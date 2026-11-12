"""
Bước 3.3: Embedding nội dung tài liệu và nạp vào pgvector.

Luồng xử lý:
  noi_dung_phieu.json → Gemini Embedding API → vector 768 chiều → INSERT vào bảng tai_lieu_vector

Sử dụng:
  python -m ung_dung.tim_kiem.nap_vector
"""

import json
import sys
import time
from pathlib import Path
import psycopg2

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import (
    GEMINI_API_KEY, CHUOI_KET_NOI_DB,
    EMBEDDING_MODEL, DUONG_DAN_TAI_LIEU_CHUNG,
)

from google import genai


def tao_client_gemini():
    """Tạo client Gemini API."""
    return genai.Client(api_key=GEMINI_API_KEY)


def tao_embedding(client, van_ban: str) -> list[float]:
    """
    Chuyển một đoạn văn bản thành vector 768 chiều.

    Giải thích đơn giản:
      - Văn bản "Phiếu báo thi..." → [0.012, -0.045, 0.078, ...] (768 số thực)
      - Hai đoạn văn có ý nghĩa giống nhau sẽ cho ra 2 vector "gần nhau"
      - Hai đoạn văn khác ý nghĩa sẽ cho ra 2 vector "xa nhau"
    """
    ket_qua = client.models.embed_content(
        model=EMBEDDING_MODEL,
        contents=van_ban,
        config={"output_dimensionality": 768},
    )
    return ket_qua.embeddings[0].values


def nap_vector():
    """Đọc file noi_dung_phieu.json, tạo embedding, và lưu vào PostgreSQL."""
    # Bước 1: Đọc file nội dung
    duong_dan = DUONG_DAN_TAI_LIEU_CHUNG / "noi_dung_phieu.json"
    with open(duong_dan, "r", encoding="utf-8") as f:
        danh_sach = json.load(f)
    print(f"📄 Đã đọc {len(danh_sach)} đoạn tài liệu")

    # Bước 2: Kết nối database
    conn = psycopg2.connect(CHUOI_KET_NOI_DB)
    cur = conn.cursor()

    # Bước 3: Xóa dữ liệu cũ
    cur.execute("TRUNCATE TABLE tai_lieu_vector RESTART IDENTITY;")
    print("🔄 Đã dọn dẹp bảng tai_lieu_vector")

    # Bước 4: Tạo embedding và nạp từng đoạn
    client = tao_client_gemini()
    for i, doan in enumerate(danh_sach, 1):
        # Ghép tiêu đề + nội dung để embedding chất lượng hơn
        van_ban_de_embedding = f"{doan['tieu_de']}: {doan['noi_dung']}"

        print(f"  [{i}/{len(danh_sach)}] Đang embedding: {doan['tieu_de']}...", end=" ")
        vector = tao_embedding(client, van_ban_de_embedding)
        print(f"✅ ({len(vector)} chiều)")

        # Lưu vào PostgreSQL
        cur.execute("""
            INSERT INTO tai_lieu_vector (ma_doan, tieu_de, noi_dung, nguon, vector_noi_dung)
            VALUES (%s, %s, %s, %s, %s::vector);
        """, (
            doan["ma_doan"],
            doan["tieu_de"],
            doan["noi_dung"],
            doan.get("nguon"),
            str(vector),  # pgvector nhận chuỗi dạng "[0.01, -0.02, ...]"
        ))

        # Nghỉ 0.5 giây giữa các lần gọi API (tránh bị giới hạn tốc độ)
        time.sleep(0.5)

    conn.commit()
    print(f"\n✅ Đã nạp thành công {len(danh_sach)} đoạn tài liệu vào pgvector!")

    # Bước 5: Kiểm tra lại
    cur.execute("SELECT COUNT(*), ma_doan FROM tai_lieu_vector GROUP BY ma_doan;")
    for row in cur.fetchall():
        print(f"  - {row[1]}")
    print(f"  Tổng: {len(danh_sach)} đoạn")

    cur.close()
    conn.close()


if __name__ == "__main__":
    nap_vector()