"""
Bước 1.3: Trích xuất thông tin thí sinh thành JSON có cấu trúc bằng Gemini.

Gemini nhận đầu vào là:
  1. Ảnh gốc của trang (để hiểu bố cục 3 cột)
  2. Văn bản OCR (để có gợi ý text)

Gemini trả về JSON theo schema đã định nghĩa bằng Pydantic.

LƯU Ý BẢO MẬT:
  - PDF chứa thông tin cá nhân học sinh.
  - Giai đoạn thử nghiệm nên sử dụng dữ liệu đã ẩn danh.
  - Khi triển khai thật phải xác định rõ quyền sử dụng dữ liệu.
"""

import json
import base64
import time
from pathlib import Path
from typing import Optional

from google import genai
from google.genai import types
from pydantic import BaseModel, Field

import sys
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import (
    GEMINI_API_KEY,
    GEMINI_MODEL,
    DUONG_DAN_ANH,
    DUONG_DAN_OCR,
    DUONG_DAN_TRICH_XUAT,
)


# ──────────────────────────────────────────────
# Định nghĩa Schema dữ liệu (Pydantic Models)
# ──────────────────────────────────────────────

class MonThi(BaseModel):
    """Thông tin một môn thi."""
    ten_mon: str = Field(description="Tên môn thi: Ngữ văn, Ngoại ngữ, hoặc Toán")
    buoi_thi: str = Field(description="Buổi thi: Sáng hoặc Chiều")
    ngay_thi: str = Field(description="Ngày thi, ví dụ: 30/5")


class NguyenVong(BaseModel):
    """Thông tin một nguyện vọng đăng ký."""
    thu_tu: int = Field(description="Thứ tự nguyện vọng: 1, 2, hoặc 3")
    ten_truong: str = Field(description="Tên trường THPT đăng ký")


class NguyenVongChuyen(BaseModel):
    """Thông tin từng nguyện vọng chuyên."""
    thu_tu: int = Field(description="Thứ tự nguyện vọng chuyên: 1, 2,...")
    truong_chuyen: str = Field(description="Tên trường chuyên đăng ký, ví dụ: Chuyên Sơn Tây, Chuyên Nguyễn Huệ")
    lop_chuyen: str = Field(description="Lớp chuyên đăng ký, ví dụ: Tin/1, Tin/2")

class TuyenSinhChuyen(BaseModel):
    """Thông tin toàn bộ phần tuyển sinh chuyên."""
    danh_sach_nguyen_vong_chuyen: list[NguyenVongChuyen] = Field(
        description="Danh sách các nguyện vọng chuyên đăng ký (NV1, NV2...)"
    )
    mon_thi_chuyen: Optional[str] = Field(default=None, description="Môn thi chuyên, ví dụ: Tin")
    ngay_thi_chuyen: Optional[str] = Field(default=None, description="Ngày thi chuyên, ví dụ: Sáng 01/6")
    diem_thi_chuyen: Optional[str] = Field(default=None, description="Địa điểm thi chuyên, ví dụ: THPT chuyên Sơn Tây")
    phong_thi_chuyen: Optional[str] = Field(default=None, description="Số phòng thi chuyên, ví dụ: 9")


class ThongTinThiSinh(BaseModel):
    """Schema đầy đủ thông tin một thí sinh trên phiếu báo thi."""

    # === Thông tin cá nhân ===
    ho_ten: str = Field(description="Họ và tên đầy đủ của thí sinh (IN HOA)")
    ngay_sinh: str = Field(description="Ngày sinh dạng dd/mm/yyyy")
    gioi_tinh: str = Field(description="Giới tính: Nam hoặc Nữ")
    dan_toc: str = Field(description="Dân tộc, ví dụ: Kinh")
    noi_sinh: str = Field(description="Nơi sinh, ví dụ: Hà Nội")

    # === Thông tin trường học ===
    ma_hoc_sinh: str = Field(description="Mã học sinh (chuỗi số 10-12 ký tự)")
    lop: str = Field(description="Lớp học năm lớp 9, ví dụ: 9A5")
    co_so_giao_duc: str = Field(description="Tên cơ sở giáo dục năm lớp 9")

    # === Thông tin tuyển sinh ===
    thi_cong_lap: bool = Field(description="Có đăng ký thi vào công lập không")
    so_luong_nguyen_vong: int = Field(description="Số lượng nguyện vọng đã đăng ký")
    danh_sach_nguyen_vong: list[NguyenVong] = Field(description="Danh sách nguyện vọng")
    ngoai_ngu_hoc: str = Field(description="Ngoại ngữ đăng ký học THPT")
    ngoai_ngu_thi: str = Field(description="Ngoại ngữ đăng ký thi")
    diem_uu_tien: float = Field(description="Điểm ưu tiên (số)")
    diem_khuyen_khich: float = Field(description="Điểm khuyến khích (số)")

    # === Thông tin kỳ thi ===
    diem_thi: str = Field(description="Tên điểm thi (tên trường THPT nơi thi)")
    dia_chi_diem_thi: str = Field(description="Địa chỉ chi tiết của điểm thi")
    so_bao_danh: str = Field(description="Số báo danh (chuỗi số 6 ký tự)")
    phong_thi: str = Field(description="Số phòng thi")
    lich_thi: list[MonThi] = Field(description="Lịch thi 3 môn")

    # === Tuyển sinh chuyên (tùy chọn) ===
    tuyen_sinh_chuyen: Optional[TuyenSinhChuyen] = Field(
        default=None,
        description="Thông tin tuyển sinh chuyên. Để null nếu thí sinh không đăng ký thi chuyên."
    )

    # === Metadata nguồn ===
    so_trang_nguon: int = Field(description="Số trang trong PDF gốc")


# ──────────────────────────────────────────────
# Hàm trích xuất dữ liệu bằng Gemini
# ──────────────────────────────────────────────

# Prompt hướng dẫn Gemini trích xuất chính xác
MAU_PROMPT = """Bạn là chuyên gia trích xuất dữ liệu từ phiếu báo thi vào lớp 10 THPT.

Hãy đọc ảnh phiếu báo thi đính kèm và trích xuất TẤT CẢ thông tin vào đúng schema JSON.

QUY TẮC BẮT BUỘC:
1. Chỉ trích xuất thông tin NHÌN THẤY trên phiếu. KHÔNG tự suy luận hay bổ sung.
2. Số báo danh, mã học sinh, phòng thi: giữ nguyên chuỗi số, không thay đổi.
3. Họ tên: giữ nguyên IN HOA như trên phiếu.
4. Ngày sinh: định dạng dd/mm/yyyy.
5. Điểm ưu tiên và khuyến khích: ghi đúng số, thường là 0 hoặc 0.5 hoặc 1.
6. Nếu không có phần tuyển sinh chuyên, để tuyen_sinh_chuyen = null.
7. Nguyện vọng: ghi đúng thứ tự 1, 2, 3 và tên trường tương ứng.
8. Địa chỉ điểm thi: ghi đầy đủ kể cả tên thôn/xã/phường/quận/huyện.

DỮ LIỆU THAM KHẢO TỪ OCR (có thể chứa lỗi, chỉ dùng để đối chiếu):
{van_ban_ocr}

Số trang nguồn trong PDF: {so_trang}
"""


def khoi_tao_gemini() -> genai.Client:
    """Khởi tạo client Gemini API."""
    client = genai.Client(api_key=GEMINI_API_KEY)
    return client


def doc_anh_base64(duong_dan_anh: Path) -> str:
    """Đọc file ảnh và chuyển thành chuỗi base64."""
    with open(duong_dan_anh, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")


def trich_xuat_mot_trang(
    client: genai.Client,
    duong_dan_anh: Path,
    van_ban_ocr: str,
    so_trang: int,
) -> dict:
    """
    Gửi ảnh + text OCR cho Gemini và nhận về JSON có cấu trúc.

    Args:
        client: Gemini API client.
        duong_dan_anh: Đường dẫn file ảnh trang.
        van_ban_ocr: Văn bản OCR đã nhận dạng.
        so_trang: Số trang trong PDF gốc.

    Returns:
        Dictionary chứa thông tin thí sinh đã trích xuất.
    """
    # Đọc ảnh
    anh_bytes = duong_dan_anh.read_bytes()

    # Tạo prompt đầy đủ
    noi_dung_prompt = MAU_PROMPT.format(
        van_ban_ocr=van_ban_ocr,
        so_trang=so_trang,
    )

    # Gọi Gemini với Structured Output
    phan_hoi = client.models.generate_content(
        model=GEMINI_MODEL,
        contents=[
            types.Content(
                role="user",
                parts=[
                    types.Part.from_bytes(data=anh_bytes, mime_type="image/png"),
                    types.Part.from_text(text=noi_dung_prompt),
                ],
            )
        ],
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=ThongTinThiSinh,
            temperature=0.0,  # Không sáng tạo, chỉ trích xuất chính xác
        ),
    )

    # Parse kết quả
    du_lieu = json.loads(phan_hoi.text)
    return du_lieu


def trich_xuat_co_thu_lai(
    client: genai.Client,
    duong_dan_anh: Path,
    van_ban_ocr: str,
    so_trang: int,
    so_lan_thu: int = 5,
) -> dict:
    """
    Gọi Gemini kèm cơ chế thử lại khi gặp lỗi tạm thời (503/quá tải).

    Chờ theo cấp số nhân: 2s, 4s, 8s, 16s trước mỗi lần thử lại.
    """
    for lan_thu in range(1, so_lan_thu + 1):
        try:
            return trich_xuat_mot_trang(
                client=client,
                duong_dan_anh=duong_dan_anh,
                van_ban_ocr=van_ban_ocr,
                so_trang=so_trang,
            )
        except Exception as loi:
            if lan_thu == so_lan_thu:
                raise
            thoi_gian_cho = 2 ** lan_thu
            print(f"[thử lại {lan_thu}/{so_lan_thu - 1} sau {thoi_gian_cho}s] ", end="")
            time.sleep(thoi_gian_cho)


def trich_xuat_tat_ca(
    thu_muc_anh: Path = DUONG_DAN_ANH,
    thu_muc_ocr: Path = DUONG_DAN_OCR,
    thu_muc_luu: Path = DUONG_DAN_TRICH_XUAT,
) -> list[Path]:
    """
    Trích xuất JSON từ tất cả trang bằng Gemini.

    Args:
        thu_muc_anh: Thư mục chứa ảnh các trang.
        thu_muc_ocr: Thư mục chứa kết quả OCR.
        thu_muc_luu: Thư mục lưu JSON đã trích xuất.

    Returns:
        Danh sách đường dẫn file JSON đã trích xuất.
    """
    thu_muc_luu.mkdir(parents=True, exist_ok=True)

    # Lấy danh sách ảnh
    danh_sach_anh = sorted(thu_muc_anh.glob("trang_*.png"))
    if not danh_sach_anh:
        print(f"[LỖI] Không tìm thấy ảnh nào trong: {thu_muc_anh}")
        return []

    print(f"[3/5] Đang trích xuất JSON bằng Gemini ({len(danh_sach_anh)} trang)...")
    client = khoi_tao_gemini()

    danh_sach_ket_qua = []
    for chi_so, duong_dan_anh in enumerate(danh_sach_anh, start=1):
        so_trang = int(duong_dan_anh.stem.split("_")[1])

        # Bỏ qua trang đã trích xuất thành công ở lần chạy trước
        ten_file = f"thi_sinh_trang_{so_trang:03d}.json"
        duong_dan_json = thu_muc_luu / ten_file
        if duong_dan_json.exists():
            print(f"       Trang {chi_so}/{len(danh_sach_anh)}: → Bỏ qua (đã có)")
            danh_sach_ket_qua.append(duong_dan_json)
            continue

        # Đọc kết quả OCR tương ứng (nếu có)
        file_ocr = thu_muc_ocr / f"ocr_trang_{so_trang:03d}.json"
        van_ban_ocr = ""
        if file_ocr.exists():
            with open(file_ocr, "r", encoding="utf-8") as f:
                du_lieu_ocr = json.load(f)
                van_ban_ocr = du_lieu_ocr.get("van_ban_day_du", "")

        print(f"       Trang {chi_so}/{len(danh_sach_anh)}: ", end="")

        try:
            du_lieu = trich_xuat_co_thu_lai(
                client=client,
                duong_dan_anh=duong_dan_anh,
                van_ban_ocr=van_ban_ocr,
                so_trang=so_trang,
            )

            # Thêm metadata trạng thái kiểm duyệt
            du_lieu["trang_thai_kiem_duyet"] = "pending"
            du_lieu["tai_lieu_nguon"] = "9A5.pdf"

            # Lưu file JSON
            with open(duong_dan_json, "w", encoding="utf-8") as f:
                json.dump(du_lieu, f, ensure_ascii=False, indent=2)

            print(f"✓ {du_lieu.get('ho_ten', 'N/A')}")
            danh_sach_ket_qua.append(duong_dan_json)

        except Exception as loi:
            print(f"✗ LỖI: {loi}")

    print(f"       ✓ Đã trích xuất {len(danh_sach_ket_qua)} bản ghi tại: {thu_muc_luu}")
    return danh_sach_ket_qua


# ──────────────────────────────────────────────
# Chạy độc lập để kiểm tra
# ──────────────────────────────────────────────
if __name__ == "__main__":
    ket_qua = trich_xuat_tat_ca()
    print(f"\nTổng file trích xuất: {len(ket_qua)}")