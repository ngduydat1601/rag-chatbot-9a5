"""
Bước 3.6: Kiểm thử Hybrid Retriever.

Kiểm tra:
  1. Phân loại câu hỏi đúng loại (sql / vector / hybrid)
  2. SQL Retriever trả đúng kết quả
  3. Vector Retriever tìm đúng đoạn tài liệu liên quan
  4. Hybrid Retriever kết hợp đúng

Sử dụng:
  python -m kiem_thu.thu_tim_kiem
"""

import sys
from pathlib import Path

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent))

from ung_dung.tim_kiem.tim_kiem_tong_hop import phan_loai_cau_hoi, tim_kiem
from ung_dung.tim_kiem.tim_kiem_vector import tim_kiem_vector


def kiem_thu():
    so_pass = 0
    so_fail = 0

    def kiem_tra(ten_test: str, dieu_kien: bool, chi_tiet: str = ""):
        nonlocal so_pass, so_fail
        if dieu_kien:
            so_pass += 1
            print(f"  ✅ {ten_test}")
        else:
            so_fail += 1
            print(f"  ❌ {ten_test}")
            if chi_tiet:
                print(f"     → {chi_tiet}")

    print(f"\n{'='*60}")
    print(f"  KIỂM THỬ HYBRID RETRIEVER — Giai đoạn 3")
    print(f"{'='*60}")

    # ──────────────────────────────────
    # Nhóm 1: Phân loại câu hỏi
    # ──────────────────────────────────
    print(f"\n📋 Nhóm 1: Phân loại câu hỏi")

    kiem_tra(
        "1.1 SBD → sql",
        phan_loai_cau_hoi("Phòng thi của SBD 204001?") == "sql",
    )
    kiem_tra(
        "1.2 Mã HS → sql",
        phan_loai_cau_hoi("Mã học sinh 0118117832 là ai?") == "sql",
    )
    kiem_tra(
        "1.3 Phiếu báo thi gồm gì → vector",
        phan_loai_cau_hoi("Phiếu báo thi có những mục gì?") == "vector",
    )
    kiem_tra(
        "1.4 Mấy giờ có mặt → vector",
        phan_loai_cau_hoi("Mấy giờ phải có mặt buổi sáng?") == "vector",
    )
    kiem_tra(
        "1.5 Quy định thi chuyên → vector",
        phan_loai_cau_hoi("Phần tuyển sinh chuyên gồm gì?") == "vector",
    )

    # ──────────────────────────────────
    # Nhóm 2: SQL Retriever
    # ──────────────────────────────────
    print(f"\n📋 Nhóm 2: SQL Retriever qua Hybrid")

    kq = tim_kiem("Số báo danh của Đặng Linh An?")
    kiem_tra(
        "2.1 Tìm SBD theo tên → sql",
        kq["phuong_phap"] == "sql" and kq["ket_qua_sql"] is not None
        and kq["ket_qua_sql"]["tim_thay"] is True,
    )

    kq = tim_kiem("Phòng thi của SBD 204001?")
    kiem_tra(
        "2.2 Tìm phòng thi theo SBD",
        kq["ket_qua_sql"]["tim_thay"] and kq["ket_qua_sql"]["du_lieu"]["phong_thi"] == "1",
    )

    kq = tim_kiem("Nguyện vọng của SBD 204001?")
    kiem_tra(
        "2.3 Lấy nguyện vọng theo SBD",
        kq["ket_qua_sql"]["tim_thay"]
        and len(kq["ket_qua_sql"]["du_lieu"]["nguyen_vong"]) == 3,
    )

    # ──────────────────────────────────
    # Nhóm 3: Vector Retriever
    # ──────────────────────────────────
    print(f"\n📋 Nhóm 3: Vector Retriever")

    kq = tim_kiem_vector("Phiếu báo thi có những mục thông tin nào?", so_ket_qua=2)
    kiem_tra(
        "3.1 Hỏi cấu trúc phiếu → tìm được tài liệu",
        kq["tim_thay"] is True and len(kq["ket_qua"]) >= 1,
    )
    if kq["tim_thay"]:
        kiem_tra(
            "3.2 Kết quả đầu tiên có độ tương đồng > 50%",
            kq["ket_qua"][0]["do_tuong_dong"] > 0.5,
            f"Độ tương đồng: {kq['ket_qua'][0]['do_tuong_dong']:.2%}",
        )

    kq = tim_kiem_vector("Bao giờ phải đến trường làm thủ tục?", so_ket_qua=2)
    kiem_tra(
        "3.3 Hỏi thủ tục → tìm được chunk 'thoi_gian_tap_trung'",
        kq["tim_thay"] and any(r["ma_doan"] == "thoi_gian_tap_trung" for r in kq["ket_qua"]),
    )

    kq = tim_kiem_vector("Buổi sáng mấy giờ phải có mặt?", so_ket_qua=2)
    kiem_tra(
        "3.4 Hỏi giờ dự thi → tìm được chunk 'thoi_gian_du_thi'",
        kq["tim_thay"] and any(r["ma_doan"] == "thoi_gian_du_thi" for r in kq["ket_qua"]),
    )

    kq = tim_kiem_vector("Phần thi chuyên có nội dung gì?", so_ket_qua=2)
    kiem_tra(
        "3.5 Hỏi thi chuyên → tìm được chunk 'tuyen_sinh_chuyen'",
        kq["tim_thay"] and any(r["ma_doan"] == "tuyen_sinh_chuyen" for r in kq["ket_qua"]),
    )

    # ──────────────────────────────────
    # Nhóm 4: Hybrid (kết hợp)
    # ──────────────────────────────────
    print(f"\n📋 Nhóm 4: Hybrid Retriever")

    kq = tim_kiem("Linh An thi ở đâu vào lúc mấy giờ?")
    kiem_tra(
        "4.1 Câu hỏi hybrid → có cả SQL lẫn Vector",
        kq["phuong_phap"] == "hybrid",
    )

    # ──────────────────────────────────
    # Tổng kết
    # ──────────────────────────────────
    tong = so_pass + so_fail
    print(f"\n{'='*60}")
    print(f"  KẾT QUẢ: {so_pass}/{tong} PASS | {so_fail} FAIL")
    print(f"{'='*60}")


if __name__ == "__main__":
    kiem_thu()