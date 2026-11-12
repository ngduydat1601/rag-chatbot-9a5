"""
Định nghĩa State (Trạng thái) cho LangGraph Chatbot.

State là TypedDict — một dict có kiểu dữ liệu rõ ràng.
Mỗi node nhận State vào, cập nhật một số trường, rồi trả State ra.
"""

from typing import TypedDict, Optional, Any


class TrangThaiChat(TypedDict):
    """
    Trạng thái đi qua toàn bộ các node của chatbot (phiên bản Text-to-SQL).

    Vòng đời dữ liệu:
      cau_hoi → [Node 1] → y_dinh
              → [Node 2] → (định tuyến)
              → [Node 3A] → cau_sql, ket_qua_sql
              → [Node 3B] → ket_qua_vector
              → [Node 4] → bang_chung
              → [Node 5] → cau_tra_loi
    """

    # === ĐẦU VÀO ===
    cau_hoi: str                        # Câu hỏi gốc từ người dùng
    lich_su_chat: Optional[list[dict]]  # Lịch sử hội thoại [{"vai_tro": "...", "noi_dung": "..."}]

    # === SAU NODE 1 (phân tích) ===
    y_dinh: Optional[str]               # "sql" | "vector" | "hybrid" | "ngoai_pham_vi"

    # === SAU NODE 3A (Text-to-SQL) ===
    cau_sql: Optional[str]              # Câu SQL do LLM sinh ra
    ket_qua_sql: Optional[Any]          # Kết quả từ CSDL

    # === SAU NODE 3B (truy xuất vector) ===
    ket_qua_vector: Optional[Any]       # Kết quả từ tim_kiem_vector.py

    # === SAU NODE 4 (tổng hợp) ===
    bang_chung: Optional[str]           # Văn bản bằng chứng đã gộp lại

    # === SAU NODE 5 (sinh câu trả lời) ===
    cau_tra_loi: Optional[str]          # Câu trả lời cuối cùng cho người dùng

    # === TRẠNG THÁI XỬ LÝ ===
    trang_thai: Optional[str]           # "thanh_cong" | "khong_tim_thay" | "loi" | "ngoai_pham_vi"
    thong_bao_loi: Optional[str]        # Mô tả lỗi nếu có
