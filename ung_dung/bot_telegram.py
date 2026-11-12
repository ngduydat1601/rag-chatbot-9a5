"""
Kết nối Chatbot LangGraph 9A5 với Telegram.

Khởi chạy:
    python -m ung_dung.bot_telegram
"""

import sys
import asyncio
from pathlib import Path

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

THU_MUC_GOC = Path(__file__).resolve().parent.parent
sys.path.append(str(THU_MUC_GOC))

import httpx
from telegram import Update
from telegram.constants import ChatAction
from telegram.error import NetworkError, TimedOut
from telegram.request import HTTPXRequest
from telegram.ext import (
    ApplicationBuilder,
    CommandHandler,
    MessageHandler,
    ContextTypes,
    filters,
)

from ung_dung.cau_hinh import TELEGRAM_BOT_TOKEN
from ung_dung.chatbot.do_thi import hoi

# Lưu lịch sử hội thoại theo chat_id của từng người dùng Telegram
BO_NHO_TELEGRAM: dict[int, list[dict]] = {}


async def _gui_phan_hoi_an_toan(update: Update, van_ban: str, parse_mode: str = None):
    """Gửi tin nhắn kèm cơ chế tự thử lại tối đa 3 lần nếu mạng chập chờn."""
    for lan_thu in range(1, 4):
        try:
            await update.message.reply_text(van_ban, parse_mode=parse_mode)
            return
        except (NetworkError, TimedOut) as loi_mang:
            print(f"⚠️ Lỗi mạng khi gửi tin nhắn (Lần {lan_thu}/3): {loi_mang}")
            if lan_thu < 3:
                await asyncio.sleep(1.5)
        except Exception:
            # Nếu lỗi định dạng Markdown, gửi lại dạng văn bản thuần
            if parse_mode is not None:
                await update.message.reply_text(van_ban)
                return
            raise


async def lenh_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Xử lý khi người dùng gõ /start."""
    loi_chao = (
        "🎓 *Xin chào! Tôi là Trợ lý Tra Cứu Phiếu Báo Thi Lớp 9A5*\n"
        "_(Trường THCS Chu Văn An, Hà Nội)_\n\n"
        "Bạn có thể hỏi trực tiếp các thông tin như:\n"
        "• _Số báo danh của Đặng Linh An là bao nhiêu?_\n"
        "• _Tổng các bạn thi tại THPT Nguyễn Quốc Trinh?_\n"
        "• _Bạn Bảo Anh có những nguyện vọng nào?_\n"
        "• _Buổi sáng mấy giờ phải có mặt tại phòng thi?_\n\n"
        "💡 Gõ /xoa bất kỳ lúc nào để xóa lịch sử trò chuyện."
    )
    await _gui_phan_hoi_an_toan(update, loi_chao, parse_mode="Markdown")


async def lenh_xoa(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Xử lý khi người dùng gõ /xoa để làm mới ngữ cảnh."""
    ma_chat = update.effective_chat.id
    if ma_chat in BO_NHO_TELEGRAM:
        del BO_NHO_TELEGRAM[ma_chat]
    await _gui_phan_hoi_an_toan(
        update,
        "🗑️ Đã xóa lịch sử trò chuyện! Bạn có thể bắt đầu câu hỏi mới."
    )


async def xu_ly_tin_nhan(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Nhận tin nhắn văn bản từ Telegram, đưa qua LangGraph và phản hồi."""
    if not update.message or not update.message.text:
        return

    cau_hoi = update.message.text.strip()
    ma_chat = update.effective_chat.id
    ten_nguoi_dung = update.effective_user.full_name

    print(f"📩 [{ten_nguoi_dung} - {ma_chat}]: {cau_hoi}")

    # Hiển thị trạng thái "Đang gõ..." (bọc try-except để không làm gián đoạn nếu mạng lag)
    try:
        await context.bot.send_chat_action(chat_id=ma_chat, action=ChatAction.TYPING)
    except Exception:
        pass

    lich_su = BO_NHO_TELEGRAM.get(ma_chat, [])

    try:
        # Chạy hàm hoi() trong thread riêng để không làm nghẽn vòng lặp bất đồng bộ
        cau_tra_loi = await asyncio.to_thread(hoi, cau_hoi, lich_su)

        # Cập nhật lịch sử hội thoại cho người dùng này (giữ tối đa 20 tin)
        if ma_chat not in BO_NHO_TELEGRAM:
            BO_NHO_TELEGRAM[ma_chat] = []
        BO_NHO_TELEGRAM[ma_chat].append({"vai_tro": "user", "noi_dung": cau_hoi})
        BO_NHO_TELEGRAM[ma_chat].append({"vai_tro": "assistant", "noi_dung": cau_tra_loi})
        if len(BO_NHO_TELEGRAM[ma_chat]) > 20:
            BO_NHO_TELEGRAM[ma_chat] = BO_NHO_TELEGRAM[ma_chat][-20:]

        print(f"🤖 Trả lời [{ten_nguoi_dung}]: {cau_tra_loi[:80]}...")
        await _gui_phan_hoi_an_toan(update, cau_tra_loi)

    except Exception as loi:
        print(f"❌ Lỗi xử lý Telegram: {loi}")
        await _gui_phan_hoi_an_toan(
            update,
            "⚠️ Hệ thống đang bận hoặc gặp sự cố tạm thời. Bạn vui lòng thử lại sau ít giây nhé!"
        )


async def xu_ly_loi_he_thong(update: object, context: ContextTypes.DEFAULT_TYPE):
    """Bắt và ghi log gọn gàng các lỗi mạng ngầm của Telegram."""
    print(f"⚠️ Cảnh báo kết nối Telegram: {context.error}")


def _tao_bo_ket_noi_http() -> HTTPXRequest:
    """Tạo bộ kết nối HTTPX ưu tiên IPv4 và tự động retry 3 lần ở tầng TCP."""
    transport = httpx.AsyncHTTPTransport(retries=3, local_address="0.0.0.0")
    return HTTPXRequest(
        connection_pool_size=8,
        connect_timeout=30.0,
        read_timeout=30.0,
        write_timeout=30.0,
        pool_timeout=30.0,
        httpx_kwargs={"transport": transport},
    )


def chay_bot():
    """Khởi động Telegram Bot ở chế độ Polling."""
    if not TELEGRAM_BOT_TOKEN:
        print("❌ LỖI: Chưa cấu hình TELEGRAM_BOT_TOKEN trong file .env!")
        return

    ung_dung = (
        ApplicationBuilder()
        .token(TELEGRAM_BOT_TOKEN)
        .request(_tao_bo_ket_noi_http())
        .get_updates_request(_tao_bo_ket_noi_http())
        .build()
    )

    # Đăng ký các bộ xử lý lệnh, tin nhắn và lỗi mạng
    ung_dung.add_handler(CommandHandler("start", lenh_start))
    ung_dung.add_handler(CommandHandler("xoa", lenh_xoa))
    ung_dung.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), xu_ly_tin_nhan))
    ung_dung.add_error_handler(xu_ly_loi_he_thong)

    print("=" * 60)
    print("🤖 TELEGRAM BOT ĐANG HOẠT ĐỘNG! (Nhấn Ctrl+C để dừng)")
    print("=" * 60)
    ung_dung.run_polling(bootstrap_retries=-1, drop_pending_updates=True)


if __name__ == "__main__":
    chay_bot()
