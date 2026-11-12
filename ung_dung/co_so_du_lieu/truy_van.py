"""
Thực thi câu lệnh SQL do LLM sinh ra — CHỈ CHO PHÉP SELECT.

Cơ chế phòng thủ theo chiều sâu (Defense in Depth):
  Tầng 1 (Ứng dụng): Kiểm tra cú pháp trước khi gửi xuống DB
  Tầng 2 (Database) : Chạy trong transaction READ ONLY
"""

import re
import sys
from pathlib import Path
import psycopg2
from psycopg2 import pool
from psycopg2.extras import RealDictCursor

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import CHUOI_KET_NOI_DB

# Khởi tạo Connection Pool dùng chung để tái sử dụng kết nối PostgreSQL
_BO_KET_NOI_DB: pool.ThreadedConnectionPool | None = None


def lay_ket_noi_db():
    """Lấy kết nối từ Connection Pool (hoặc tạo mới nếu pool chưa khởi tạo)."""
    global _BO_KET_NOI_DB
    if _BO_KET_NOI_DB is None or _BO_KET_NOI_DB.closed:
        _BO_KET_NOI_DB = pool.ThreadedConnectionPool(
            minconn=1,
            maxconn=10,
            dsn=CHUOI_KET_NOI_DB,
            connect_timeout=5,
        )
    conn = _BO_KET_NOI_DB.getconn()
    # Kiểm tra kết nối còn sống không, nếu bị ngắt thì lấy kết nối mới
    if conn.closed != 0:
        _BO_KET_NOI_DB.putconn(conn, close=True)
        conn = _BO_KET_NOI_DB.getconn()
    return conn


def tra_ket_noi_db(conn) -> None:
    """Trả kết nối về lại Connection Pool."""
    global _BO_KET_NOI_DB
    if conn is not None and _BO_KET_NOI_DB is not None and not _BO_KET_NOI_DB.closed:
        try:
            _BO_KET_NOI_DB.putconn(conn)
        except Exception:
            conn.close()


# Danh sách từ khóa nguy hiểm — KHÔNG cho phép xuất hiện trong câu SQL
CAC_TU_KHOA_CAM = [
    "INSERT", "UPDATE", "DELETE", "DROP", "ALTER", "TRUNCATE",
    "CREATE", "GRANT", "REVOKE", "EXECUTE", "COPY",
    "SET ROLE", "SET SESSION",
]


class LoiSQLKhongAnToan(Exception):
    """Ngoại lệ khi phát hiện câu SQL không an toàn."""
    pass


def kiem_tra_an_toan(cau_sql: str) -> None:
    """
    Tầng 1: Kiểm tra câu SQL ở tầng ứng dụng trước khi gửi xuống DB.

    Quy tắc:
      - Phải bắt đầu bằng SELECT (sau khi loại bỏ khoảng trắng)
      - Không chứa dấu chấm phẩy (ngăn chặn chèn nhiều câu lệnh)
      - Không chứa bất kỳ từ khóa nguy hiểm nào
    """
    cau_sql_chuan = cau_sql.strip()

    # Kiểm tra bắt đầu bằng SELECT
    if not re.match(r"^\s*SELECT\b", cau_sql_chuan, re.IGNORECASE):
        raise LoiSQLKhongAnToan("Chỉ cho phép câu lệnh SELECT.")

    # Kiểm tra không có dấu chấm phẩy (ngăn injection nhiều câu lệnh)
    if ";" in cau_sql_chuan:
        raise LoiSQLKhongAnToan("Không cho phép dấu chấm phẩy trong câu SQL.")

    # Kiểm tra từ khóa nguy hiểm
    cau_sql_upper = cau_sql_chuan.upper()
    for tu_khoa in CAC_TU_KHOA_CAM:
        if re.search(rf"\b{tu_khoa}\b", cau_sql_upper):
            raise LoiSQLKhongAnToan(f"Phát hiện từ khóa bị cấm: {tu_khoa}")


def thuc_thi_sql(cau_sql: str) -> dict:
    """
    Thực thi câu SELECT do LLM sinh ra và trả về kết quả.

    Tham số:
      cau_sql: Câu lệnh SQL (chỉ SELECT)

    Trả về:
      {
        "thanh_cong": True/False,
        "cau_sql": "SELECT ...",
        "so_ban_ghi": 5,
        "du_lieu": [{"ho_ten": "...", ...}, ...],
        "ten_cot": ["ho_ten", "so_bao_danh", ...]
      }
    """
    # Tầng 1: Kiểm tra ở ứng dụng
    try:
        kiem_tra_an_toan(cau_sql)
    except LoiSQLKhongAnToan as loi:
        return {
            "thanh_cong": False,
            "cau_sql": cau_sql,
            "loi": f"SQL không an toàn: {str(loi)}",
        }

    # Tầng 2: Thực thi trong transaction READ ONLY (tái sử dụng kết nối từ Pool)
    conn = None
    try:
        conn = lay_ket_noi_db()
        conn.rollback()
        conn.set_session(readonly=True, autocommit=False)
        cur = conn.cursor(cursor_factory=RealDictCursor)

        cur.execute(cau_sql)
        rows = cur.fetchall()

        # Lấy tên các cột
        ten_cot = [desc[0] for desc in cur.description] if cur.description else []

        # Chuyển RealDictRow sang dict thuần
        du_lieu = [dict(r) for r in rows]
        cur.close()

        return {
            "thanh_cong": True,
            "cau_sql": cau_sql,
            "so_ban_ghi": len(du_lieu),
            "du_lieu": du_lieu,
            "ten_cot": ten_cot,
        }

    except psycopg2.Error as loi_db:
        return {
            "thanh_cong": False,
            "cau_sql": cau_sql,
            "loi": f"Lỗi PostgreSQL: {str(loi_db).strip()}",
        }
    finally:
        if conn:
            try:
                conn.rollback()
            except Exception:
                pass
            tra_ket_noi_db(conn)


if __name__ == "__main__":
    import json

    print("Kiểm tra 1: SELECT hợp lệ")
    kq1 = thuc_thi_sql("SELECT ho_ten, so_bao_danh FROM thi_sinh LIMIT 3")
    print(json.dumps(kq1, ensure_ascii=False, indent=2))

    print("\nKiểm tra 2: UPDATE (phải bị chặn)")
    kq2 = thuc_thi_sql("UPDATE thi_sinh SET ho_ten = 'Hack' WHERE id = 1")
    print(json.dumps(kq2, ensure_ascii=False, indent=2))

    print("\nKiểm tra 3: Dấu chấm phẩy (phải bị chặn)")
    kq3 = thuc_thi_sql("SELECT 1; DROP TABLE thi_sinh")
    print(json.dumps(kq3, ensure_ascii=False, indent=2))
