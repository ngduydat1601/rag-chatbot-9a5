"""
Định nghĩa các node của LangGraph Chatbot.
Phiên bản Text-to-SQL: LLM tự sinh câu SELECT thay vì gọi hàm cố định.
"""

import sys
import json
import re
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from google.genai import types

from ung_dung.cau_hinh import (
    GEMINI_CHAT_MODEL,
    NHIET_DO_PHAN_TICH,
    NHIET_DO_TRA_LOI,
)
from ung_dung.co_so_du_lieu.truy_van import thuc_thi_sql, lay_ket_noi_db, tra_ket_noi_db
from ung_dung.co_so_du_lieu.quet_schema import lay_schema_csdl
from ung_dung.tim_kiem.tim_kiem_vector import tim_kiem_vector, CLIENT_GEMINI
from ung_dung.chatbot.cac_prompt import (
    PROMPT_PHAN_TICH,
    PROMPT_TRA_LOI,
    PROMPT_SINH_SQL,
    PROMPT_SUA_SQL,
    CAU_TU_CHOI,
)
from ung_dung.chatbot.trang_thai import TrangThaiChat

# Dùng chung 1 Gemini Client với module tìm kiếm vector để giữ kết nối HTTP Keep-Alive luôn ấm
client = CLIENT_GEMINI

# Danh sách model ưu tiên theo tốc độ (xoay vòng ngay nếu 1 model chạm giới hạn 15 RPM)
CAC_MODEL_UU_TIEN = [
    GEMINI_CHAT_MODEL,
    "gemini-3.5-flash",
    "gemini-3.5-flash-lite",
]


def khoi_dong_am_he_thong() -> None:
    """
    Làm ấm (Warm-up) kết nối CSDL, Schema Cache và phiên SSL/HTTP tới Gemini API
    ngay khi khởi động server để câu hỏi đầu tiên của người dùng không bị trễ Cold-Start.
    """
    try:
        lay_schema_csdl()
        conn = lay_ket_noi_db()
        tra_ket_noi_db(conn)
        client.models.generate_content(
            model=GEMINI_CHAT_MODEL,
            contents="OK",
            config=types.GenerateContentConfig(temperature=0.0, max_output_tokens=2),
        )
        # Làm ấm luôn API Embedding (câu hỏi Vector đầu tiên không bị trễ Cold-Start)
        tim_kiem_vector("giờ có mặt buổi sáng", so_ket_qua=1)
    except Exception:
        pass


def _goi_gemini_nhanh(prompt: str, nhiet_do: float = 0.0) -> str:
    """
    Gọi Gemini API với cơ chế tự động xoay vòng sang model dự phòng ngay lập tức
    nếu model chính bị quá tải (503) hoặc chạm giới hạn 15 RPM (429).
    """
    loi_cuoi = None
    for ten_model in dict.fromkeys(CAC_MODEL_UU_TIEN):
        try:
            phan_hoi = client.models.generate_content(
                model=ten_model,
                contents=prompt,
                config=types.GenerateContentConfig(temperature=nhiet_do),
            )
            if phan_hoi and phan_hoi.text:
                return phan_hoi.text.strip()
        except Exception as loi:
            loi_cuoi = loi
            continue
    raise RuntimeError(f"Tất cả model Gemini đều bận: {loi_cuoi}")


def _dinh_dang_lich_su(lich_su_chat: list[dict], so_tin_nhan: int = 6) -> str:
    """Định dạng lịch sử chat thành chuỗi văn bản cho prompt."""
    if not lich_su_chat:
        return "Chưa có cuộc trò chuyện trước đó."
    cac_tin_nhan = []
    for tin in lich_su_chat[-so_tin_nhan:]:
        vai_tro = "Người dùng" if tin.get("vai_tro") in ["user", "nguoi_dung"] else "Trợ lý"
        noi_dung = tin.get("noi_dung", "").strip()
        cac_tin_nhan.append(f"{vai_tro}: {noi_dung}")
    return "\n".join(cac_tin_nhan)


# ══════════════════════════════════════════════════════
# NODE 1: Phân tích câu hỏi & Sinh sẵn SQL (Gộp 2-trong-1)
# ══════════════════════════════════════════════════════
def phan_tich_cau_hoi(trang_thai: TrangThaiChat) -> dict:
    """
    Node 1: Phân loại ý định câu hỏi VÀ sinh sẵn câu lệnh SELECT (nếu là sql/hybrid)
    ngay trong 1 lần gọi Gemini duy nhất để giảm một nửa độ trễ.
    """
    cau_hoi = trang_thai["cau_hoi"]
    lich_su_chat = trang_thai.get("lich_su_chat") or []
    van_ban_lich_su = _dinh_dang_lich_su(lich_su_chat)
    schema_csdl = lay_schema_csdl()

    prompt = PROMPT_PHAN_TICH.format(
        schema_csdl=schema_csdl,
        lich_su=van_ban_lich_su,
        cau_hoi=cau_hoi,
    )

    try:
        van_ban = _goi_gemini_nhanh(prompt, nhiet_do=NHIET_DO_PHAN_TICH)
        van_ban = re.sub(r'^```(?:json)?\s*', '', van_ban, flags=re.IGNORECASE)
        van_ban = re.sub(r'\s*```$', '', van_ban)
        # Trích xuất khối JSON {...} nếu có ký tự thừa xung quanh
        khop_json = re.search(r'\{.*\}', van_ban, flags=re.DOTALL)
        if khop_json:
            van_ban = khop_json.group(0)

        ket_qua = json.loads(van_ban)
        y_dinh = ket_qua.get("y_dinh", "hybrid")
        cau_sql_tho = ket_qua.get("cau_sql")
        cau_sql = _lam_sach_cau_sql(cau_sql_tho) if isinstance(cau_sql_tho, str) and cau_sql_tho.strip() else None

        return {
            "y_dinh": y_dinh,
            "cau_sql": cau_sql,
        }

    except (json.JSONDecodeError, Exception):
        return {"y_dinh": "hybrid", "cau_sql": None}


# ══════════════════════════════════════════════════════
# NODE 2: Định tuyến (conditional edge)
# ══════════════════════════════════════════════════════
def dinh_tuyen(trang_thai: TrangThaiChat) -> str:
    """Quyết định node tiếp theo dựa trên ý định."""
    y_dinh = trang_thai.get("y_dinh", "hybrid")

    if y_dinh == "ngoai_pham_vi":
        return "tu_choi"
    elif y_dinh == "sql":
        return "truy_van_sql"
    elif y_dinh == "vector":
        return "tim_kiem_vector_node"
    else:
        return "truy_van_tong_hop"


# ══════════════════════════════════════════════════════
# NODE 3A: Text-to-SQL (Thực thi câu SQL đã sinh hoặc dự phòng)
# ══════════════════════════════════════════════════════
def _lam_sach_cau_sql(sql_raw: str) -> str:
    """Làm sạch markdown block và dấu chấm phẩy thừa."""
    cau_sql = sql_raw.strip()
    cau_sql = re.sub(r'^```(?:sql)?\s*', '', cau_sql, flags=re.IGNORECASE)
    cau_sql = re.sub(r'\s*```$', '', cau_sql)
    cau_sql = cau_sql.rstrip(";").strip()
    return cau_sql


def _goi_llm_sinh_sql(cau_hoi: str, van_ban_lich_su: str) -> str:
    """Gọi LLM sinh câu SELECT từ câu hỏi dựa trên schema CSDL động (dự phòng khi Node 1 chưa trả SQL)."""
    schema_csdl = lay_schema_csdl()
    prompt = PROMPT_SINH_SQL.format(
        schema_csdl=schema_csdl,
        lich_su=van_ban_lich_su,
        cau_hoi=cau_hoi,
    )
    van_ban_sql = _goi_gemini_nhanh(prompt, nhiet_do=0.0)
    return _lam_sach_cau_sql(van_ban_sql)


def _goi_llm_sua_sql(cau_sql_loi: str, thong_bao_loi: str) -> str:
    """Gọi LLM sửa câu SQL khi gặp lỗi cú pháp từ PostgreSQL."""
    prompt = PROMPT_SUA_SQL.format(cau_sql_loi=cau_sql_loi, thong_bao_loi=thong_bao_loi)
    van_ban_sql = _goi_gemini_nhanh(prompt, nhiet_do=0.0)
    return _lam_sach_cau_sql(van_ban_sql)


def truy_van_sql(trang_thai: TrangThaiChat) -> dict:
    """
    Node 3A: Sử dụng câu SELECT đã sinh sẵn ở Node 1 (hoặc gọi LLM nếu chưa có)
    → thực thi trên PostgreSQL → tự sửa nếu lỗi.
    """
    cau_hoi = trang_thai["cau_hoi"]
    lich_su_chat = trang_thai.get("lich_su_chat") or []
    van_ban_lich_su = _dinh_dang_lich_su(lich_su_chat)

    try:
        # Bước 1: Lấy SQL đã sinh sẵn từ Node 1 để tiết kiệm 1 lần gọi LLM
        cau_sql = trang_thai.get("cau_sql")
        if not cau_sql:
            cau_sql = _goi_llm_sinh_sql(cau_hoi, van_ban_lich_su)

        # Bước 2: Thực thi an toàn
        ket_qua = thuc_thi_sql(cau_sql)

        # Bước 3: Tự sửa lỗi nếu bước 2 thất bại (Self-correction 1 lần)
        if not ket_qua["thanh_cong"]:
            thong_bao_loi = ket_qua.get("loi", "Lỗi không xác định")
            cau_sql_sua = _goi_llm_sua_sql(cau_sql, thong_bao_loi)
            ket_qua_sua = thuc_thi_sql(cau_sql_sua)
            if ket_qua_sua["thanh_cong"]:
                cau_sql = cau_sql_sua
                ket_qua = ket_qua_sua

        return {
            "cau_sql": cau_sql,
            "ket_qua_sql": ket_qua,
        }

    except Exception as loi:
        return {
            "cau_sql": None,
            "ket_qua_sql": {
                "thanh_cong": False,
                "loi": f"Lỗi sinh SQL: {str(loi)}",
            },
        }


# ══════════════════════════════════════════════════════
# NODE 3B: Tìm kiếm Vector (Quy định & nội dung chung)
# ══════════════════════════════════════════════════════
def tim_kiem_vector_node(trang_thai: TrangThaiChat) -> dict:
    """Node 3B: Tìm kiếm similarity trong pgvector."""
    cau_hoi = trang_thai["cau_hoi"]
    try:
        ket_qua = tim_kiem_vector(cau_hoi, so_ket_qua=3)
    except Exception as loi:
        # Không để lỗi Embedding API làm sập toàn bộ đồ thị
        ket_qua = {"tim_thay": False, "thong_bao": f"Lỗi tìm kiếm vector: {loi}"}
    return {"ket_qua_vector": ket_qua}


# ══════════════════════════════════════════════════════
# NODE 3C: Truy vấn tổng hợp (Hybrid — Chạy song song)
# ══════════════════════════════════════════════════════
def truy_van_tong_hop(trang_thai: TrangThaiChat) -> dict:
    """Node hybrid — thực thi đồng thời (song song) cả SQL lẫn Vector."""
    with ThreadPoolExecutor(max_workers=2) as bo_thuc_thi:
        luong_sql = bo_thuc_thi.submit(truy_van_sql, trang_thai)
        luong_vector = bo_thuc_thi.submit(tim_kiem_vector_node, trang_thai)
        kq_sql = luong_sql.result()
        kq_vector = luong_vector.result()

    return {
        "cau_sql": kq_sql.get("cau_sql"),
        "ket_qua_sql": kq_sql.get("ket_qua_sql"),
        "ket_qua_vector": kq_vector.get("ket_qua_vector"),
    }


# ══════════════════════════════════════════════════════
# NODE 4: Tổng hợp bằng chứng
# ══════════════════════════════════════════════════════
def tong_hop_bang_chung(trang_thai: TrangThaiChat) -> dict:
    """Node 4: Gộp kết quả SQL + Vector thành văn bản bằng chứng gọn nhẹ."""
    cac_phan = []

    # Phần 1: Dữ liệu SQL
    ket_qua_sql = trang_thai.get("ket_qua_sql")
    if ket_qua_sql and isinstance(ket_qua_sql, dict):
        if ket_qua_sql.get("thanh_cong"):
            du_lieu = ket_qua_sql.get("du_lieu", [])
            so_ban_ghi = ket_qua_sql.get("so_ban_ghi", 0)
            cau_sql = trang_thai.get("cau_sql", "")
            cac_phan.append("=== DỮ LIỆU TỪ CƠ SỞ DỮ LIỆU (SQL) ===")
            cac_phan.append(f"Câu lệnh SQL đã chạy: {cau_sql}")
            cac_phan.append(f"Số bản ghi tìm thấy: {so_ban_ghi}")
            if so_ban_ghi == 0:
                cac_phan.append("⚠️ KẾT QUẢ: KHÔNG CÓ BẢN GHI NÀO PHÙ HỢP. Câu truy vấn SQL đã chạy thành công nhưng trả về 0 kết quả. Điều này có nghĩa là KHÔNG CÓ dữ liệu nào trong CSDL khớp với điều kiện tìm kiếm. BẠN KHÔNG ĐƯỢC TỰ BỊA RA SỐ LIỆU.")
            else:
                cac_phan.append(json.dumps(du_lieu, ensure_ascii=False, separators=(",", ":"), default=str))
        else:
            loi = ket_qua_sql.get("loi", "Không tìm thấy dữ liệu")
            cac_phan.append(f"=== KẾT QUẢ TRUY VẤN SQL ===\n{loi}")

    # Phần 2: Dữ liệu Vector
    ket_qua_vector = trang_thai.get("ket_qua_vector")
    if ket_qua_vector and isinstance(ket_qua_vector, dict):
        ds_ket_qua = ket_qua_vector.get("ket_qua", [])
        if ds_ket_qua:
            cac_phan.append("\n=== THÔNG TIN QUY ĐỊNH / NỘI DUNG PHIẾU BÁO THI ===")
            for muc in ds_ket_qua:
                tieu_de = muc.get("tieu_de", "")
                noi_dung = muc.get("noi_dung", "")
                do_tuong_dong = muc.get("do_tuong_dong", 0)
                cac_phan.append(f"[{do_tuong_dong:.0%}] {tieu_de}:\n{noi_dung}")

    bang_chung = "\n\n".join(cac_phan) if cac_phan else "Không tìm thấy dữ liệu liên quan."
    trang_thai_xu_ly = "thanh_cong" if cac_phan else "khong_tim_thay"

    return {
        "bang_chung": bang_chung,
        "trang_thai": trang_thai_xu_ly,
    }


# ══════════════════════════════════════════════════════
# NODE 5: Tạo câu trả lời (có kiểm tra chống hallucination)
# ══════════════════════════════════════════════════════

def _kiem_tra_bia_so_lieu(cau_tra_loi: str, ket_qua_sql: dict | None) -> str | None:
    """
    Lớp 3 chống hallucination: Kiểm tra xem câu trả lời có chứa số liệu
    bịa đặt khi SQL thực tế trả về 0 bản ghi không.
    Trả về câu trả lời đã sửa nếu phát hiện bịa, None nếu hợp lệ.
    """
    if not ket_qua_sql or not isinstance(ket_qua_sql, dict):
        return None
    if not ket_qua_sql.get("thanh_cong"):
        return None

    so_ban_ghi = ket_qua_sql.get("so_ban_ghi", 0)

    if so_ban_ghi == 0:
        # SQL trả về 0 bản ghi — kiểm tra xem LLM có bịa con số > 0 không
        cac_so = re.findall(r'\b(\d+)\b', cau_tra_loi)
        cac_so_lon = [int(s) for s in cac_so if int(s) > 0 and int(s) not in {
            # Loại trừ các con số là ngày tháng/giờ/năm hợp lệ trong ngữ cảnh thi cử
            7, 9, 10, 13, 29, 30, 31, 2026, 2027,
            # Loại trừ số phòng thi, SBD phổ biến
        }]
        # Nếu câu trả lời chứa số lớn (kiểu "36 học sinh", "8 bạn") mà SQL trả về 0
        for so in cac_so_lon:
            if so >= 2 and so <= 100:
                return (
                    "Theo dữ liệu trong hệ thống, mình không tìm thấy bản ghi nào "
                    "phù hợp với câu hỏi của bạn. Có thể tên trường hoặc từ khóa tìm kiếm "
                    "chưa chính xác. Bạn thử hỏi lại với tên đầy đủ hoặc cách diễn đạt khác nhé!"
                )

    return None


def tao_cau_tra_loi(trang_thai: TrangThaiChat) -> dict:
    """Node 5: Gemini đọc bằng chứng và sinh câu trả lời tự nhiên."""
    if trang_thai.get("trang_thai") == "khong_tim_thay":
        return {
            "cau_tra_loi": "Xin lỗi, tôi không tìm thấy thông tin phù hợp trong cơ sở dữ liệu lớp 9A5 cho câu hỏi này.",
            "trang_thai": "khong_tim_thay",
        }

    bang_chung = trang_thai.get("bang_chung", "Không có thông tin.")
    cau_hoi = trang_thai["cau_hoi"]
    lich_su_chat = trang_thai.get("lich_su_chat") or []
    van_ban_lich_su = _dinh_dang_lich_su(lich_su_chat)

    prompt = PROMPT_TRA_LOI.format(
        lich_su=van_ban_lich_su,
        bang_chung=bang_chung,
        cau_hoi=cau_hoi,
    )

    try:
        van_ban_tra_loi = _goi_gemini_nhanh(prompt, nhiet_do=NHIET_DO_TRA_LOI)

        # Lớp 3: Kiểm tra chống hallucination — phát hiện LLM bịa số liệu
        ket_qua_sql = trang_thai.get("ket_qua_sql")
        cau_da_sua = _kiem_tra_bia_so_lieu(van_ban_tra_loi, ket_qua_sql)
        if cau_da_sua:
            van_ban_tra_loi = cau_da_sua

        return {
            "cau_tra_loi": van_ban_tra_loi,
            "trang_thai": "thanh_cong",
        }
    except Exception as loi:
        return {
            "cau_tra_loi": "Xin lỗi, hệ thống gặp lỗi khi tạo câu trả lời. Vui lòng thử lại.",
            "trang_thai": "loi",
            "thong_bao_loi": str(loi),
        }


# ══════════════════════════════════════════════════════
# NODE 6: Từ chối câu hỏi ngoài phạm vi
# ══════════════════════════════════════════════════════
def tu_choi(trang_thai: TrangThaiChat) -> dict:
    """Node 6: Trả về câu từ chối cho câu hỏi ngoài phạm vi."""
    return {
        "cau_tra_loi": CAU_TU_CHOI,
        "trang_thai": "ngoai_pham_vi",
    }
