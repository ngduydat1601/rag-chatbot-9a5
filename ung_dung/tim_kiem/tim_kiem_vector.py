"""
Bước 3.4: Vector Retriever — Tìm kiếm tài liệu theo ý nghĩa câu hỏi.

Cách hoạt động:
  1. Nhận câu hỏi từ người dùng
  2. Chuyển câu hỏi thành vector (embedding)
  3. So sánh vector câu hỏi với tất cả vector trong bảng tai_lieu_vector
  4. Trả về các đoạn tài liệu "gần nhau" nhất (tương đồng ý nghĩa nhất)

Sử dụng:
  python -m ung_dung.tim_kiem.tim_kiem_vector
"""

import sys
import time
from functools import lru_cache
from pathlib import Path
from psycopg2.extras import RealDictCursor

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import GEMINI_API_KEY, EMBEDDING_MODEL
from ung_dung.co_so_du_lieu.truy_van import lay_ket_noi_db, tra_ket_noi_db
from google import genai
from google.genai import types

# Khởi tạo Gemini Client 1 lần duy nhất (dùng chung cho cả Embedding và Chat để giữ kết nối Keep-Alive ấm)
CLIENT_GEMINI = genai.Client(
    api_key=GEMINI_API_KEY,
    http_options=types.HttpOptions(
        timeout=12000,
        retry_options=types.HttpRetryOptions(attempts=1),
    ),
)


@lru_cache(maxsize=128)
def _tao_embedding_da_luu_cache(cau_hoi_chuan: str) -> tuple[float, ...]:
    """Chuyển câu hỏi thành vector và lưu vào bộ nhớ đệm (RAM) để tránh gọi lại API."""
    # Tự thử lại tối đa 3 lần (nghỉ ngắn 0.5s) nếu Google trả 503 tạm thời
    for lan_thu in range(3):
        try:
            ket_qua = CLIENT_GEMINI.models.embed_content(
                model=EMBEDDING_MODEL,
                contents=cau_hoi_chuan,
                config={"output_dimensionality": 768},
            )
            return tuple(ket_qua.embeddings[0].values)
        except Exception:
            if lan_thu == 2:
                raise
            time.sleep(0.5)


def _tao_embedding_cau_hoi(cau_hoi: str) -> list[float]:
    """Chuyển câu hỏi thành vector (có sử dụng cache)."""
    cau_hoi_chuan = " ".join(cau_hoi.strip().lower().split())
    return list(_tao_embedding_da_luu_cache(cau_hoi_chuan))


def tim_kiem_vector(cau_hoi: str, so_ket_qua: int = 3) -> dict:
    """
    Tìm các đoạn tài liệu liên quan nhất đến câu hỏi.

    Tham số:
      cau_hoi    : Câu hỏi của người dùng (tiếng Việt)
      so_ket_qua : Số lượng đoạn trả về (mặc định: 3)

    Trả về:
      {
        "tim_thay": True/False,
        "cau_hoi": "...",
        "ket_qua": [
          {
            "ma_doan": "lich_thi",
            "tieu_de": "Quy định về lịch thi",
            "noi_dung": "...",
            "nguon": "...",
            "do_tuong_dong": 0.85
          },
          ...
        ]
      }
    """
    # Bước 1: Embedding câu hỏi
    vector_cau_hoi = _tao_embedding_cau_hoi(cau_hoi)

    # Bước 2: Truy vấn pgvector — tìm các đoạn có vector gần nhất (tái sử dụng kết nối từ Pool)
    conn = lay_ket_noi_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    try:
        # Toán tử <=> là cosine distance (khoảng cách cosine)
        # Giá trị càng nhỏ → càng giống nhau
        # 1 - khoảng cách = độ tương đồng (0.0 đến 1.0)
        sql = """
            SELECT
                ma_doan,
                tieu_de,
                noi_dung,
                nguon,
                1 - (vector_noi_dung <=> %s::vector) AS do_tuong_dong
            FROM tai_lieu_vector
            ORDER BY vector_noi_dung <=> %s::vector
            LIMIT %s;
        """
        vector_str = str(vector_cau_hoi)
        cur.execute(sql, (vector_str, vector_str, so_ket_qua))
        rows = cur.fetchall()

        if not rows:
            return {
                "tim_thay": False,
                "cau_hoi": cau_hoi,
                "thong_bao": "Không tìm thấy tài liệu nào liên quan.",
            }

        ket_qua = []
        for r in rows:
            ket_qua.append({
                "ma_doan": r["ma_doan"],
                "tieu_de": r["tieu_de"],
                "noi_dung": r["noi_dung"],
                "nguon": r["nguon"],
                "do_tuong_dong": round(float(r["do_tuong_dong"]), 4),
            })

        return {
            "tim_thay": True,
            "cau_hoi": cau_hoi,
            "so_ket_qua": len(ket_qua),
            "ket_qua": ket_qua,
        }

    finally:
        cur.close()
        try:
            conn.rollback()
        except Exception:
            pass
        tra_ket_noi_db(conn)


if __name__ == "__main__":
    import json

    cac_cau_hoi_thu = [
        "Phiếu báo thi có những mục gì?",
        "Bao giờ phải đến trường để làm thủ tục dự thi?",
        "Buổi sáng mấy giờ phải có mặt?",
        "Phần thi chuyên có nội dung gì?",
        "Được đăng ký bao nhiêu nguyện vọng?",
    ]

    for cau_hoi in cac_cau_hoi_thu:
        kq = tim_kiem_vector(cau_hoi, so_ket_qua=2)
        print(f"\n{'─'*60}")
        print(f"  CÂU HỎI: {cau_hoi}")
        print(f"{'─'*60}")
        if kq["tim_thay"]:
            for i, r in enumerate(kq["ket_qua"], 1):
                print(f"  Kết quả {i}: [{r['do_tuong_dong']:.2%}] {r['tieu_de']}")
                print(f"    → {r['noi_dung'][:100]}...")
        else:
            print(f"  {kq['thong_bao']}")