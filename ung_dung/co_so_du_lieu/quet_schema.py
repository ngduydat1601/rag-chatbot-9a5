"""
Tự động quét cấu trúc cơ sở dữ liệu (Schema Introspection) từ PostgreSQL.

Tác dụng:
  - Quét danh sách các bảng, cột, kiểu dữ liệu và chú thích (COMMENT) từ information_schema.
  - Quét các mối quan hệ khóa ngoại (Foreign Keys).
  - Tự động tạo văn bản mô tả schema để nạp vào prompt cho LLM.
  - Có cơ chế Cache trong RAM để không tốn thời gian truy vấn lại ở mỗi tin nhắn.
"""

import sys
from pathlib import Path
from typing import Optional
import psycopg2
from psycopg2.extras import RealDictCursor

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import CHUOI_KET_NOI_DB

# Biến lưu cache schema trong bộ nhớ
_SCHEMA_CACHE: Optional[str] = None

# Danh sách các bảng hệ thống hoặc bảng vector nội bộ cần bỏ qua
CAC_BANG_BO_QUA = {"tai_lieu_vector", "spatial_ref_sys"}


def _quet_cac_cot_tu_csdl() -> dict[str, list[dict]]:
    """Truy vấn information_schema để lấy bảng, cột, kiểu dữ liệu và mô tả."""
    conn = psycopg2.connect(CHUOI_KET_NOI_DB, cursor_factory=RealDictCursor, connect_timeout=5)
    cur = conn.cursor()
    try:
        sql = """
            SELECT 
                c.table_name,
                c.column_name,
                c.data_type,
                c.is_nullable,
                pgd.description
            FROM information_schema.columns c
            JOIN pg_catalog.pg_class pc ON pc.relname = c.table_name
            JOIN pg_catalog.pg_namespace pn ON pn.oid = pc.relnamespace AND pn.nspname = c.table_schema
            LEFT JOIN pg_catalog.pg_description pgd 
                ON pgd.objoid = pc.oid AND pgd.objsubid = c.ordinal_position
            WHERE c.table_schema = 'public'
            ORDER BY c.table_name, c.ordinal_position;
        """
        cur.execute(sql)
        hang_du_lieu = cur.fetchall()

        ket_qua: dict[str, list[dict]] = {}
        for r in hang_du_lieu:
            ten_bang = r["table_name"]
            if ten_bang in CAC_BANG_BO_QUA:
                continue

            if ten_bang not in ket_qua:
                ket_qua[ten_bang] = []

            ket_qua[ten_bang].append({
                "ten_cot": r["column_name"],
                "kieu_du_lieu": r["data_type"],
                "co_the_null": r["is_nullable"] == "YES",
                "mo_ta": r["description"] or "",
            })
        return ket_qua
    finally:
        cur.close()
        conn.close()


def _quet_khoa_ngoai_tu_csdl() -> list[dict]:
    """Truy vấn các ràng buộc khóa ngoại (Foreign Keys) giữa các bảng."""
    conn = psycopg2.connect(CHUOI_KET_NOI_DB, cursor_factory=RealDictCursor, connect_timeout=5)
    cur = conn.cursor()
    try:
        sql = """
            SELECT
                tc.table_name, 
                kcu.column_name, 
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name 
            FROM information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public';
        """
        cur.execute(sql)
        hang_du_lieu = cur.fetchall()

        danh_sach = []
        for r in hang_du_lieu:
            if r["table_name"] in CAC_BANG_BO_QUA or r["foreign_table_name"] in CAC_BANG_BO_QUA:
                continue
            danh_sach.append({
                "bang_goc": r["table_name"],
                "cot_goc": r["column_name"],
                "bang_dich": r["foreign_table_name"],
                "cot_dich": r["foreign_column_name"],
            })
        return danh_sach
    finally:
        cur.close()
        conn.close()


def lay_schema_csdl(lam_moi: bool = False) -> str:
    """
    Lấy chuỗi mô tả toàn bộ cấu trúc CSDL hiện tại.
    Có cache: chỉ đọc CSDL 1 lần duy nhất, các lần sau lấy từ RAM.
    
    Tham số:
      lam_moi (bool): Nếu True, bắt buộc đọc lại từ PostgreSQL.
    """
    global _SCHEMA_CACHE
    if _SCHEMA_CACHE is not None and not lam_moi:
        return _SCHEMA_CACHE

    danh_sach_bang = _quet_cac_cot_tu_csdl()
    danh_sach_khoa_ngoai = _quet_khoa_ngoai_tu_csdl()

    cac_dong = ["=== CẤU TRÚC CƠ SỞ DỮ LIỆU (Tự động cập nhật từ CSDL) ===\n"]

    for ten_bang, ds_cot in danh_sach_bang.items():
        cac_dong.append(f"Bảng `{ten_bang}`:")
        for cot in ds_cot:
            chuoi_cot = f"  - {cot['ten_cot']} ({cot['kieu_du_lieu']})"
            if cot["mo_ta"]:
                chuoi_cot += f": {cot['mo_ta']}"
            cac_dong.append(chuoi_cot)
        cac_dong.append("")

    if danh_sach_khoa_ngoai:
        cac_dong.append("Quan hệ khóa ngoại (Dùng để JOIN):")
        for kn in danh_sach_khoa_ngoai:
            cac_dong.append(
                f"  - {kn['bang_goc']}.{kn['cot_goc']} -> {kn['bang_dich']}.{kn['cot_dich']}"
            )
        cac_dong.append("")

    _SCHEMA_CACHE = "\n".join(cac_dong).strip()
    return _SCHEMA_CACHE


if __name__ == "__main__":
    print("Kiểm tra quét cấu trúc schema từ PostgreSQL:\n")
    schema = lay_schema_csdl(lam_moi=True)
    print(schema)
