"""
Bước 2.5: Nạp dữ liệu từ candidates.json vào PostgreSQL bằng SQL thuần.

Sử dụng trực tiếp psycopg2 và các câu lệnh INSERT INTO.
Không cần SQLAlchemy, không cần file mo_hinh.py hay ket_noi.py.

Sử dụng:
  python -m ung_dung.co_so_du_lieu.nap_du_lieu
"""

import json
import sys
from pathlib import Path
import psycopg2
from psycopg2.extras import RealDictCursor

# Đảm bảo in tiếng Việt trên console Windows không lỗi
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

# Thêm thư mục gốc vào path để lấy cấu hình
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import CHUOI_KET_NOI_DB, DUONG_DAN_KIEM_DUYET


def lay_ket_noi():
    """Tạo kết nối trực tiếp đến PostgreSQL."""
    return psycopg2.connect(CHUOI_KET_NOI_DB)


def doc_du_lieu_json(duong_dan: Path) -> list[dict]:
    """Đọc file candidates.json."""
    with open(duong_dan, "r", encoding="utf-8") as f:
        du_lieu = json.load(f)
    print(f"📄 Đã đọc {len(du_lieu)} bản ghi từ {duong_dan.name}")
    return du_lieu


def nap_du_lieu(duong_dan_json: Path = None):
    """Nạp toàn bộ dữ liệu vào PostgreSQL bằng các lệnh SQL thuần."""
    if duong_dan_json is None:
        duong_dan_json = DUONG_DAN_KIEM_DUYET / "candidates.json"

    danh_sach = doc_du_lieu_json(duong_dan_json)
    conn = lay_ket_noi()
    cur = conn.cursor()

    try:
        # Bước 1: Dọn dẹp dữ liệu cũ (reset ID về 1)
        print("🔄 Dọn dẹp dữ liệu cũ trong bảng...")
        cur.execute("""
            TRUNCATE TABLE nguyen_vong_chuyen, tuyen_sinh_chuyen, 
                           lich_thi, nguyen_vong, thi_sinh 
            RESTART IDENTITY CASCADE;
        """)

        # Bước 2: Nạp từng bản ghi
        so_thanh_cong = 0
        for ban_ghi in danh_sach:
            # 1. Thêm vào bảng thi_sinh
            sql_thi_sinh = """
                INSERT INTO thi_sinh (
                    ho_ten, ngay_sinh, gioi_tinh, dan_toc, noi_sinh,
                    ma_hoc_sinh, lop, co_so_giao_duc, thi_cong_lap,
                    so_luong_nguyen_vong, ngoai_ngu_hoc, ngoai_ngu_thi,
                    diem_uu_tien, diem_khuyen_khich, diem_thi, dia_chi_diem_thi,
                    so_bao_danh, phong_thi, thoi_gian_tap_trung, so_trang_nguon,
                    trang_thai_kiem_duyet, tai_lieu_nguon
                ) VALUES (
                    %s, %s, %s, %s, %s,
                    %s, %s, %s, %s,
                    %s, %s, %s,
                    %s, %s, %s, %s,
                    %s, %s, %s, %s,
                    %s, %s
                ) RETURNING id;
            """
            cur.execute(sql_thi_sinh, (
                ban_ghi["ho_ten"],
                ban_ghi["ngay_sinh"],
                ban_ghi["gioi_tinh"],
                ban_ghi["dan_toc"],
                ban_ghi["noi_sinh"],
                ban_ghi["ma_hoc_sinh"],
                ban_ghi["lop"],
                ban_ghi["co_so_giao_duc"],
                ban_ghi["thi_cong_lap"],
                ban_ghi["so_luong_nguyen_vong"],
                ban_ghi.get("ngoai_ngu_hoc"),
                ban_ghi.get("ngoai_ngu_thi"),
                ban_ghi.get("diem_uu_tien", 0),
                ban_ghi.get("diem_khuyen_khich", 0),
                ban_ghi.get("diem_thi"),
                ban_ghi.get("dia_chi_diem_thi"),
                ban_ghi["so_bao_danh"],
                ban_ghi.get("phong_thi"),
                "9h00 ngày 29/5/2026",  # Giá trị mặc định
                ban_ghi.get("so_trang_nguon"),
                ban_ghi.get("trang_thai_kiem_duyet", "verified"),
                ban_ghi.get("tai_lieu_nguon", "9A5.pdf")
            ))
            thi_sinh_id = cur.fetchone()[0]

            # 2. Thêm vào bảng nguyen_vong
            for nv in ban_ghi.get("danh_sach_nguyen_vong", []):
                cur.execute("""
                    INSERT INTO nguyen_vong (thi_sinh_id, thu_tu, ten_truong)
                    VALUES (%s, %s, %s);
                """, (thi_sinh_id, nv["thu_tu"], nv["ten_truong"]))

            # 3. Thêm vào bảng lich_thi
            for mon in ban_ghi.get("lich_thi", []):
                cur.execute("""
                    INSERT INTO lich_thi (thi_sinh_id, ten_mon, buoi_thi, ngay_thi)
                    VALUES (%s, %s, %s, %s);
                """, (thi_sinh_id, mon["ten_mon"], mon["buoi_thi"], mon["ngay_thi"]))

            # 4. Thêm vào bảng tuyen_sinh_chuyen (nếu có)
            chuyen = ban_ghi.get("tuyen_sinh_chuyen")
            if chuyen:
                cur.execute("""
                    INSERT INTO tuyen_sinh_chuyen (
                        thi_sinh_id, mon_thi_chuyen, ngay_thi_chuyen,
                        diem_thi_chuyen, phong_thi_chuyen
                    ) VALUES (%s, %s, %s, %s, %s) RETURNING id;
                """, (
                    thi_sinh_id,
                    chuyen.get("mon_thi_chuyen"),
                    chuyen.get("ngay_thi_chuyen"),
                    chuyen.get("diem_thi_chuyen"),
                    chuyen.get("phong_thi_chuyen")
                ))
                tsc_id = cur.fetchone()[0]

                # Thêm danh sách nguyện vọng chuyên
                for nvc in chuyen.get("danh_sach_nguyen_vong_chuyen", []):
                    cur.execute("""
                        INSERT INTO nguyen_vong_chuyen (
                            tuyen_sinh_chuyen_id, thu_tu, truong_chuyen, lop_chuyen
                        ) VALUES (%s, %s, %s, %s);
                    """, (tsc_id, nvc["thu_tu"], nvc["truong_chuyen"], nvc["lop_chuyen"]))

            so_thanh_cong += 1

        conn.commit()
        print(f"✅ Đã nạp thành công {so_thanh_cong} thí sinh vào PostgreSQL!")

    except Exception as e:
        conn.rollback()
        print(f"❌ Lỗi khi nạp dữ liệu: {e}")
        raise
    finally:
        cur.close()
        conn.close()

    # Kiểm tra lại số lượng sau khi nạp
    kiem_tra_sau_nap()


def kiem_tra_sau_nap():
    """Kiểm tra số lượng bản ghi bằng lệnh SQL COUNT."""
    conn = lay_ket_noi()
    cur = conn.cursor()

    print(f"\n{'='*50}")
    print(f"  KIỂM TRA SAU KHI NẠP DỮ LIỆU (SQL THUẦN)")
    print(f"{'='*50}")

    cur.execute("SELECT COUNT(*) FROM thi_sinh;")
    print(f"  Thí sinh         : {cur.fetchone()[0]} (mong đợi: 43)")

    cur.execute("SELECT COUNT(*) FROM nguyen_vong;")
    print(f"  Nguyện vọng      : {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM lich_thi;")
    print(f"  Lịch thi         : {cur.fetchone()[0]} (mong đợi: 129 = 43x3)")

    cur.execute("SELECT COUNT(*) FROM tuyen_sinh_chuyen;")
    print(f"  Tuyển sinh chuyên: {cur.fetchone()[0]} (mong đợi: 1)")

    cur.execute("SELECT COUNT(*) FROM nguyen_vong_chuyen;")
    print(f"  NV chuyên        : {cur.fetchone()[0]} (mong đợi: 2)")

    print(f"{'='*50}")
    cur.close()
    conn.close()


if __name__ == "__main__":
    nap_du_lieu()
