"""
Bước 3.5: Hybrid Retriever — Kết hợp SQL + Vector.

Phân loại câu hỏi tự động:
  - Có chứa SBD, mã HS, tên người → gọi SQL Retriever
  - Hỏi về nội dung phiếu, quy định → gọi Vector Retriever
  - Không rõ → gọi cả hai

Sử dụng:
  python -m ung_dung.tim_kiem.tim_kiem_tong_hop
"""

import re
import sys
from pathlib import Path

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from ung_dung.co_so_du_lieu.truy_van import (
    tim_thi_sinh_theo_ten,
    tim_thi_sinh_theo_sbd,
    tim_thi_sinh_theo_ma,
    lay_lich_thi,
    lay_nguyen_vong,
    dem_thi_sinh_theo_diem_thi,
)
from ung_dung.tim_kiem.tim_kiem_vector import tim_kiem_vector


# ──────────────────────────────────────────────
# Hàm phân loại câu hỏi (Rule-based đơn giản)
# ──────────────────────────────────────────────
def phan_loai_cau_hoi(cau_hoi: str) -> str:
    """
    Phân loại câu hỏi thành 1 trong 3 loại:
      - "sql"    : Tra cứu thông tin cá nhân thí sinh
      - "vector" : Hỏi về nội dung/cấu trúc phiếu
      - "hybrid" : Không rõ → gọi cả hai

    Lưu ý: Đây là phân loại đơn giản bằng luật (rule-based).
    Ở Giai đoạn 4, AI (Gemini) sẽ tự phân loại chính xác hơn.
    """
    cau_hoi_lower = cau_hoi.lower()

    # Pattern 1: Có số báo danh (6 chữ số)
    if re.search(r'\b\d{6}\b', cau_hoi):
        return "sql"

    # Pattern 2: Có mã học sinh (10 chữ số)
    if re.search(r'\b\d{10}\b', cau_hoi):
        return "sql"

    # Pattern 3: Kiểm tra từ khóa SQL và Vector
    tu_khoa_sql = [
        "số báo danh", "sbd", "phòng thi", "mã học sinh",
        "thi ở đâu", "tên gì", "ai thi", "điểm thi của",
        "bao nhiêu người", "bao nhiêu thí sinh", "đếm",
        "nguyện vọng của", "nv1", "nv2", "nv3",
        "lịch thi của", "thi môn gì", "thi ngày nào",
    ]
    tu_khoa_vector = [
        "phiếu báo thi", "nội dung", "cấu trúc", "gồm những gì",
        "có những mục", "quy định", "hướng dẫn", "lưu ý",
        "điểm ưu tiên là gì", "điểm khuyến khích là gì",
        "thi chuyên là gì", "nguyện vọng là gì",
        "mấy giờ", "bao giờ", "lúc mấy giờ",
        "phần tuyển sinh", "giải thích",
    ]

    co_sql = any(tk in cau_hoi_lower for tk in tu_khoa_sql)
    co_vector = any(tk in cau_hoi_lower for tk in tu_khoa_vector)

    if co_sql and co_vector:
        return "hybrid"
    if co_sql:
        return "sql"
    if co_vector:
        return "vector"

    # Mặc định: hybrid (gọi cả hai)
    return "hybrid"


# ──────────────────────────────────────────────
# Hàm trích xuất thông tin từ câu hỏi
# ──────────────────────────────────────────────
def trich_xuat_thong_tin(cau_hoi: str) -> dict:
    """Trích xuất SBD, mã HS hoặc tên người từ câu hỏi."""
    thong_tin = {"loai": None, "gia_tri": None}

    # Tìm SBD (6 chữ số)
    sbd = re.search(r'\b(\d{6})\b', cau_hoi)
    if sbd:
        thong_tin["loai"] = "sbd"
        thong_tin["gia_tri"] = sbd.group(1)
        return thong_tin

    # Tìm mã HS (10 chữ số)
    ma_hs = re.search(r'\b(\d{10})\b', cau_hoi)
    if ma_hs:
        thong_tin["loai"] = "ma_hs"
        thong_tin["gia_tri"] = ma_hs.group(1)
        return thong_tin

    # Tìm tên người: lọc các từ viết hoa chữ cái đầu (bỏ qua các từ khóa câu hỏi)
    tu_bo_qua = {
        "số", "báo", "danh", "sbd", "phòng", "thi", "của", "cho",
        "mã", "học", "sinh", "tên", "ai", "ở", "đâu", "gì", "là", "bao", "nhiêu",
        "lịch", "nguyện", "vọng", "hỏi", "xem", "tìm"
    }
    cac_tu = re.sub(r'[?.,!;:"]', '', cau_hoi).split()
    tu_viet_hoa = [w for w in cac_tu if w and w[0].isupper() and w.lower() not in tu_bo_qua]
    if len(tu_viet_hoa) >= 2:
        thong_tin["loai"] = "ten"
        thong_tin["gia_tri"] = " ".join(tu_viet_hoa)
        return thong_tin

    # Thử lấy tên từ chữ thường (ví dụ: "linh an")
    bo_tu = [
        "số", "báo", "danh", "sbd", "phòng", "thi", "của", "cho",
        "mã", "học", "sinh", "tên", "ai", "ở", "đâu", "gì",
        "nguyện", "vọng", "lịch", "môn", "ngày", "điểm",
        "bao", "nhiêu", "người", "thí", "đếm", "trường",
    ]
    cac_tu = cau_hoi.lower().split()
    tu_con_lai = [t for t in cac_tu if t not in bo_tu and len(t) > 1]
    if len(tu_con_lai) >= 2:
        thong_tin["loai"] = "ten"
        thong_tin["gia_tri"] = " ".join(tu_con_lai)

    return thong_tin


# ──────────────────────────────────────────────
# Hàm chính: Hybrid Retriever
# ──────────────────────────────────────────────
def tim_kiem(cau_hoi: str) -> dict:
    """
    Hàm tìm kiếm tổng hợp — tự động chọn SQL hoặc Vector.

    Trả về:
      {
        "cau_hoi": "...",
        "phuong_phap": "sql" | "vector" | "hybrid",
        "ket_qua_sql": {...} | None,
        "ket_qua_vector": {...} | None,
      }
    """
    loai = phan_loai_cau_hoi(cau_hoi)

    ket_qua = {
        "cau_hoi": cau_hoi,
        "phuong_phap": loai,
        "ket_qua_sql": None,
        "ket_qua_vector": None,
    }

    # SQL Retriever
    if loai in ("sql", "hybrid"):
        thong_tin = trich_xuat_thong_tin(cau_hoi)
        cau_hoi_lower = cau_hoi.lower()

        if thong_tin["loai"] == "sbd":
            if "lịch" in cau_hoi_lower or "môn" in cau_hoi_lower or "ngày" in cau_hoi_lower:
                ket_qua["ket_qua_sql"] = lay_lich_thi(sbd=thong_tin["gia_tri"])
            elif "nguyện vọng" in cau_hoi_lower or "nv" in cau_hoi_lower:
                ket_qua["ket_qua_sql"] = lay_nguyen_vong(sbd=thong_tin["gia_tri"])
            else:
                ket_qua["ket_qua_sql"] = tim_thi_sinh_theo_sbd(thong_tin["gia_tri"])

        elif thong_tin["loai"] == "ma_hs":
            ket_qua["ket_qua_sql"] = tim_thi_sinh_theo_ma(thong_tin["gia_tri"])

        elif thong_tin["loai"] == "ten":
            if "lịch" in cau_hoi_lower or "môn" in cau_hoi_lower:
                kq_ten = tim_thi_sinh_theo_ten(thong_tin["gia_tri"])
                if kq_ten["tim_thay"]:
                    du_lieu = kq_ten["du_lieu"] if isinstance(kq_ten["du_lieu"], dict) else kq_ten["du_lieu"][0]
                    ket_qua["ket_qua_sql"] = lay_lich_thi(sbd=du_lieu["so_bao_danh"])
            elif "nguyện vọng" in cau_hoi_lower or "nv" in cau_hoi_lower:
                kq_ten = tim_thi_sinh_theo_ten(thong_tin["gia_tri"])
                if kq_ten["tim_thay"]:
                    du_lieu = kq_ten["du_lieu"] if isinstance(kq_ten["du_lieu"], dict) else kq_ten["du_lieu"][0]
                    ket_qua["ket_qua_sql"] = lay_nguyen_vong(sbd=du_lieu["so_bao_danh"])
            elif any(k in cau_hoi_lower for k in ["bao nhiêu người", "bao nhiêu thí sinh", "bao nhiêu bạn", "đếm"]):
                ket_qua["ket_qua_sql"] = dem_thi_sinh_theo_diem_thi(thong_tin["gia_tri"])
            else:
                ket_qua["ket_qua_sql"] = tim_thi_sinh_theo_ten(thong_tin["gia_tri"])

    # Vector Retriever
    if loai in ("vector", "hybrid"):
        ket_qua["ket_qua_vector"] = tim_kiem_vector(cau_hoi, so_ket_qua=2)

    return ket_qua


if __name__ == "__main__":
    import json

    cac_cau_hoi = [
        # SQL
        "Số báo danh của Đặng Linh An là bao nhiêu?",
        "Phòng thi của SBD 204001?",
        "Nguyện vọng của Linh An?",
        # Vector
        "Phiếu báo thi có những mục gì?",
        "Bao giờ phải có mặt để làm thủ tục?",
        # Hybrid
        "Linh An thi ở đâu vào lúc mấy giờ?",
    ]

    for cau in cac_cau_hoi:
        kq = tim_kiem(cau)
        print(f"\n{'═'*60}")
        print(f"  CÂU HỎI : {cau}")
        print(f"  PHƯƠNG PHÁP: {kq['phuong_phap'].upper()}")
        print(f"{'═'*60}")
        if kq["ket_qua_sql"]:
            print(f"  📋 SQL: {json.dumps(kq['ket_qua_sql'], ensure_ascii=False)[:200]}...")
        if kq["ket_qua_vector"]:
            for r in kq["ket_qua_vector"].get("ket_qua", []):
                print(f"  📚 Vector [{r['do_tuong_dong']:.2%}]: {r['tieu_de']}")