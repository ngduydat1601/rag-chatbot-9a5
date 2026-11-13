"""
Script tự động nạp dữ liệu (Extension + Tables + Vector) từ file dulieu_backup.sql lên Render PostgreSQL.
Sử dụng:
    python nap_du_lieu_render.py "<EXTERNAL_DATABASE_URL>"
"""

import sys
from pathlib import Path
import psycopg2

if len(sys.argv) < 2:
    print("❌ LỖI: Vui lòng truyền External Database URL của Render!")
    print('👉 Ví dụ: python nap_du_lieu_render.py "postgresql://user:pass@dpg-xxxx.singapore-postgres.render.com/rag_thi_tuyen_sinh"')
    sys.exit(1)

url_render = sys.argv[1].strip().strip('"').strip("'")
file_sql = Path(__file__).resolve().parent / "dulieu_backup_clean.sql"
if not file_sql.exists():
    file_sql = Path(__file__).resolve().parent / "dulieu_backup.sql"

if not file_sql.exists():
    print(f"❌ Không tìm thấy file {file_sql}")
    sys.exit(1)

print(f"🔗 Đang kết nối tới Render Database...")
try:
    conn = psycopg2.connect(url_render, connect_timeout=15)
    conn.autocommit = True
    cur = conn.cursor()

    # 1. Bật extension vector và unaccent
    print("⚙️  1. Đang kích hoạt extension 'vector' và 'unaccent'...")
    cur.execute("CREATE EXTENSION IF NOT EXISTS vector;")
    cur.execute("CREATE EXTENSION IF NOT EXISTS unaccent;")
    print("✅ Đã kích hoạt extension thành công!")

    # 2. Đọc và thực thi file SQL
    print(f"📦 2. Đang nạp bảng và dữ liệu 43 thí sinh từ {file_sql.name}...")
    noi_dung_sql = None
    for bang_ma in ["utf-8-sig", "utf-8", "utf-16", "utf-16-le"]:
        try:
            with open(file_sql, "r", encoding=bang_ma) as f:
                noi_dung_sql = f.read()
                break
        except (UnicodeDecodeError, UnicodeError):
            continue

    if not noi_dung_sql:
        raise ValueError("Không thể đọc file SQL với các bảng mã UTF-8/UTF-16!")

    # Lọc bỏ các lệnh nội bộ của psql client và đảm bảo search_path là public
    cac_dong = ["SET search_path TO public;"]
    for dong in noi_dung_sql.splitlines():
        dong_strip = dong.strip()
        if dong_strip.startswith("\\"):
            continue
        if "set_config('search_path'" in dong:
            continue
        cac_dong.append(dong)
    sql_sach = "\n".join(cac_dong)

    cur.execute(sql_sach)
    print("🎉 NẠP TOÀN BỘ DỮ LIỆU LÊN RENDER THÀNH CÔNG!")

    # 3. Kiểm tra nhanh số lượng thí sinh
    cur.execute("SELECT COUNT(*) FROM public.thi_sinh;")
    so_luong = cur.fetchone()[0]
    print(f"📊 Đã xác nhận: Có {so_luong} thí sinh trong bảng 'thi_sinh' trên Render.")

    cur.close()
    conn.close()

except Exception as loi:
    print(f"❌ Gặp lỗi khi nạp dữ liệu: {loi}")
    sys.exit(1)
