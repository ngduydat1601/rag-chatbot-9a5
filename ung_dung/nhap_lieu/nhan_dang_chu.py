"""
Bước 1.2: Nhận dạng chữ bằng PaddleOCR Detection + VietOCR Recognition.

Chức năng:
1. PaddleOCR phát hiện vị trí các dòng chữ (Detection).
2. Perspective Transform để căn chỉnh các dòng chữ về phương ngang.
3. VietOCR nhận dạng tiếng Việt có dấu chuẩn xác (Recognition).
4. Nhận diện dấu [X] ở ô 'Thi vào công lập':
   - Tách vùng ô vuông checkbox ở đầu dòng chữ (có tự động căn chỉnh contour).
   - Dùng chính VietOCR để đọc ô vuông: nếu ra 'x' / 'X' -> có chọn (selected = True).
5. Lưu kết quả OCR và trạng thái lựa chọn vào JSON.
"""

import json
import re
import unicodedata
from pathlib import Path

# Import PyTorch trước để nạp DLL
import torch
print("PyTorch:", torch.__version__)
print("CUDA:", torch.cuda.is_available())

import cv2
import numpy as np
from PIL import Image

# Import VietOCR sau PyTorch
from vietocr.tool.config import Cfg
from vietocr.tool.predictor import Predictor

# Import PaddleOCR sau cùng
from paddleocr import PaddleOCR

import sys
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from ung_dung.cau_hinh import DUONG_DAN_ANH, DUONG_DAN_OCR


# ==================================================
# CẤU HÌNH
# ==================================================

THIET_BI_VIETOCR = "cuda" if torch.cuda.is_available() else "cpu"
LUU_ANH_DEBUG = True


# ==================================================
# KHỞI TẠO MODEL
# ==================================================

def khoi_tao_paddle_detector() -> PaddleOCR:
    """Khởi tạo PaddleOCR chỉ để Detection (bỏ recognition)."""
    return PaddleOCR(
        use_angle_cls=False,
        lang="vi",
        rec=False,
        show_log=False,
    )


def khoi_tao_vietocr(thiet_bi: str = "cuda") -> Predictor:
    """Khởi tạo VietOCR Recognition (vgg_transformer)."""
    cau_hinh = Cfg.load_config_from_name("vgg_transformer")
    cau_hinh["cnn"]["pretrained"] = False
    cau_hinh["device"] = thiet_bi
    cau_hinh["predictor"]["beamsearch"] = False
    return Predictor(cau_hinh)


# ==================================================
# XỬ LÝ BOUNDING BOX
# ==================================================

def chuan_hoa_bbox(item):
    """Chuẩn hóa kết quả bounding box từ PaddleOCR về dạng list 4 điểm."""
    cac_ung_vien = [item]
    if isinstance(item, (list, tuple)) and len(item) == 2:
        cac_ung_vien.insert(0, item[0])

    for ung_vien in cac_ung_vien:
        try:
            arr = np.asarray(ung_vien, dtype=np.float32)
            if arr.shape == (4, 2):
                return arr.tolist()
        except (ValueError, TypeError):
            continue
    return None


def sap_xep_bbox_theo_dong(danh_sach_bbox):
    """Sắp xếp bounding box từ trên xuống dưới, cùng dòng từ trái sang phải."""
    danh_sach_da_xu_ly = []

    for item in danh_sach_bbox:
        bbox = chuan_hoa_bbox(item)
        if bbox is None:
            continue

        y_trung_tam = (bbox[0][1] + bbox[2][1]) / 2
        x_trai = min(point[0] for point in bbox)

        danh_sach_da_xu_ly.append({
            "bbox": bbox,
            "y": y_trung_tam,
            "x": x_trai,
        })

    danh_sach_da_xu_ly.sort(key=lambda item: (item["y"], item["x"]))
    return [item["bbox"] for item in danh_sach_da_xu_ly]


# ==================================================
# CẮT ẢNH VÀ CĂN CHỈNH
# ==================================================

def cat_anh_theo_bbox(
    anh: Image.Image,
    bbox: list,
    padding: int = 5
) -> Image.Image:
    """Cắt vùng chữ và dùng Perspective Transform để căn ngang."""
    diem = np.asarray(bbox, dtype=np.float32)

    rong = int(max(
        np.linalg.norm(diem[1] - diem[0]),
        np.linalg.norm(diem[2] - diem[3])
    ))
    cao = int(max(
        np.linalg.norm(diem[3] - diem[0]),
        np.linalg.norm(diem[2] - diem[1])
    ))

    rong = max(rong, 2)
    cao = max(cao, 2)

    diem_dich = np.array([
        [0, 0],
        [rong - 1, 0],
        [rong - 1, cao - 1],
        [0, cao - 1],
    ], dtype=np.float32)

    ma_tran = cv2.getPerspectiveTransform(diem, diem_dich)
    anh_np = np.asarray(anh.convert("RGB"))

    anh_can_chinh = cv2.warpPerspective(
        anh_np,
        ma_tran,
        (rong, cao),
        flags=cv2.INTER_CUBIC,
        borderMode=cv2.BORDER_CONSTANT,
        borderValue=(255, 255, 255),
    )

    anh_cat = Image.fromarray(anh_can_chinh)

    # Thêm padding nền trắng
    canvas = Image.new(
        "RGB",
        (anh_cat.width + padding * 2, anh_cat.height + padding * 2),
        (255, 255, 255)
    )
    canvas.paste(anh_cat, (padding, padding))
    return canvas


# ==================================================
# PHÁT HIỆN DẤU [X] BẰNG VIETOCR
# ==================================================

def chuan_hoa_chu_khong_dau(text: str) -> str:
    """Chuyển chữ tiếng Việt thành chữ thường không dấu."""
    text = text.lower().replace("đ", "d")
    text = unicodedata.normalize("NFD", text)
    return "".join(c for c in text if unicodedata.category(c) != "Mn")


def la_dong_thi_vao_cong_lap(text: str) -> bool:
    """Kiểm tra dòng có chứa nội dung 'Thi vào công lập' không."""
    return "thi vao cong lap" in chuan_hoa_chu_khong_dau(text)


def tach_vung_dau_va_van_ban(
    anh_dong: Image.Image,
    padding_hop: int = 4
):
    """
    Tách ô vuông checkbox ở đầu dòng và phần văn bản còn lại.
    Dùng contour để tự động bắt trọn viền ô vuông không bị lệch mép.
    """
    rong, cao = anh_dong.size

    # Quét vùng 35% bên trái của dòng chữ
    vung_quet_rong = min(int(cao * 1.4), int(rong * 0.35))
    anh_dau_dong = anh_dong.crop((0, 0, vung_quet_rong, cao))

    anh_np = np.asarray(anh_dau_dong.convert("RGB"))
    gray = cv2.cvtColor(anh_np, cv2.COLOR_RGB2GRAY)
    _, binary = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    contours, _ = cv2.findContours(binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    hop_vuong_bbox = None
    min_size = int(cao * 0.35)
    max_size = int(cao * 1.1)

    for cnt in contours:
        x, y, w, h = cv2.boundingRect(cnt)
        ty_le_khung = w / float(h)
        if min_size <= w <= max_size and min_size <= h <= max_size and 0.7 <= ty_le_khung <= 1.3:
            hop_vuong_bbox = (x, y, w, h)
            break

    if hop_vuong_bbox is not None:
        hx, hy, hw, hh = hop_vuong_bbox
        x1 = max(0, hx - padding_hop)
        y1 = max(0, hy - padding_hop)
        x2 = min(vung_quet_rong, hx + hw + padding_hop)
        y2 = min(cao, hy + hh + padding_hop)

        vung_dau = anh_dau_dong.crop((x1, y1, x2, y2))
        diem_cat_chu = min(hx + hw + padding_hop + 3, rong - 1)
        vung_van_ban = anh_dong.crop((diem_cat_chu, 0, rong, cao))
    else:
        # Fallback theo tỷ lệ rộng rãi hơn (1.1x chiều cao) tránh cắt xén
        rong_fallback = min(int(cao * 1.1), int(rong * 0.30))
        vung_dau = anh_dong.crop((0, 0, rong_fallback, cao))
        vung_van_ban = anh_dong.crop((rong_fallback, 0, rong, cao))

    return vung_dau, vung_van_ban


def kiem_tra_dau_x_bang_vietocr(
    vung_dau: Image.Image,
    bo_doc_chu: Predictor
) -> dict:
    """
    Dùng trực tiếp VietOCR để đọc ô vuông checkbox:
    - Nếu đọc ra 'x', 'X', hoặc các ký tự dấu chéo -> selected = True
    - Nếu ô trống -> selected = False
    """
    chu_doc_duoc = bo_doc_chu.predict(vung_dau).strip().lower()

    # Các ký tự thường xuất hiện khi có dấu X trong ô vuông
    cac_dau_hieu_x = ["x", "v", "+", "*", "k", "1", "l", "/"]
    selected = any(k in chu_doc_duoc for k in cac_dau_hieu_x)

    return {
        "selected": selected,
        "status": "detected" if selected else "empty",
        "raw_ocr": chu_doc_duoc,
        "mark_type": "X",
    }


def loai_bo_ky_hieu_x_dau_dong(text: str) -> str:
    """Loại bỏ ký tự x bị dính ở đầu dòng nếu có."""
    return re.sub(r"^\s*[xX×]\s*[iìIÌ]?\s*", "", text).strip()


# ==================================================
# OCR MỘT TRANG
# ==================================================

def ocr_mot_trang(
    bo_phat_hien: PaddleOCR,
    bo_doc_chu: Predictor,
    duong_dan_anh: Path,
    thu_muc_debug: Path = None
) -> dict:
    anh_goc = Image.open(duong_dan_anh).convert("RGB")

    # 1. Detection
    ket_qua_phat_hien = bo_phat_hien.ocr(
        str(duong_dan_anh),
        det=True,
        rec=False,
        cls=False
    )

    if not ket_qua_phat_hien or not ket_qua_phat_hien[0]:
        return {
            "file_anh": duong_dan_anh.name,
            "so_trang": int(duong_dan_anh.stem.split("_")[-1]),
            "van_ban_day_du": "",
            "so_dong_nhan_dien": 0,
            "chi_tiet_dong": [],
        }

    # 2. Sắp xếp thứ tự đọc
    danh_sach_bbox = sap_xep_bbox_theo_dong(ket_qua_phat_hien[0])

    # 3. Recognition
    danh_sach_dong = []
    van_ban_day_du = []

    for chi_so, bbox in enumerate(danh_sach_bbox, start=1):
        anh_cat = cat_anh_theo_bbox(anh_goc, bbox, padding=5)
        noi_dung_tho = bo_doc_chu.predict(anh_cat).strip()

        if not noi_dung_tho:
            continue

        noi_dung = noi_dung_tho
        thong_tin_dau_chon = None

        # Kiểm tra dòng Thi vào công lập
        if la_dong_thi_vao_cong_lap(noi_dung_tho):
            vung_dau, vung_van_ban = tach_vung_dau_va_van_ban(anh_cat)

            # Dùng VietOCR nhận diện dấu X
            thong_tin_dau_chon = kiem_tra_dau_x_bang_vietocr(vung_dau, bo_doc_chu)

            # VietOCR đọc lại phần văn bản sau ô vuông
            noi_dung_tach = bo_doc_chu.predict(vung_van_ban).strip()
            if la_dong_thi_vao_cong_lap(noi_dung_tach):
                noi_dung = noi_dung_tach
            else:
                noi_dung = loai_bo_ky_hieu_x_dau_dong(noi_dung_tho)

            # Lưu ảnh debug
            if LUU_ANH_DEBUG and thu_muc_debug is not None:
                thu_muc_debug.mkdir(parents=True, exist_ok=True)
                ten_goc = duong_dan_anh.stem
                vung_dau.save(thu_muc_debug / f"{ten_goc}_dong_{chi_so:03d}_dau.png")
                vung_van_ban.save(thu_muc_debug / f"{ten_goc}_dong_{chi_so:03d}_chu.png")

        if not noi_dung:
            continue

        # Gắn nhãn [X] hoặc [ ] vào văn bản
        if thong_tin_dau_chon is not None:
            dong_tong_hop = f"[X] {noi_dung}" if thong_tin_dau_chon["selected"] else f"[ ] {noi_dung}"
        else:
            dong_tong_hop = noi_dung

        chi_tiet = {
            "text": noi_dung,
            "bbox": bbox,
        }
        if thong_tin_dau_chon is not None:
            chi_tiet["mark_detection"] = thong_tin_dau_chon

        danh_sach_dong.append(chi_tiet)
        van_ban_day_du.append(dong_tong_hop)

    return {
        "file_anh": duong_dan_anh.name,
        "so_trang": int(duong_dan_anh.stem.split("_")[-1]),
        "van_ban_day_du": "\n".join(van_ban_day_du),
        "so_dong_nhan_dien": len(danh_sach_dong),
        "chi_tiet_dong": danh_sach_dong,
    }


# ==================================================
# OCR TẤT CẢ TRANG
# ==================================================

def ocr_tat_ca_trang(
    thu_muc_anh: Path = DUONG_DAN_ANH,
    thu_muc_luu: Path = DUONG_DAN_OCR
) -> list[Path]:
    thu_muc_luu.mkdir(parents=True, exist_ok=True)

    # Chạy toàn bộ 43 ảnh
    danh_sach_anh = sorted(thu_muc_anh.glob("trang_*.png"))
    danh_sach_anh = [p for p in danh_sach_anh if p.exists()]

    if not danh_sach_anh:
        print(f"[LỖI] Không tìm thấy ảnh trong: {thu_muc_anh}")
        return []

    print(f"[2/5] Đang OCR {len(danh_sach_anh)} trang...")
    print("       Phương pháp: PaddleOCR Detection + VietOCR Recognition (kèm nhận diện [X])")

    print("       Đang tải PaddleOCR detector...", end="")
    bo_phat_hien = khoi_tao_paddle_detector()
    print(" ✓")

    print("       Đang tải VietOCR (vgg_transformer)...", end="")
    bo_doc_chu = khoi_tao_vietocr(thiet_bi=THIET_BI_VIETOCR)
    print(f" ✓ ({THIET_BI_VIETOCR.upper()})\n")

    danh_sach_ket_qua = []
    thu_muc_debug = thu_muc_luu / "debug_dau_chon"

    for chi_so, duong_dan_anh in enumerate(danh_sach_anh, start=1):
        print(f"       Trang {chi_so}/{len(danh_sach_anh)}: {duong_dan_anh.name}", end="")

        ket_qua = ocr_mot_trang(
            bo_phat_hien,
            bo_doc_chu,
            duong_dan_anh,
            thu_muc_debug=thu_muc_debug
        )

        ten_file_json = f"ocr_trang_{ket_qua['so_trang']:03d}.json"
        duong_dan_json = thu_muc_luu / ten_file_json

        with open(duong_dan_json, "w", encoding="utf-8") as f:
            json.dump(ket_qua, f, ensure_ascii=False, indent=2)

        print(f" → ✓ ({ket_qua['so_dong_nhan_dien']} dòng)")

        # In trạng thái lựa chọn dấu X
        for dong in ket_qua["chi_tiet_dong"]:
            if "mark_detection" in dong:
                print(f"          Lựa chọn: {dong['text']}")
                print(f"          Trạng thái [X]: {dong['mark_detection']['status']} (ký tự đọc: '{dong['mark_detection']['raw_ocr']}')")

        danh_sach_ket_qua.append(duong_dan_json)

    print(f"\n       ✓ Đã lưu {len(danh_sach_ket_qua)} file OCR tại: {thu_muc_luu}")
    if LUU_ANH_DEBUG:
        print(f"       Ảnh debug dấu chọn: {thu_muc_debug}")

    return danh_sach_ket_qua


# ==================================================
# MAIN
# ==================================================

if __name__ == "__main__":
    ket_qua = ocr_tat_ca_trang()
    print(f"\nTổng file OCR: {len(ket_qua)}")
