"""
Bước 1.6: Công cụ hỗ trợ kiểm duyệt thủ công.

Hiển thị từng bản ghi đã trích xuất, cho phép người kiểm duyệt:
  - Xác nhận (verified) → copy sang du_lieu/da_kiem_duyet/
  - Sửa trường sai → cập nhật và xác nhận
  - Bỏ qua → giữ trạng thái pending

Quy trình:
  pending → [đối chiếu ảnh PDF gốc] → verified → sẵn sàng nạp DB

Sử dụng:
  python -m ung_dung.nhap_lieu.kiem_duyet
"""

import json
import shutil
from pathlib import Path

import sys
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import DUONG_DAN_TRICH_XUAT, DUONG_DAN_KIEM_DUYET


# Các trường quan trọng cần hiển thị khi kiểm duyệt
CAC_TRUONG_HIEN_THI = [
    ("ho_ten", "Họ tên"),
    ("ngay_sinh", "Ngày sinh"),
    ("gioi_tinh", "Giới tính"),
    ("dan_toc", "Dân tộc"),
    ("noi_sinh", "Nơi sinh"),
    ("ma_hoc_sinh", "Mã học sinh"),
    ("lop", "Lớp"),
    ("so_bao_danh", "Số báo danh"),
    ("phong_thi", "Phòng thi"),
    ("diem_thi", "Điểm thi"),
    ("dia_chi_diem_thi", "Địa chỉ điểm thi"),
    ("diem_uu_tien", "Điểm ưu tiên"),
    ("diem_khuyen_khich", "Điểm khuyến khích"),
]


def hien_thi_ban_ghi(du_lieu: dict, so_thu_tu: int, tong: int):
    """Hiển thị thông tin một bản ghi để kiểm duyệt."""
    print(f"\n{'='*60}")
    print(f"  BẢN GHI {so_thu_tu}/{tong} — Trang {du_lieu.get('so_trang_nguon', '?')}")
    print(f"{'='*60}")

    for khoa, nhan in CAC_TRUONG_HIEN_THI:
        gia_tri = du_lieu.get(khoa, "N/A")
        print(f"  {nhan:<20}: {gia_tri}")

    # Hiển thị nguyện vọng
    print(f"\n  {'Nguyện vọng':<20}:")
    for nv in du_lieu.get("danh_sach_nguyen_vong", []):
        print(f"    NV{nv['thu_tu']}: {nv['ten_truong']}")

    # Hiển thị lịch thi
    print(f"\n  {'Lịch thi':<20}:")
    for mon in du_lieu.get("lich_thi", []):
        print(f"    {mon['ten_mon']}: {mon['buoi_thi']} {mon['ngay_thi']}")

    # Hiển thị thi chuyên nếu có
        # Hiển thị thi chuyên nếu có
    thi_chuyen = du_lieu.get("tuyen_sinh_chuyen")
    if thi_chuyen:
        print(f"\n  {'Thi chuyên':<20}: Có")
        # Kiểm tra nếu là dạng danh sách mới
        ds_nv_chuyen = thi_chuyen.get("danh_sach_nguyen_vong_chuyen", [])
        if ds_nv_chuyen:
            for nvc in ds_nv_chuyen:
                print(f"    NV Chuyên {nvc.get('thu_tu')}: {nvc.get('truong_chuyen')} - Lớp: {nvc.get('lop_chuyen')}")
        else:
            print(f"    Trường: {thi_chuyen.get('truong_chuyen', 'N/A')}")
            print(f"    Lớp: {thi_chuyen.get('lop_chuyen', 'N/A')}")
            
        print(f"    Môn thi: {thi_chuyen.get('mon_thi_chuyen', 'N/A')} - Buổi thi: {thi_chuyen.get('ngay_thi_chuyen', 'N/A')}")
        print(f"    Điểm thi: {thi_chuyen.get('diem_thi_chuyen', 'N/A')} - Phòng: {thi_chuyen.get('phong_thi_chuyen', 'N/A')}")
    else:
        print(f"\n  {'Thi chuyên':<20}: Không")

    print(f"{'─'*60}")


def kiem_duyet_tuong_tac(
    thu_muc_trich_xuat: Path = DUONG_DAN_TRICH_XUAT,
    thu_muc_kiem_duyet: Path = DUONG_DAN_KIEM_DUYET,
):
    """
    Quy trình kiểm duyệt tương tác từng bản ghi.

    Người kiểm duyệt mở ảnh PDF gốc để đối chiếu, sau đó:
      - Nhấn Enter hoặc 'y' → xác nhận (verified)
      - Nhấn 's' → bỏ qua (giữ pending)
      - Nhấn 'q' → thoát, lưu tiến trình
    """
    thu_muc_kiem_duyet.mkdir(parents=True, exist_ok=True)

    danh_sach_file = sorted(thu_muc_trich_xuat.glob("thi_sinh_trang_*.json"))
    if not danh_sach_file:
        print("[LỖI] Không tìm thấy bản ghi nào để kiểm duyệt.")
        return

    # Lọc ra các bản ghi chưa được kiểm duyệt
    danh_sach_chua_duyet = []
    for duong_dan in danh_sach_file:
        # Kiểm tra xem đã có trong thư mục kiểm duyệt chưa
        file_da_duyet = thu_muc_kiem_duyet / duong_dan.name
        if not file_da_duyet.exists():
            danh_sach_chua_duyet.append(duong_dan)

    if not danh_sach_chua_duyet:
        print("✓ Tất cả bản ghi đã được kiểm duyệt!")
        return

    print(f"\n  Cần kiểm duyệt: {len(danh_sach_chua_duyet)} bản ghi")
    print(f"  Đã kiểm duyệt:  {len(danh_sach_file) - len(danh_sach_chua_duyet)}")
    print(f"\n  Hướng dẫn:")
    print(f"    Enter hoặc 'y' → Xác nhận (verified)")
    print(f"    's'             → Bỏ qua")
    print(f"    'q'             → Thoát\n")

    dem_xac_nhan = 0
    for chi_so, duong_dan_file in enumerate(danh_sach_chua_duyet, start=1):
        with open(duong_dan_file, "r", encoding="utf-8") as f:
            du_lieu = json.load(f)

        hien_thi_ban_ghi(du_lieu, chi_so, len(danh_sach_chua_duyet))

        print(f"  → Mở ảnh trang {du_lieu.get('so_trang_nguon')} để đối chiếu.")
        lua_chon = input("  Xác nhận? [Y/s/q]: ").strip().lower()

        if lua_chon in ("", "y", "yes"):
            # Đánh dấu verified và copy sang thư mục kiểm duyệt
            du_lieu["trang_thai_kiem_duyet"] = "verified"
            file_dich = thu_muc_kiem_duyet / duong_dan_file.name
            with open(file_dich, "w", encoding="utf-8") as f:
                json.dump(du_lieu, f, ensure_ascii=False, indent=2)
            dem_xac_nhan += 1
            print(f"  ✓ Đã xác nhận: {du_lieu['ho_ten']}")

        elif lua_chon == "s":
            print(f"  → Bỏ qua: {du_lieu['ho_ten']}")
            continue

        elif lua_chon == "q":
            print(f"\n  Đã thoát. Xác nhận được {dem_xac_nhan} bản ghi.")
            break

    print(f"\n  === TỔNG KẾT KIỂM DUYỆT ===")
    so_da_duyet = len(list(thu_muc_kiem_duyet.glob("thi_sinh_trang_*.json")))
    print(f"  Đã xác nhận phiên này: {dem_xac_nhan}")
    print(f"  Tổng đã kiểm duyệt:   {so_da_duyet}/{len(danh_sach_file)}")

    if so_da_duyet == len(danh_sach_file):
        print(f"\n  ✓ TẤT CẢ {so_da_duyet} bản ghi đã được kiểm duyệt!")
        print(f"  → Sẵn sàng chuyển sang Giai đoạn 2 (nạp PostgreSQL)")


def gop_thanh_file_cuoi(
    thu_muc_kiem_duyet: Path = DUONG_DAN_KIEM_DUYET,
) -> Path:
    """
    Gộp tất cả bản ghi đã kiểm duyệt thành 1 file candidates.json.

    Returns:
        Đường dẫn file candidates.json
    """
    danh_sach_file = sorted(thu_muc_kiem_duyet.glob("thi_sinh_trang_*.json"))

    tat_ca_ban_ghi = []
    for duong_dan in danh_sach_file:
        with open(duong_dan, "r", encoding="utf-8") as f:
            du_lieu = json.load(f)
            if du_lieu.get("trang_thai_kiem_duyet") == "verified":
                tat_ca_ban_ghi.append(du_lieu)

    duong_dan_ket_qua = thu_muc_kiem_duyet / "candidates.json"
    with open(duong_dan_ket_qua, "w", encoding="utf-8") as f:
        json.dump(tat_ca_ban_ghi, f, ensure_ascii=False, indent=2)

    print(f"[5/5] Đã gộp {len(tat_ca_ban_ghi)} bản ghi → {duong_dan_ket_qua}")
    return duong_dan_ket_qua


# ──────────────────────────────────────────────
# Chạy độc lập
# ──────────────────────────────────────────────
if __name__ == "__main__":
    kiem_duyet_tuong_tac()