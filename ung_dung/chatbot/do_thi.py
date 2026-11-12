"""
Lắp ghép LangGraph StateGraph từ các node đã định nghĩa.

Sơ đồ luồng:
  START
    → phan_tich_cau_hoi          (Node 1)
    → dinh_tuyen                  (Conditional edge — Node 2)
    → truy_van_sql                (Node 3A — nếu y_dinh=sql)
    → tim_kiem_vector_node        (Node 3B — nếu y_dinh=vector)
    → truy_van_tong_hop           (Node 3C — nếu y_dinh=hybrid)
    → tong_hop_bang_chung         (Node 4)
    → tao_cau_tra_loi             (Node 5)
    → END

  HOẶC:
    → tu_choi                     (Node 6 — nếu y_dinh=ngoai_pham_vi)
    → END
"""

import sys
import threading
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from langgraph.graph import StateGraph, END

from ung_dung.chatbot.trang_thai import TrangThaiChat
from ung_dung.chatbot.cac_node import (
    phan_tich_cau_hoi,
    dinh_tuyen,
    truy_van_sql,
    tim_kiem_vector_node,
    truy_van_tong_hop,
    tong_hop_bang_chung,
    tao_cau_tra_loi,
    tu_choi,
    khoi_dong_am_he_thong,
)


def tao_do_thi_chatbot() -> StateGraph:
    """
    Tạo và biên dịch đồ thị LangGraph cho chatbot.
    """
    do_thi = StateGraph(TrangThaiChat)

    # ── Thêm các node ──
    do_thi.add_node("phan_tich_cau_hoi", phan_tich_cau_hoi)
    do_thi.add_node("truy_van_sql", truy_van_sql)
    do_thi.add_node("tim_kiem_vector_node", tim_kiem_vector_node)
    do_thi.add_node("truy_van_tong_hop", truy_van_tong_hop)
    do_thi.add_node("tong_hop_bang_chung", tong_hop_bang_chung)
    do_thi.add_node("tao_cau_tra_loi", tao_cau_tra_loi)
    do_thi.add_node("tu_choi", tu_choi)

    # ── Node bắt đầu ──
    do_thi.set_entry_point("phan_tich_cau_hoi")

    # ── Conditional edge sau Node 1 ──
    do_thi.add_conditional_edges(
        source="phan_tich_cau_hoi",
        path=dinh_tuyen,
        path_map={
            "truy_van_sql": "truy_van_sql",
            "tim_kiem_vector_node": "tim_kiem_vector_node",
            "truy_van_tong_hop": "truy_van_tong_hop",
            "tu_choi": "tu_choi",
        },
    )

    # ── Các node 3A/3B/3C đều đi vào Node 4 ──
    do_thi.add_edge("truy_van_sql", "tong_hop_bang_chung")
    do_thi.add_edge("tim_kiem_vector_node", "tong_hop_bang_chung")
    do_thi.add_edge("truy_van_tong_hop", "tong_hop_bang_chung")

    # ── Node 4 → Node 5 ──
    do_thi.add_edge("tong_hop_bang_chung", "tao_cau_tra_loi")

    # ── Node 5 và Node 6 → kết thúc ──
    do_thi.add_edge("tao_cau_tra_loi", END)
    do_thi.add_edge("tu_choi", END)

    return do_thi.compile()


# ── Singleton: tạo 1 lần, dùng nhiều lần ──
CHATBOT = tao_do_thi_chatbot()

# Làm ấm hệ thống ở luồng nền ngay khi import (không chặn quá trình khởi động API / Telegram Bot)
threading.Thread(target=khoi_dong_am_he_thong, daemon=True).start()

# Bộ nhớ đệm câu trả lời trong RAM (giúp trả lời tức thì 0.001s nếu trùng câu hỏi & ngữ cảnh)
_BO_NHO_DEM_CAU_HOI: dict[tuple[str, str], str] = {}
_GIOI_HAN_CACHE = 256


def _tao_khoa_cache(cau_hoi: str, lich_su_chat: list[dict] = None) -> tuple[str, str]:
    """Chuẩn hóa câu hỏi và câu gần nhất trong lịch sử làm khóa cache."""
    cau_hoi_chuan = " ".join(cau_hoi.strip().lower().split())
    if not lich_su_chat:
        ngu_canh = ""
    else:
        tin_cuoi = lich_su_chat[-2:]
        ngu_canh = "|".join(f"{t.get('vai_tro')}:{t.get('noi_dung', '')[:80]}" for t in tin_cuoi)
    return (cau_hoi_chuan, ngu_canh)


def hoi(cau_hoi: str, lich_su_chat: list[dict] = None) -> str:
    """
    Hàm giao tiếp công khai — đầu vào câu hỏi và lịch sử (nếu có), đầu ra câu trả lời.
    """
    khoa_cache = _tao_khoa_cache(cau_hoi, lich_su_chat)
    if khoa_cache in _BO_NHO_DEM_CAU_HOI:
        return _BO_NHO_DEM_CAU_HOI[khoa_cache]

    trang_thai_dau_vao: TrangThaiChat = {
        "cau_hoi": cau_hoi,
        "lich_su_chat": lich_su_chat,
        "y_dinh": None,
        "cau_sql": None,
        "ket_qua_sql": None,
        "ket_qua_vector": None,
        "bang_chung": None,
        "cau_tra_loi": None,
        "trang_thai": None,
        "thong_bao_loi": None,
    }

    trang_thai_cuoi = CHATBOT.invoke(trang_thai_dau_vao)
    cau_tra_loi = trang_thai_cuoi.get("cau_tra_loi", "Xin lỗi, không có câu trả lời.")

    # Chỉ lưu cache khi trạng thái xử lý thành công hoặc ngoài phạm vi
    if trang_thai_cuoi.get("trang_thai") in ("thanh_cong", "ngoai_pham_vi"):
        if len(_BO_NHO_DEM_CAU_HOI) >= _GIOI_HAN_CACHE:
            _BO_NHO_DEM_CAU_HOI.pop(next(iter(_BO_NHO_DEM_CAU_HOI)))
        _BO_NHO_DEM_CAU_HOI[khoa_cache] = cau_tra_loi

    return cau_tra_loi


if __name__ == "__main__":
    import time

    if sys.stdout.encoding != 'utf-8':
        try:
            sys.stdout.reconfigure(encoding='utf-8')
        except Exception:
            pass

    cac_cau_hoi_thu = [
        "Tổng các bạn thi tại THPT Nguyễn Quốc Trinh là bao nhiêu?",
        "Số báo danh của Đặng Linh An là bao nhiêu?",
        "Mấy giờ phải có mặt buổi sáng?",
        "Số báo danh của Đặng Linh An là bao nhiêu?",  # Kiểm tra tốc độ Cache
    ]

    for cau in cac_cau_hoi_thu:
        print(f"\n{'─'*60}")
        print(f"HỎI: {cau}")
        t_bat_dau = time.perf_counter()
        tra_loi = hoi(cau)
        thoi_gian = time.perf_counter() - t_bat_dau
        print(f"⏱️ THỜI GIAN: {thoi_gian:.2f} giây")
        print(f"TRẢ LỜI: {tra_loi}")
