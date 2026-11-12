"""
Bước 1.4: Kiểm tra tính hợp lệ của dữ liệu đã trích xuất.

Kiểm tra bao gồm:
  - Định dạng chuỗi (độ dài mã học sinh, SBD)
  - Định dạng ngày tháng (ngày sinh, ngày thi)
  - Tính nhất quán logic (số NV = số phần tử trong danh sách NV)
  - Kiểm tra trùng lặp SBD hoặc mã học sinh giữa các bản ghi
"""

import json
import re
from pathlib import Path
from datetime import datetime

import sys
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import DUONG_DAN_TRICH_XUAT


# ──────────────────────────────────────────────
# Các hàm kiểm tra từng trường
# ──────────────────────────────────────────────

def kiem_tra_ma_hoc_sinh(ma: str) -> list[str]:
    """Kiểm tra mã học sinh phải là chuỗi số, dài 10-12 ký tự."""
    loi = []
    if not ma:
        loi.append("Mã học sinh bị trống")
    elif not re.match(r"^\d{10,12}$", ma):
        loi.append(f"Mã học sinh không hợp lệ: '{ma}' (cần 10-12 chữ số)")
    return loi


def kiem_tra_so_bao_danh(sbd: str) -> list[str]:
    """Kiểm tra SBD phải là chuỗi số, dài 6 ký tự."""
    loi = []
    if not sbd:
        loi.append("Số báo danh bị trống")
    elif not re.match(r"^\d{5,7}$", sbd):
        loi.append(f"Số báo danh không hợp lệ: '{sbd}' (cần 5-7 chữ số)")
    return loi


def kiem_tra_ngay_sinh(ngay: str) -> list[str]:
    """Kiểm tra ngày sinh đúng định dạng dd/mm/yyyy và hợp lệ."""
    loi = []
    if not ngay:
        loi.append("Ngày sinh bị trống")
        return loi
    try:
        ngay_parsed = datetime.strptime(ngay, "%d/%m/%Y")
        # Thí sinh thi vào lớp 10 năm 2026 thường sinh năm 2010-2012
        if ngay_parsed.year < 2009 or ngay_parsed.year > 2013:
            loi.append(f"Năm sinh bất thường: {ngay_parsed.year} (kỳ vọng 2010-2012)")
    except ValueError:
        loi.append(f"Ngày sinh sai định dạng: '{ngay}' (cần dd/mm/yyyy)")
    return loi


def kiem_tra_nguyen_vong(du_lieu: dict) -> list[str]:
    """Kiểm tra tính nhất quán giữa số lượng và danh sách nguyện vọng."""
    loi = []
    so_luong = du_lieu.get("so_luong_nguyen_vong", 0)
    danh_sach = du_lieu.get("danh_sach_nguyen_vong", [])

    if len(danh_sach) != so_luong:
        loi.append(
            f"Số nguyện vọng không khớp: khai báo {so_luong}, "
            f"thực tế có {len(danh_sach)} mục"
        )

    # Kiểm tra thứ tự NV liên tục (1, 2, 3)
    thu_tu_thuc_te = [nv.get("thu_tu", 0) for nv in danh_sach]
    thu_tu_ky_vong = list(range(1, so_luong + 1))
    if sorted(thu_tu_thuc_te) != thu_tu_ky_vong:
        loi.append(f"Thứ tự nguyện vọng không liên tục: {thu_tu_thuc_te}")

    return loi


def kiem_tra_lich_thi(lich: list[dict]) -> list[str]:
    """Kiểm tra lịch thi phải có đủ 3 môn chuẩn."""
    loi = []
    cac_mon_can_co = {"Ngữ văn", "Ngoại ngữ", "Toán"}
    cac_mon_thuc_te = {mon.get("ten_mon", "") for mon in lich}

    mon_thieu = cac_mon_can_co - cac_mon_thuc_te
    if mon_thieu:
        loi.append(f"Thiếu môn thi: {mon_thieu}")

    return loi


def kiem_tra_mot_ban_ghi(du_lieu: dict) -> dict:
    """
    Kiểm tra toàn diện một bản ghi thí sinh.

    Returns:
        Dictionary chứa kết quả kiểm tra:
        {
            "hop_le": True/False,
            "so_loi": int,
            "so_canh_bao": int,
            "chi_tiet": [...]
        }
    """
    tat_ca_loi = []
    tat_ca_canh_bao = []

    # --- Kiểm tra các trường bắt buộc ---
    cac_truong_bat_buoc = [
        "ho_ten", "ngay_sinh", "gioi_tinh", "ma_hoc_sinh",
        "so_bao_danh", "phong_thi", "diem_thi"
    ]
    for truong in cac_truong_bat_buoc:
        if not du_lieu.get(truong):
            tat_ca_loi.append(f"Trường '{truong}' bị trống hoặc thiếu")

    # --- Kiểm tra định dạng cụ thể ---
    tat_ca_loi.extend(kiem_tra_ma_hoc_sinh(du_lieu.get("ma_hoc_sinh", "")))
    tat_ca_loi.extend(kiem_tra_so_bao_danh(du_lieu.get("so_bao_danh", "")))
    tat_ca_loi.extend(kiem_tra_ngay_sinh(du_lieu.get("ngay_sinh", "")))
    tat_ca_loi.extend(kiem_tra_nguyen_vong(du_lieu))
    tat_ca_loi.extend(kiem_tra_lich_thi(du_lieu.get("lich_thi", [])))

    # --- Cảnh báo (không phải lỗi, nhưng cần kiểm tra) ---
    if du_lieu.get("diem_uu_tien", 0) > 0:
        tat_ca_canh_bao.append(
            f"Điểm ưu tiên = {du_lieu['diem_uu_tien']} (cần đối chiếu phiếu gốc)"
        )

    if du_lieu.get("tuyen_sinh_chuyen") is not None:
        tat_ca_canh_bao.append("Có phần thi chuyên — cần kiểm tra kỹ thông tin chuyên")

    return {
        "ho_ten": du_lieu.get("ho_ten", "N/A"),
        "so_trang": du_lieu.get("so_trang_nguon", "N/A"),
        "hop_le": len(tat_ca_loi) == 0,
        "so_loi": len(tat_ca_loi),
        "so_canh_bao": len(tat_ca_canh_bao),
        "danh_sach_loi": tat_ca_loi,
        "danh_sach_canh_bao": tat_ca_canh_bao,
    }


def kiem_tra_trung_lap(danh_sach_du_lieu: list[dict]) -> list[str]:
    """Kiểm tra trùng lặp SBD hoặc mã học sinh giữa các bản ghi."""
    loi = []

    # Kiểm tra trùng SBD
    tat_ca_sbd = {}
    for dl in danh_sach_du_lieu:
        sbd = dl.get("so_bao_danh", "")
        if sbd in tat_ca_sbd:
            loi.append(
                f"Trùng SBD '{sbd}': trang {tat_ca_sbd[sbd]} và trang {dl.get('so_trang_nguon')}"
            )
        tat_ca_sbd[sbd] = dl.get("so_trang_nguon")

    # Kiểm tra trùng mã học sinh
    tat_ca_ma = {}
    for dl in danh_sach_du_lieu:
        ma = dl.get("ma_hoc_sinh", "")
        if ma in tat_ca_ma:
            loi.append(
                f"Trùng mã HS '{ma}': trang {tat_ca_ma[ma]} và trang {dl.get('so_trang_nguon')}"
            )
        tat_ca_ma[ma] = dl.get("so_trang_nguon")

    return loi


def kiem_tra_tat_ca(
    thu_muc_trich_xuat: Path = DUONG_DAN_TRICH_XUAT,
) -> dict:
    """
    Kiểm tra toàn bộ các file JSON đã trích xuất.

    Returns:
        Báo cáo tổng hợp kiểm tra.
    """
    danh_sach_file = sorted(thu_muc_trich_xuat.glob("thi_sinh_trang_*.json"))
    if not danh_sach_file:
        print(f"[LỖI] Không tìm thấy file nào trong: {thu_muc_trich_xuat}")
        return {}

    print(f"[4/5] Đang kiểm tra {len(danh_sach_file)} bản ghi...")

    tat_ca_du_lieu = []
    tat_ca_ket_qua = []
    tong_loi = 0
    tong_canh_bao = 0

    for duong_dan_file in danh_sach_file:
        with open(duong_dan_file, "r", encoding="utf-8") as f:
            du_lieu = json.load(f)

        tat_ca_du_lieu.append(du_lieu)
        ket_qua = kiem_tra_mot_ban_ghi(du_lieu)
        tat_ca_ket_qua.append(ket_qua)

        trang_thai = "✓" if ket_qua["hop_le"] else "✗"
        print(
            f"       Trang {ket_qua['so_trang']:>3}: {trang_thai} "
            f"{ket_qua['ho_ten']:<25} "
            f"Lỗi: {ket_qua['so_loi']}, Cảnh báo: {ket_qua['so_canh_bao']}"
        )

        if ket_qua["danh_sach_loi"]:
            for loi in ket_qua["danh_sach_loi"]:
                print(f"              ✗ {loi}")

        if ket_qua["danh_sach_canh_bao"]:
            for cb in ket_qua["danh_sach_canh_bao"]:
                print(f"              ⚠ {cb}")

        tong_loi += ket_qua["so_loi"]
        tong_canh_bao += ket_qua["so_canh_bao"]

    # Kiểm tra trùng lặp xuyên bản ghi
    loi_trung_lap = kiem_tra_trung_lap(tat_ca_du_lieu)
    if loi_trung_lap:
        print("\n       === LỖI TRÙNG LẶP ===")
        for loi in loi_trung_lap:
            print(f"       ✗ {loi}")
        tong_loi += len(loi_trung_lap)

    # Tổng kết
    so_hop_le = sum(1 for kq in tat_ca_ket_qua if kq["hop_le"])
    bao_cao = {
        "tong_ban_ghi": len(tat_ca_ket_qua),
        "so_hop_le": so_hop_le,
        "so_co_loi": len(tat_ca_ket_qua) - so_hop_le,
        "tong_loi": tong_loi,
        "tong_canh_bao": tong_canh_bao,
        "loi_trung_lap": loi_trung_lap,
        "chi_tiet": tat_ca_ket_qua,
    }

    print(f"\n       === TỔNG KẾT ===")
    print(f"       Tổng bản ghi : {bao_cao['tong_ban_ghi']}")
    print(f"       Hợp lệ       : {bao_cao['so_hop_le']}")
    print(f"       Có lỗi        : {bao_cao['so_co_loi']}")
    print(f"       Tổng lỗi      : {bao_cao['tong_loi']}")
    print(f"       Tổng cảnh báo : {bao_cao['tong_canh_bao']}")

    # Lưu báo cáo
    duong_dan_bao_cao = thu_muc_trich_xuat / "bao_cao_kiem_tra.json"
    with open(duong_dan_bao_cao, "w", encoding="utf-8") as f:
        json.dump(bao_cao, f, ensure_ascii=False, indent=2)
    print(f"       Báo cáo đã lưu: {duong_dan_bao_cao}")

    return bao_cao


# ──────────────────────────────────────────────
# Chạy độc lập
# ──────────────────────────────────────────────
if __name__ == "__main__":
    kiem_tra_tat_ca()