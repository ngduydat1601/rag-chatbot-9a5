"""
Bước 2.7: Kiểm thử toàn bộ database (SQL thuần).

Kiểm tra:
  1. Đủ 43 bản ghi
  2. Không trùng SBD / mã HS
  3. Quan hệ thí sinh ↔ nguyện vọng chính xác
  4. Tất cả 7 hàm truy vấn hoạt động đúng
  5. Tìm kiếm không dấu hoạt động

Sử dụng:
  python -m kiem_thu.thu_csdl
"""

import sys
from pathlib import Path
import psycopg2

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent))
from ung_dung.cau_hinh import CHUOI_KET_NOI_DB
from ung_dung.co_so_du_lieu.truy_van import (
    tim_thi_sinh_theo_ten,
    tim_thi_sinh_theo_sbd,
    tim_thi_sinh_theo_ma,
    lay_lich_thi,
    lay_nguyen_vong,
    lay_thi_sinh_theo_diem_thi,
    dem_thi_sinh_theo_diem_thi,
)


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
    print(f"  KIỂM THỬ DATABASE (SQL THUẦN) — Giai đoạn 2")
    print(f"{'='*60}")

    # Nhóm 1: Kiểm tra dữ liệu trực tiếp bằng SQL
    print(f"\n📋 Nhóm 1: Kiểm tra tính toàn vẹn dữ liệu")
    conn = psycopg2.connect(CHUOI_KET_NOI_DB)
    cur = conn.cursor()

    cur.execute("SELECT COUNT(*) FROM thi_sinh;")
    so_ts = cur.fetchone()[0]
    kiem_tra("1.1 Đủ 43 thí sinh", so_ts == 43, f"Có {so_ts} thí sinh")

    cur.execute("SELECT so_bao_danh, COUNT(*) FROM thi_sinh GROUP BY so_bao_danh HAVING COUNT(*) > 1;")
    sbd_trung = cur.fetchall()
    kiem_tra("1.2 Không trùng SBD", len(sbd_trung) == 0, f"SBD trùng: {sbd_trung}")

    cur.execute("SELECT ma_hoc_sinh, COUNT(*) FROM thi_sinh GROUP BY ma_hoc_sinh HAVING COUNT(*) > 1;")
    ma_trung = cur.fetchall()
    kiem_tra("1.3 Không trùng mã HS", len(ma_trung) == 0, f"Mã trùng: {ma_trung}")

    cur.execute("SELECT COUNT(*) FROM tuyen_sinh_chuyen;")
    so_tsc = cur.fetchone()[0]
    kiem_tra("1.4 Đúng 1 thí sinh thi chuyên", so_tsc == 1, f"Có {so_tsc}")

    cur.execute("SELECT COUNT(*) FROM nguyen_vong_chuyen;")
    so_nvc = cur.fetchone()[0]
    kiem_tra("1.5 Thí sinh chuyên có 2 NV chuyên", so_nvc == 2, f"Có {so_nvc}")

    cur.close()
    conn.close()

    # Nhóm 2: Kiểm tra các hàm truy vấn
    print(f"\n📋 Nhóm 2: Kiểm tra các hàm truy vấn")

    kq = tim_thi_sinh_theo_ten("ĐẶNG LINH AN")
    kiem_tra("2.1 Tìm theo tên có dấu", kq["tim_thay"] is True)

    kq = tim_thi_sinh_theo_ten("linh an")
    kiem_tra("2.2 Tìm theo tên một phần (không dấu)", kq["tim_thay"] is True)

    kq = tim_thi_sinh_theo_sbd("204001")
    kiem_tra("2.3 Tìm theo SBD '204001'", kq["tim_thay"] and kq["du_lieu"]["ho_ten"] == "ĐẶNG LINH AN")

    kq = tim_thi_sinh_theo_sbd("999999")
    kiem_tra("2.4 SBD không tồn tại → tim_thay=False", kq["tim_thay"] is False)

    kq = tim_thi_sinh_theo_ma("0118117832")
    kiem_tra("2.5 Tìm theo mã HS '0118117832'", kq["tim_thay"] and kq["du_lieu"]["ho_ten"] == "ĐẶNG LINH AN")

    kq = lay_lich_thi(sbd="204001")
    kiem_tra("2.6 Lịch thi có đủ 3 môn", kq["tim_thay"] and len(kq["du_lieu"]["lich_thi"]) == 3)
    kiem_tra("2.7 Có thời gian tập trung", kq["tim_thay"] and kq["du_lieu"]["thoi_gian_tap_trung"] == "9h00 ngày 29/5/2026")

    kq = lay_nguyen_vong(sbd="204001")
    kiem_tra("2.8 Nguyện vọng có đủ 3 NV", kq["tim_thay"] and len(kq["du_lieu"]["nguyen_vong"]) == 3)
    if kq["tim_thay"]:
        kiem_tra("2.9 NV1 = 'Nguyễn Quốc Trinh'", kq["du_lieu"]["nguyen_vong"][0]["ten_truong"] == "Nguyễn Quốc Trinh")

    kq = dem_thi_sinh_theo_diem_thi("Nguyễn Quốc Trinh")
    kiem_tra("2.10 Đếm thí sinh theo điểm thi > 0", kq["tim_thay"] and kq["so_luong"] > 0)

    kq = lay_thi_sinh_theo_diem_thi("Nguyễn Quốc Trinh")
    kiem_tra("2.11 Liệt kê thí sinh theo điểm thi", kq["tim_thay"] and len(kq["du_lieu"]) > 0)

    # Thí sinh chuyên
    kq_chuyen = tim_thi_sinh_theo_ten("Phùng Minh Vũ")
    if kq_chuyen["tim_thay"]:
        du_lieu = kq_chuyen["du_lieu"] if isinstance(kq_chuyen["du_lieu"], dict) else kq_chuyen["du_lieu"][0]
        kq_nv = lay_nguyen_vong(ma_hs=du_lieu["ma_hoc_sinh"])
        kiem_tra("2.12 Thí sinh chuyên có NV chuyên", kq_nv["tim_thay"] and kq_nv["du_lieu"].get("nguyen_vong_chuyen") is not None)
    else:
        kiem_tra("2.12 Thí sinh chuyên có NV chuyên", False, "Không tìm thấy Phùng Minh Vũ")

    tong = so_pass + so_fail
    print(f"\n{'='*60}")
    print(f"  KẾT QUẢ: {so_pass}/{tong} PASS | {so_fail} FAIL")
    print(f"{'='*60}")


if __name__ == "__main__":
    kiem_thu()
