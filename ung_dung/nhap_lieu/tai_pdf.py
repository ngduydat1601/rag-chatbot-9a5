"""
Bước 1.1: Chuyển từng trang PDF scan thành file ảnh PNG.

Mỗi trang tương ứng với 1 phiếu báo thi của 1 thí sinh.
Ảnh được lưu với tên: trang_001.png, trang_002.png, ...
"""

from pathlib import Path
from pdf2image import convert_from_path

import sys
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import (
    DUONG_DAN_PDF,
    DUONG_DAN_ANH,
    DO_PHAN_GIAI_ANH,
    POPPLER_PATH,
)


def chuyen_pdf_thanh_anh(
    duong_dan_pdf: Path = DUONG_DAN_PDF,
    thu_muc_luu: Path = DUONG_DAN_ANH,
    dpi: int = DO_PHAN_GIAI_ANH,
) -> list[Path]:
    """
    Chuyển toàn bộ trang PDF thành các file ảnh PNG.

    Args:
        duong_dan_pdf: Đường dẫn file PDF gốc.
        thu_muc_luu: Thư mục lưu ảnh đầu ra.
        dpi: Độ phân giải ảnh (mặc định 300 DPI).

    Returns:
        Danh sách đường dẫn các file ảnh đã tạo.
    """
    # Tạo thư mục lưu nếu chưa có
    thu_muc_luu.mkdir(parents=True, exist_ok=True)

    print(f"[1/5] Đang chuyển PDF thành ảnh: {duong_dan_pdf}")
    print(f"       Độ phân giải: {dpi} DPI")

    # Cấu hình tham số cho pdf2image
    tham_so = {
        "pdf_path": str(duong_dan_pdf),
        "dpi": dpi,
        "fmt": "png",
    }
    # Trên Windows cần chỉ rõ đường dẫn Poppler
    if POPPLER_PATH:
        tham_so["poppler_path"] = POPPLER_PATH

    # Chuyển đổi
    danh_sach_anh = convert_from_path(**tham_so)

    # Lưu từng trang thành file riêng
    danh_sach_duong_dan = []
    for chi_so, anh in enumerate(danh_sach_anh, start=1):
        ten_file = f"trang_{chi_so:03d}.png"
        duong_dan_file = thu_muc_luu / ten_file
        anh.save(str(duong_dan_file), "PNG")
        danh_sach_duong_dan.append(duong_dan_file)

    print(f"       ✓ Đã tạo {len(danh_sach_duong_dan)} ảnh tại: {thu_muc_luu}")
    return danh_sach_duong_dan


# ──────────────────────────────────────────────
# Chạy độc lập để kiểm tra
# ──────────────────────────────────────────────
if __name__ == "__main__":
    ket_qua = chuyen_pdf_thanh_anh()
    print(f"\nTổng số trang: {len(ket_qua)}")
    for duong_dan in ket_qua[:3]:
        print(f"  - {duong_dan}")
    print("  ...")