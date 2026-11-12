"""
Kiểm thử end-to-end cho chatbot LangGraph.

Chạy: python -m kiem_thu.thu_chatbot
"""

import sys
from pathlib import Path

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent))

from ung_dung.chatbot.do_thi import hoi


def kiem_tra(so_thu: int, mo_ta: str, cau_hoi: str, tu_khoa_ky_vong: list[str]) -> bool:
    """Chạy 1 test case và in kết quả."""
    print(f"\n{'─'*60}")
    print(f"[Test {so_thu:02d}] {mo_ta}")
    print(f"  Hỏi: {cau_hoi}")

    tra_loi = hoi(cau_hoi)
    print(f"  Trả lời: {tra_loi}")

    # Kiểm tra xem câu trả lời có chứa từ khóa kỳ vọng không
    tra_loi_lower = tra_loi.lower()
    tat_ca_dung = all(tk.lower() in tra_loi_lower for tk in tu_khoa_ky_vong)

    if tat_ca_dung:
        print(f"  → PASS (tìm thấy: {tu_khoa_ky_vong})")
    else:
        thieu = [tk for tk in tu_khoa_ky_vong if tk.lower() not in tra_loi_lower]
        print(f"  → FAIL (thiếu: {thieu})")

    return tat_ca_dung


def chay_kiem_thu():
    """Chạy toàn bộ bộ test cases."""
    cac_bai_kiem_tra = [
        # (mô tả, câu hỏi, [từ khóa kỳ vọng trong câu trả lời])

        # --- Nhóm SQL: Tra cứu theo tên ---
        (
            "SQL: Tìm SBD theo tên đầy đủ",
            "Số báo danh của Đặng Linh An là bao nhiêu?",
            ["204001"],
        ),
        (
            "SQL: Tìm thông tin theo SBD",
            "Phòng thi của SBD 204001?",
            ["đặng linh an"],
        ),
        (
            "SQL: Lịch thi theo tên",
            "Lịch thi của Linh An?",
            ["ngữ văn"],
        ),
        (
            "SQL: Nguyện vọng theo tên",
            "Nguyện vọng của Đặng Linh An?",
            ["nv1"],
        ),

        # --- Nhóm Vector: Quy định chung ---
        (
            "Vector: Giờ có mặt buổi sáng",
            "Buổi sáng mấy giờ phải có mặt?",
            ["7h"],
        ),
        (
            "Vector: Thời gian tập trung",
            "Khi nào phải đến trường để làm thủ tục?",
            ["29/5"],
        ),
        (
            "Vector: Nội dung phiếu báo thi",
            "Phiếu báo thi có những mục gì?",
            ["họ tên"],
        ),

        # --- Ngoài phạm vi ---
        (
            "Ngoài phạm vi: Thời tiết",
            "Hôm nay thời tiết thế nào?",
            ["xin lỗi", "phạm vi"],
        ),
        (
            "Ngoài phạm vi: Toán học",
            "2 + 2 bằng bao nhiêu?",
            ["xin lỗi"],
        ),
    ]

    tong_so = len(cac_bai_kiem_tra)
    so_pass = 0

    print("=" * 60)
    print("  KIỂM THỬ CHATBOT LANGGRAPH — PHIẾU BÁO THI 9A5")
    print("=" * 60)

    for i, (mo_ta, cau_hoi, tu_khoa) in enumerate(cac_bai_kiem_tra, 1):
        ket_qua = kiem_tra(i, mo_ta, cau_hoi, tu_khoa)
        if ket_qua:
            so_pass += 1

    print(f"\n{'=' * 60}")
    print(f"  KẾT QUẢ: {so_pass}/{tong_so} PASS")
    if so_pass == tong_so:
        print("  Tất cả test đều PASS!")
    else:
        print(f"  {tong_so - so_pass} test FAIL — kiểm tra lại prompt hoặc logic.")
    print("=" * 60)


if __name__ == "__main__":
    chay_kiem_thu()
