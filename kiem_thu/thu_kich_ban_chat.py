"""
Kịch bản kiểm thử toàn diện các Use Case cho Chatbot Tra Cứu Phiếu Báo Thi 9A5.

Kiểm thử trực tiếp qua REST API (http://localhost:8000/api/chat).
Bao gồm đầy đủ 8 nhóm tình huống của một Chatbot hoàn chỉnh:
  1. Chào hỏi xã giao & Giới thiệu vai trò
  2. Tra cứu cá nhân (SQL 1-turn: tên không dấu, SBD, mã HS)
  3. Hội thoại ngữ cảnh đa lượt (Multi-turn Contextual)
  4. Thống kê & Tổng hợp (Dynamic Text-to-SQL)
  5. Quy định & Hướng dẫn chung (Vector Search)
  6. Xử lý đính chính / Làm rõ từ người dùng
  7. Dữ liệu không tồn tại (Edge Case / Not Found)
  8. Câu hỏi ngoài phạm vi (Guardrails / Out-of-domain)
"""

import sys
import json
import urllib.request
import urllib.error
import time

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

URL_API = "http://localhost:8000/api/chat"


def goi_api_chat(cau_hoi: str, session_id: str = "test_mac_dinh") -> dict:
    """Gửi câu hỏi tới API chat và trả về JSON phản hồi."""
    du_lieu = json.dumps({
        "cau_hoi": cau_hoi,
        "session_id": session_id,
    }).encode("utf-8")

    req = urllib.request.Request(
        URL_API,
        data=du_lieu,
        headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        noi_dung_loi = e.read().decode("utf-8")
        return {"thanh_cong": False, "loi": f"HTTP {e.code}: {noi_dung_loi}"}
    except Exception as e:
        return {"thanh_cong": False, "loi": str(e)}


def in_ket_qua(stt: str, ten_ca: str, cau_hoi: str, phan_hoi: dict, tieu_chi_danh_gia: list[str]) -> bool:
    """In chi tiết câu hỏi, câu trả lời và đánh giá xem câu trả lời có đạt không."""
    print(f"\n{'='*75}")
    print(f"👉 [{stt}] {ten_ca}")
    print(f"❓ Câu hỏi: \"{cau_hoi}\"")
    print(f"{'-'*75}")

    if not phan_hoi.get("thanh_cong", False):
        print(f"❌ LỖI GỌI API: {phan_hoi.get('loi', 'Không rõ')}")
        return False

    cau_tra_loi = phan_hoi.get("cau_tra_loi", "").strip()
    print(f"🤖 Chatbot:\n{cau_tra_loi}\n")

    # Đánh giá dựa trên từ khóa mong đợi
    cau_tra_loi_lower = cau_tra_loi.lower()
    cac_tu_khuyet = [tk for tk in tieu_chi_danh_gia if tk.lower() not in cau_tra_loi_lower]

    if not cac_tu_khuyet:
        print(f"✅ ĐẠT (Đầy đủ tiêu chí mong đợi: {', '.join(tieu_chi_danh_gia)})")
        return True
    else:
        print(f"⚠️ CẦN XEM LẠI (Thiếu từ khóa/ý chính: {', '.join(cac_tu_khuyet)})")
        return False


def chay_bo_kiem_thu():
    print("=" * 75)
    print(" BẮT ĐẦU KIỂM THỬ TOÀN DIỆN CÁC USE CASE CHO CHATBOT 9A5")
    print("=" * 75)

    tong_so = 0
    so_dat = 0

    # ─────────────────────────────────────────────────────────────
    # NHÓM 1: Chào hỏi & Nhận diện vai trò
    # ─────────────────────────────────────────────────────────────
    tong_so += 1
    kq = goi_api_chat("Xin chào bạn, bạn là ai và giúp được gì cho tôi?", session_id="phien_chao_hoi")
    if in_ket_qua("Case 1", "Chào hỏi & Giới thiệu vai trò",
                  "Xin chào bạn, bạn là ai và giúp được gì cho tôi?", kq, ["phiếu báo thi", "9A5"]):
        so_dat += 1
    time.sleep(1)

    # ─────────────────────────────────────────────────────────────
    # NHÓM 2: Tra cứu thông tin cá nhân (SQL 1-turn)
    # ─────────────────────────────────────────────────────────────
    tong_so += 1
    kq = goi_api_chat("sbd cua linh an la bao nhieu", session_id="phien_ca_nhan_1")
    if in_ket_qua("Case 2.1", "Tra cứu theo tên không dấu (unaccent)",
                  "sbd cua linh an la bao nhieu", kq, ["204001"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Thí sinh có số báo danh 204001 thi ở phòng số mấy?", session_id="phien_ca_nhan_2")
    if in_ket_qua("Case 2.2", "Tra cứu theo Số Báo Danh (SBD)",
                  "Thí sinh có số báo danh 204001 thi ở phòng số mấy?", kq, ["01"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Mã học sinh 0118117832 là của bạn nào?", session_id="phien_ca_nhan_3")
    if in_ket_qua("Case 2.3", "Tra cứu theo Mã học sinh (10 chữ số)",
                  "Mã học sinh 0118117832 là của bạn nào?", kq, ["Linh An"]):
        so_dat += 1
    time.sleep(1)

    # ─────────────────────────────────────────────────────────────
    # NHÓM 3: Hội thoại ngữ cảnh đa lượt (Multi-turn Contextual)
    # ─────────────────────────────────────────────────────────────
    phien_ngu_canh = f"phien_ngu_canh_{int(time.time())}"

    tong_so += 1
    kq = goi_api_chat("Bạn Đỗ Hoàng Bảo Anh thi ở trường nào?", session_id=phien_ngu_canh)
    if in_ket_qua("Case 3.1", "Lượt 1: Thiết lập đối tượng (Bảo Anh)",
                  "Bạn Đỗ Hoàng Bảo Anh thi ở trường nào?", kq, ["Việt Nam-Ba Lan"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Bạn đó có bao nhiêu nguyện vọng?", session_id=phien_ngu_canh)
    if in_ket_qua("Case 3.2", "Lượt 2: Tham chiếu 'bạn đó' (Anaphora Resolution)",
                  "Bạn đó có bao nhiêu nguyện vọng?", kq, ["3"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Đó là những trường nào?", session_id=phien_ngu_canh)
    if in_ket_qua("Case 3.3", "Lượt 3: Tham chiếu sâu 'đó là những trường nào'",
                  "Đó là những trường nào?", kq, ["Việt Nam-Ba Lan", "Hoàng Văn Thụ", "Đoàn Kết"]):
        so_dat += 1
    time.sleep(1)

    # ─────────────────────────────────────────────────────────────
    # NHÓM 4: Thống kê & Tổng hợp (Dynamic Text-to-SQL)
    # ─────────────────────────────────────────────────────────────
    tong_so += 1
    kq = goi_api_chat("Lớp 9A5 có tổng cộng bao nhiêu bạn nữ?", session_id="phien_thong_ke_1")
    if in_ket_qua("Case 4.1", "Đếm có điều kiện (COUNT + WHERE)",
                  "Lớp 9A5 có tổng cộng bao nhiêu bạn nữ?", kq, ["20"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Tổng các bạn thi tại THPT Nguyễn Quốc Trinh là bao nhiêu?", session_id="phien_thong_ke_2")
    if in_ket_qua("Case 4.2", "Thống kê theo địa điểm thi",
                  "Tổng các bạn thi tại THPT Nguyễn Quốc Trinh là bao nhiêu?", kq, ["8"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Những bạn nào có điểm ưu tiên lớn hơn 0?", session_id="phien_thong_ke_3")
    if in_ket_qua("Case 4.3", "Lọc điều kiện nâng cao (Điểm ưu tiên > 0)",
                  "Những bạn nào có điểm ưu tiên lớn hơn 0?", kq, ["Như Quỳnh"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Có bạn nào đăng ký thi chuyên không, bạn ấy thi môn gì?", session_id="phien_thong_ke_4")
    if in_ket_qua("Case 4.4", "Tra cứu bảng thi chuyên (JOIN)",
                  "Có bạn nào đăng ký thi chuyên không, bạn ấy thi môn gì?", kq, ["Phùng Minh Vũ", "Tin"]):
        so_dat += 1
    time.sleep(1)

    # ─────────────────────────────────────────────────────────────
    # NHÓM 5: Quy định & Hướng dẫn chung (Vector Search)
    # ─────────────────────────────────────────────────────────────
    tong_so += 1
    kq = goi_api_chat("Buổi sáng mấy giờ thí sinh phải có mặt tại phòng thi?", session_id="phien_vector_1")
    if in_ket_qua("Case 5.1", "Quy định giờ giấc dự thi buổi sáng",
                  "Buổi sáng mấy giờ thí sinh phải có mặt tại phòng thi?", kq, ["7h00"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Bao giờ thí sinh phải đến trường làm thủ tục dự thi?", session_id="phien_vector_2")
    if in_ket_qua("Case 5.2", "Quy định thời gian tập trung làm thủ tục",
                  "Bao giờ thí sinh phải đến trường làm thủ tục dự thi?", kq, ["9h00", "29/5"]):
        so_dat += 1
    time.sleep(1)

    # ─────────────────────────────────────────────────────────────
    # NHÓM 6: Xử lý đính chính / Làm rõ từ người dùng
    # ─────────────────────────────────────────────────────────────
    phien_dinh_chinh = f"phien_dinh_chinh_{int(time.time())}"

    tong_so += 1
    kq = goi_api_chat("Thời gian thi của Trịnh Đức Anh?", session_id=phien_dinh_chinh)
    if in_ket_qua("Case 6.1", "Lượt 1: Hỏi thời gian thi của học sinh",
                  "Thời gian thi của Trịnh Đức Anh?", kq, ["30/5", "31/5"]):
        so_dat += 1
    time.sleep(1)

    tong_so += 1
    kq = goi_api_chat("Không phải thời gian tập trung mà là lịch thi từng môn cụ thể cơ", session_id=phien_dinh_chinh)
    if in_ket_qua("Case 6.2", "Lượt 2: Người dùng đính chính phân biệt 'tập trung' vs 'thi môn'",
                  "Không phải thời gian tập trung mà là lịch thi từng môn cụ thể cơ", kq, ["Ngữ văn", "Ngoại ngữ", "Toán"]):
        so_dat += 1
    time.sleep(1)

    # ─────────────────────────────────────────────────────────────
    # NHÓM 7: Dữ liệu không tồn tại (Edge Case / Not Found)
    # ─────────────────────────────────────────────────────────────
    tong_so += 1
    kq = goi_api_chat("Số báo danh của bạn Nguyễn Văn Fake là bao nhiêu?", session_id="phien_not_found")
    if in_ket_qua("Case 7", "Dữ liệu thí sinh không tồn tại trong lớp",
                  "Số báo danh của bạn Nguyễn Văn Fake là bao nhiêu?", kq, ["không tìm thấy", "không có"]):
        so_dat += 1
    time.sleep(1)

    # ─────────────────────────────────────────────────────────────
    # NHÓM 8: Câu hỏi ngoài phạm vi (Guardrails / Out-of-domain)
    # ─────────────────────────────────────────────────────────────
    tong_so += 1
    kq = goi_api_chat("Hôm nay thời tiết Hà Nội thế nào, có mưa không?", session_id="phien_ngoai_pham_vi")
    if in_ket_qua("Case 8", "Câu hỏi ngoài phạm vi nghiệp vụ",
                  "Hôm nay thời tiết Hà Nội thế nào, có mưa không?", kq, ["chỉ có thể", "liên quan", "phiếu báo thi"]):
        so_dat += 1

    # ─────────────────────────────────────────────────────────────
    # Tổng kết
    # ─────────────────────────────────────────────────────────────
    print(f"\n{'='*75}")
    print(f"📊 KẾT QUẢ TỔNG HỢP: {so_dat}/{tong_so} trường hợp ĐẠT ({so_dat/tong_so*100:.1f}%)")
    print(f"{'='*75}")


if __name__ == "__main__":
    chay_bo_kiem_thu()
