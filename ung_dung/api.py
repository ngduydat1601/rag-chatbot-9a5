"""
Giao diện API RESTful cho Chatbot tra cứu phiếu báo thi 9A5 (có hỗ trợ Session Memory).

Sử dụng FastAPI để cung cấp các endpoint nhận câu hỏi và trả về câu trả lời.
Khởi chạy server:
    python -m ung_dung.api
hoặc:
    uvicorn ung_dung.api:ung_dung_api --reload --port 8000
"""

import sys
from pathlib import Path
from typing import Optional

# Đảm bảo mã hóa UTF-8 trên Windows
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

# Thêm thư mục gốc dự án vào sys.path
THU_MUC_GOC = Path(__file__).resolve().parent.parent
sys.path.append(str(THU_MUC_GOC))

from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from ung_dung.chatbot.do_thi import hoi
from ung_dung.co_so_du_lieu.quet_schema import lay_schema_csdl


# ──────────────────────────────────────────────
# Khởi tạo ứng dụng FastAPI
# ──────────────────────────────────────────────
ung_dung_api = FastAPI(
    title="API Chatbot Tra Cứu Phiếu Báo Thi Lớp 9A5",
    description="API tiếp nhận câu hỏi của người dùng, hỗ trợ ghi nhớ ngữ cảnh cuộc trò chuyện theo session_id.",
    version="1.1.0",
)

# Cấu hình CORS để cho phép frontend gọi tới từ bất kỳ cổng nào
ung_dung_api.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ──────────────────────────────────────────────
# Bộ nhớ lưu lịch sử theo phiên (Session Memory)
# Cấu trúc: {session_id: [{"vai_tro": "user"/"assistant", "noi_dung": "..."}]}
# ──────────────────────────────────────────────
BO_NHO_PHIEN: dict[str, list[dict]] = {}


# ──────────────────────────────────────────────
# Định nghĩa Schema dữ liệu đầu vào / đầu ra
# ──────────────────────────────────────────────
class YeuCauHoi(BaseModel):
    """Mẫu dữ liệu yêu cầu gửi câu hỏi kèm mã phiên chat."""
    cau_hoi: str = Field(
        ...,
        min_length=1,
        description="Nội dung câu hỏi cần tra cứu",
        examples=["Số báo danh của Đặng Linh An là bao nhiêu?"]
    )
    session_id: Optional[str] = Field(
        default="mac_dinh",
        description="Mã định danh phiên hội thoại để lưu nhớ ngữ cảnh qua lại",
        examples=["phien_1", "user_123"]
    )


class PhanHoiTraLoi(BaseModel):
    """Mẫu dữ liệu phản hồi câu trả lời."""
    cau_hoi: str = Field(description="Câu hỏi gốc từ người dùng")
    cau_tra_loi: str = Field(description="Nội dung câu trả lời từ chatbot")
    session_id: str = Field(description="Mã phiên hội thoại hiện tại")
    thanh_cong: bool = Field(default=True, description="Trạng thái xử lý")


GIAO_DIEN_HTML = r"""<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trợ lý Tra Cứu Phiếu Báo Thi - Lớp 9A5</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Inter', sans-serif; }
    .scrollbar-w-2::-webkit-scrollbar { width: 6px; }
    .scrollbar-track-blue-lighter::-webkit-scrollbar-track { background-color: #f1f5f9; }
    .scrollbar-thumb-blue::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 9999px; }
  </style>
</head>
<body class="bg-slate-100 h-screen flex flex-col justify-between">
  <!-- Header -->
  <header class="bg-white border-b border-slate-200 px-4 py-3 shadow-sm flex items-center justify-between sticky top-0 z-10">
    <div class="flex items-center space-x-3">
      <div class="w-10 h-10 rounded-full bg-blue-600 flex items-center justify-center text-white text-xl shadow-md">
        🎓
      </div>
      <div>
        <h1 class="text-base font-bold text-slate-800 leading-tight">Tra Cứu Phiếu Báo Thi 9A5</h1>
        <p class="text-xs text-slate-500">THCS Chu Văn An • Tuyển sinh Lớp 10 (2026-2027)</p>
      </div>
    </div>
    <div class="flex items-center space-x-2">
      <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
        <span class="w-1.5 h-1.5 mr-1.5 bg-emerald-500 rounded-full animate-ping"></span>
        Trực tuyến
      </span>
      <button onclick="xoaCuocTroChuyen()" title="Cuộc trò chuyện mới" class="p-2 text-slate-400 hover:text-rose-600 hover:bg-slate-100 rounded-lg transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
      </button>
    </div>
  </header>

  <!-- Chat container -->
  <main id="khung-chat" class="flex-1 overflow-y-auto p-4 space-y-4 max-w-3xl w-full mx-auto scrollbar-w-2 scrollbar-track-blue-lighter scrollbar-thumb-blue">
    <!-- Welcome message -->
    <div class="flex items-start space-x-3">
      <div class="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center text-white text-sm shrink-0">🤖</div>
      <div class="bg-white border border-slate-200 rounded-2xl rounded-tl-none p-4 shadow-sm max-w-[85%] text-slate-700 text-sm leading-relaxed">
        <p class="font-medium text-slate-900 mb-2">Xin chào! 👋</p>
        <p>Tôi là trợ lý AI tra cứu phiếu báo thi của 43 học sinh lớp 9A5, THCS Chu Văn An. Bạn có thể tra cứu thông tin thí sinh, lịch thi, phòng thi hoặc các quy định chung.</p>
        
        <div class="mt-3 pt-3 border-t border-slate-100 space-y-1.5">
          <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Gợi ý câu hỏi nhanh:</p>
          <div class="flex flex-wrap gap-1.5">
            <button onclick="chonGoiY(this.innerText)" class="text-xs bg-slate-50 hover:bg-blue-50 hover:text-blue-600 text-slate-600 px-2.5 py-1.5 rounded-lg border border-slate-200 transition-colors text-left">📌 Số báo danh của Linh An?</button>
            <button onclick="chonGoiY(this.innerText)" class="text-xs bg-slate-50 hover:bg-blue-50 hover:text-blue-600 text-slate-600 px-2.5 py-1.5 rounded-lg border border-slate-200 transition-colors text-left">📊 Tổng bạn thi tại THPT Nguyễn Quốc Trinh?</button>
            <button onclick="chonGoiY(this.innerText)" class="text-xs bg-slate-50 hover:bg-blue-50 hover:text-blue-600 text-slate-600 px-2.5 py-1.5 rounded-lg border border-slate-200 transition-colors text-left">⏰ Mấy giờ phải có mặt buổi sáng?</button>
            <button onclick="chonGoiY(this.innerText)" class="text-xs bg-slate-50 hover:bg-blue-50 hover:text-blue-600 text-slate-600 px-2.5 py-1.5 rounded-lg border border-slate-200 transition-colors text-left">🏫 Bạn Bảo Anh có những nguyện vọng nào?</button>
          </div>
        </div>
      </div>
    </div>
  </main>

  <!-- Input footer -->
  <footer class="bg-white border-t border-slate-200 p-3 sticky bottom-0">
    <div class="max-w-3xl mx-auto">
      <form id="form-chat" onsubmit="guiTinNhan(event)" class="flex items-center space-x-2">
        <input 
          id="o-nhap" 
          type="text" 
          placeholder="Nhập câu hỏi tra cứu... (Ví dụ: Lịch thi của Đặng Linh An?)" 
          autocomplete="off"
          class="flex-1 bg-slate-50 border border-slate-300 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white text-slate-800 transition"
        />
        <button 
          id="nut-gui" 
          type="submit" 
          class="bg-blue-600 hover:bg-blue-700 text-white rounded-xl px-4 py-3 shadow transition flex items-center justify-center shrink-0 disabled:opacity-50"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
          </svg>
        </button>
      </form>
      <p class="text-[11px] text-center text-slate-400 mt-2">Dữ liệu trích xuất chính xác từ 43 phiếu báo thi lớp 9A5 • Hỗ trợ Text-to-SQL & Vector Search</p>
    </div>
  </footer>

  <script>
    let maPhien = sessionStorage.getItem('ma_phien') || ('phien_' + Math.random().toString(36).substring(2, 9));
    sessionStorage.setItem('ma_phien', maPhien);

    const khungChat = document.getElementById('khung-chat');
    const oNhap = document.getElementById('o-nhap');
    const nutGui = document.getElementById('nut-gui');

    function dinhDangVanBan(text) {
      if (!text) return '';
      let escaped = text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
      escaped = escaped.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
      escaped = escaped.replace(/\*(.*?)\*/g, '<em>$1</em>');
      escaped = escaped.replace(/`([^`]+)`/g, '<code class="bg-slate-100 text-rose-600 px-1 py-0.5 rounded text-xs">$1</code>');
      escaped = escaped.replace(/^[\*\-] (.*$)/gim, '<li class="ml-4 list-disc">$1</li>');
      escaped = escaped.replace(/^\d+\. (.*$)/gim, '<li class="ml-4 list-decimal">$1</li>');
      escaped = escaped.replace(/\n/g, '<br/>');
      return escaped;
    }

    function cuonXuongCuoi() {
      khungChat.scrollTop = khungChat.scrollHeight;
    }

    function chonGoiY(cauHoi) {
      const sachCauHoi = cauHoi.replace(/^[^\w\s\u00C0-\u1EF9]+/, '').trim();
      oNhap.value = sachCauHoi;
      oNhap.focus();
    }

    function themTinNhan(vaiTro, noiDung) {
      const isUser = vaiTro === 'user';
      const msgDiv = document.createElement('div');
      msgDiv.className = `flex items-start space-x-3 ${isUser ? 'flex-row-reverse space-x-reverse' : ''}`;
      
      const avatar = document.createElement('div');
      avatar.className = `w-8 h-8 rounded-full flex items-center justify-center text-sm shrink-0 ${isUser ? 'bg-slate-700 text-white' : 'bg-blue-600 text-white'}`;
      avatar.innerText = isUser ? '👤' : '🤖';

      const content = document.createElement('div');
      content.className = isUser 
        ? 'bg-blue-600 text-white rounded-2xl rounded-tr-none p-3.5 shadow-sm max-w-[85%] text-sm leading-relaxed' 
        : 'bg-white border border-slate-200 text-slate-800 rounded-2xl rounded-tl-none p-3.5 shadow-sm max-w-[85%] text-sm leading-relaxed';
      content.innerHTML = isUser ? dinhDangVanBan(noiDung) : dinhDangVanBan(noiDung);

      msgDiv.appendChild(avatar);
      msgDiv.appendChild(content);
      khungChat.appendChild(msgDiv);
      cuonXuongCuoi();
    }

    function themDangGo() {
      const typingDiv = document.createElement('div');
      typingDiv.id = 'typing-indicator';
      typingDiv.className = 'flex items-start space-x-3';
      typingDiv.innerHTML = `
        <div class="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center text-white text-sm shrink-0">🤖</div>
        <div class="bg-white border border-slate-200 rounded-2xl rounded-tl-none px-4 py-3 shadow-sm text-slate-500 text-sm flex items-center space-x-1.5">
          <span class="w-2 h-2 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 0ms"></span>
          <span class="w-2 h-2 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 150ms"></span>
          <span class="w-2 h-2 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 300ms"></span>
          <span class="text-xs text-slate-400 ml-2">Đang tra cứu dữ liệu...</span>
        </div>
      `;
      khungChat.appendChild(typingDiv);
      cuonXuongCuoi();
    }

    function xoaDangGo() {
      const el = document.getElementById('typing-indicator');
      if (el) el.remove();
    }

    async function guiTinNhan(e) {
      if (e) e.preventDefault();
      const cauHoi = oNhap.value.trim();
      if (!cauHoi) return;

      themTinNhan('user', cauHoi);
      oNhap.value = '';
      oNhap.disabled = true;
      nutGui.disabled = true;
      themDangGo();

      try {
        const res = await fetch('/api/chat', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': '1'
          },
          body: JSON.stringify({ cau_hoi: cauHoi, session_id: maPhien })
        });
        const data = await res.json();
        xoaDangGo();
        if (data.thanh_cong) {
          themTinNhan('assistant', data.cau_tra_loi);
        } else {
          themTinNhan('assistant', data.detail || 'Xin lỗi, không nhận được phản hồi hợp lệ.');
        }
      } catch (err) {
        xoaDangGo();
        themTinNhan('assistant', 'Lỗi kết nối tới máy chủ. Vui lòng thử lại!');
      } finally {
        oNhap.disabled = false;
        nutGui.disabled = false;
        oNhap.focus();
      }
    }

    async function xoaCuocTroChuyen() {
      if (!confirm('Bạn có muốn bắt đầu một cuộc trò chuyện mới không?')) return;
      try {
        await fetch('/api/chat/phien/' + maPhien, { method: 'DELETE' });
      } catch (e) {}
      maPhien = 'phien_' + Math.random().toString(36).substring(2, 9);
      sessionStorage.setItem('ma_phien', maPhien);
      location.reload();
    }
  </script>
</body>
</html>
"""


# ──────────────────────────────────────────────
# Các Endpoint API
# ──────────────────────────────────────────────
@ung_dung_api.get("/", response_class=HTMLResponse, summary="Giao diện Chatbot Trực quan")
def trang_chu():
    """Phục vụ giao diện web chat trực quan cho người dùng."""
    return HTMLResponse(content=GIAO_DIEN_HTML)


@ung_dung_api.get("/api/kiem_tra", summary="Kiểm tra trạng thái sức khỏe")
def kiem_tra_suc_khoe():
    """Endpoint dùng để kiểm tra server có đang sống không."""
    return {"trang_thai": "hoat_dong_tot"}


@ung_dung_api.post(
    "/api/chat",
    response_model=PhanHoiTraLoi,
    summary="Gửi câu hỏi và nhận câu trả lời (có nhớ ngữ cảnh)",
)
def xu_ly_cau_hoi(yeu_cau: YeuCauHoi):
    """
    Tiếp nhận câu hỏi từ client, lấy lịch sử của session_id,
    chuyển qua đồ thị LangGraph xử lý và cập nhật lại bộ nhớ phiên.
    """
    cau_hoi_nguoi_dung = yeu_cau.cau_hoi.strip()
    ma_phien = yeu_cau.session_id.strip() if yeu_cau.session_id else "mac_dinh"

    if not cau_hoi_nguoi_dung:
        raise HTTPException(status_code=400, detail="Câu hỏi không được để trống.")

    try:
        # Lấy lịch sử hội thoại của phiên này (nếu có)
        lich_su = BO_NHO_PHIEN.get(ma_phien, [])

        # Gọi hàm xử lý từ đồ thị LangGraph kèm lịch sử hội thoại
        ket_qua_tra_loi = hoi(cau_hoi=cau_hoi_nguoi_dung, lich_su_chat=lich_su)

        # Cập nhật lịch sử mới vào phiên
        if ma_phien not in BO_NHO_PHIEN:
            BO_NHO_PHIEN[ma_phien] = []
        BO_NHO_PHIEN[ma_phien].append({"vai_tro": "user", "noi_dung": cau_hoi_nguoi_dung})
        BO_NHO_PHIEN[ma_phien].append({"vai_tro": "assistant", "noi_dung": ket_qua_tra_loi})

        # Giữ tối đa 20 tin nhắn gần nhất cho mỗi phiên
        if len(BO_NHO_PHIEN[ma_phien]) > 20:
            BO_NHO_PHIEN[ma_phien] = BO_NHO_PHIEN[ma_phien][-20:]

        return PhanHoiTraLoi(
            cau_hoi=cau_hoi_nguoi_dung,
            cau_tra_loi=ket_qua_tra_loi,
            session_id=ma_phien,
            thanh_cong=True,
        )
    except Exception as loi:
        raise HTTPException(
            status_code=500,
            detail=f"Lỗi khi xử lý câu hỏi: {str(loi)}"
        )


@ung_dung_api.delete(
    "/api/chat/phien/{ma_phien}",
    summary="Xóa lịch sử hội thoại của một phiên",
)
def xoa_lich_su_phien(ma_phien: str):
    """Reset cuộc trò chuyện cho một session_id cụ thể."""
    if ma_phien in BO_NHO_PHIEN:
        del BO_NHO_PHIEN[ma_phien]
        return {"thong_bao": f"Đã xóa lịch sử phiên chat '{ma_phien}' thành công."}
    return {"thong_bao": f"Phiên chat '{ma_phien}' không tồn tại hoặc đã trống."}


@ung_dung_api.post(
    "/api/schema/lam_moi",
    summary="Quét lại cấu trúc CSDL và làm mới bộ nhớ đệm",
)
def lam_moi_schema():
    """Đọc lại cấu trúc các bảng từ PostgreSQL và cập nhật cache."""
    schema_moi = lay_schema_csdl(lam_moi=True)
    return {
        "thanh_cong": True,
        "thong_bao": "Đã quét lại cấu trúc CSDL từ PostgreSQL thành công.",
        "schema": schema_moi,
    }


@ung_dung_api.get(
    "/api/ping",
    summary="Endpoint siêu nhẹ để cron-job ping giữ thức",
)
def ping():
    """Trả về phản hồi 2 byte cực nhẹ để cron-job ping không bị lỗi output too large."""
    return "OK"


# ──────────────────────────────────────────────
# Chạy trực tiếp qua lệnh python
# ──────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    print("=" * 60)
    print("Khởi chạy máy chủ API tại http://127.0.0.1:8000")
    print("Xem tài liệu tương tác Swagger UI tại http://127.0.0.1:8000/docs")
    print("=" * 60)
    uvicorn.run(ung_dung_api, host="0.0.0.0", port=8000)
