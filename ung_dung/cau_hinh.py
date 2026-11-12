"""
Cấu hình chung cho toàn bộ ứng dụng.
Đọc biến môi trường từ file .env và cung cấp các hằng số dùng chung.
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Tải biến môi trường từ file .env ở thư mục gốc dự án
THU_MUC_GOC = Path(__file__).resolve().parent.parent
load_dotenv(THU_MUC_GOC / ".env")


# ──────────────────────────────────────────────
# Gemini API
# ──────────────────────────────────────────────
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

# ──────────────────────────────────────────────
# PostgreSQL
# ──────────────────────────────────────────────
# Ưu tiên lấy trực tiếp từ CHUOI_KET_NOI_DB hoặc DATABASE_URL (chuẩn của Render/Cloud)
_DATABASE_URL_ENV = os.getenv("CHUOI_KET_NOI_DB") or os.getenv("DATABASE_URL")

if _DATABASE_URL_ENV:
    CHUOI_KET_NOI_DB = _DATABASE_URL_ENV
else:
    POSTGRES_HOST = os.getenv("POSTGRES_HOST", "localhost")
    POSTGRES_PORT = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "")
    POSTGRES_DB = os.getenv("POSTGRES_DB", "rag_thi_tuyen_sinh")

    CHUOI_KET_NOI_DB = (
        f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}"
        f"@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"
    )

# ──────────────────────────────────────────────
# Đường dẫn thư mục dữ liệu
# ──────────────────────────────────────────────
DUONG_DAN_PDF = THU_MUC_GOC / os.getenv("DUONG_DAN_PDF", "du_lieu/goc/9A5.pdf")
DUONG_DAN_ANH = THU_MUC_GOC / os.getenv("DUONG_DAN_ANH", "du_lieu/anh_trang")
DUONG_DAN_OCR = THU_MUC_GOC / os.getenv("DUONG_DAN_OCR", "du_lieu/ket_qua_ocr")
DUONG_DAN_TRICH_XUAT = THU_MUC_GOC / os.getenv("DUONG_DAN_TRICH_XUAT", "du_lieu/da_trich_xuat")
DUONG_DAN_KIEM_DUYET = THU_MUC_GOC / os.getenv("DUONG_DAN_KIEM_DUYET", "du_lieu/da_kiem_duyet")

# Poppler (cho pdf2image trên Windows)
POPPLER_PATH = os.getenv("POPPLER_PATH", None)

# ──────────────────────────────────────────────
# Tham số OCR
# ──────────────────────────────────────────────
DO_PHAN_GIAI_ANH = 300          # DPI khi render PDF thành ảnh
NGUONG_TIN_CAY_OCR = 0.80       # Ngưỡng confidence tối thiểu cho OCR

# ──────────────────────────────────────────────
# Tham số Gemini
# ──────────────────────────────────────────────
GEMINI_MODEL = "gemini-3.5-flash-lite"  # Model dùng để trích xuất JSON

# ──────────────────────────────────────────────
# Embedding
# ──────────────────────────────────────────────
EMBEDDING_MODEL = "gemini-embedding-001"  # Model embedding của Gemini (hỗ trợ output 768 chiều)
DUONG_DAN_TAI_LIEU_CHUNG = THU_MUC_GOC / "du_lieu/tai_lieu_chung"

# ──────────────────────────────────────────────
# Model chat (dùng cho Chatbot Giai đoạn 4)
# ──────────────────────────────────────────────
# Sử dụng gemini-3.1-flash-lite cho tốc độ phản hồi ~1.0s/call (nhanh gấp 6.6 lần gemini-3.5-flash-lite)
GEMINI_CHAT_MODEL = os.getenv("GEMINI_CHAT_MODEL", "gemini-3.1-flash-lite")  # Model trả lời chatbot
NHIET_DO_PHAN_TICH = 0.0                    # 0.0 = tất định, dùng cho phân tích JSON
NHIET_DO_TRA_LOI = 0.3                      # Chút sáng tạo khi sinh câu trả lời

# ──────────────────────────────────────────────
# Telegram Bot
# ──────────────────────────────────────────────
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
