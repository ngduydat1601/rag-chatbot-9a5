"""
Bước 1.5: Pipeline tổng hợp toàn bộ quá trình nhập liệu.

Điều phối tuần tự:
  1. Chuyển PDF thành ảnh
  2. OCR từng trang
  3. Gemini trích xuất JSON
  4. Kiểm tra dữ liệu
  5. Tổng hợp báo cáo

Sử dụng:
  python -m ung_dung.nhap_lieu.quy_trinh
    hoặc
  python -m ung_dung.nhap_lieu.quy_trinh --buoc 3
    (chỉ chạy từ bước 3 trở đi, dùng khi bước 1-2 đã chạy xong)
"""

import argparse
import time
from pathlib import Path

import sys
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from ung_dung.nhap_lieu.tai_pdf import chuyen_pdf_thanh_anh
from ung_dung.nhap_lieu.nhan_dang_chu import ocr_tat_ca_trang
from ung_dung.nhap_lieu.trich_xuat_gemini import trich_xuat_tat_ca
from ung_dung.nhap_lieu.kiem_tra import kiem_tra_tat_ca


def chay_pipeline(buoc_bat_dau: int = 1):
    """
    Chạy toàn bộ pipeline nhập liệu theo thứ tự.

    Args:
        buoc_bat_dau: Bước bắt đầu (1-4). Hữu ích khi muốn chạy lại
                      từ một bước cụ thể sau khi sửa lỗi.
    """
    thoi_gian_bat_dau = time.time()

    print("=" * 60)
    print("  PIPELINE NHẬP LIỆU - PHIẾU BÁO THI VÀO LỚP 10")
    print("=" * 60)
    print()

    # ──────────── Bước 1: PDF → Ảnh ────────────
    if buoc_bat_dau <= 1:
        chuyen_pdf_thanh_anh()
        print()

    # ──────────── Bước 2: Ảnh → OCR ────────────
    if buoc_bat_dau <= 2:
        ocr_tat_ca_trang()
        print()

    # ──────────── Bước 3: OCR + Ảnh → Gemini → JSON ────────────
    if buoc_bat_dau <= 3:
        trich_xuat_tat_ca()
        print()

    # ──────────── Bước 4: Kiểm tra dữ liệu ────────────
    if buoc_bat_dau <= 4:
        bao_cao = kiem_tra_tat_ca()
        print()

    # ──────────── Tổng kết ────────────
    thoi_gian_ket_thuc = time.time()
    thoi_gian_chay = thoi_gian_ket_thuc - thoi_gian_bat_dau

    print("=" * 60)
    print(f"  HOÀN TẤT - Thời gian: {thoi_gian_chay:.1f} giây")
    print("=" * 60)
    print()
    print("  Bước tiếp theo:")
    print("  → Kiểm duyệt thủ công các bản ghi trong du_lieu/da_trich_xuat/")
    print("  → Sau khi xác minh, copy sang du_lieu/da_kiem_duyet/")
    print("  → Rồi chạy Giai đoạn 2 để nạp vào PostgreSQL")


# ──────────────────────────────────────────────
# Điểm khởi chạy
# ──────────────────────────────────────────────
if __name__ == "__main__":
    bo_phan_tich = argparse.ArgumentParser(
        description="Pipeline nhập liệu phiếu báo thi"
    )
    bo_phan_tich.add_argument(
        "--buoc",
        type=int,
        default=1,
        choices=[1, 2, 3, 4],
        help="Bước bắt đầu (1=PDF→ảnh, 2=OCR, 3=Gemini, 4=Kiểm tra)",
    )
    tham_so = bo_phan_tich.parse_args()

    chay_pipeline(buoc_bat_dau=tham_so.buoc)