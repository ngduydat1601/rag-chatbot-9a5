-- ==============================================================================
-- KỊCH BẢN TẠO CƠ SỞ DỮ LIỆU BẰNG SQL THUẦN (POSTGRESQL)
-- Dự án: Tra cứu phiếu báo thi vào lớp 10 THPT (Lớp 9A5 - THCS Chu Văn An)
-- ==============================================================================

-- 1. Kích hoạt các extension cần thiết
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Xóa các bảng cũ nếu đã tồn tại (theo thứ tự quan hệ bảng con trước, bảng cha sau)
DROP TABLE IF EXISTS nguyen_vong_chuyen CASCADE;
DROP TABLE IF EXISTS tuyen_sinh_chuyen CASCADE;
DROP TABLE IF EXISTS lich_thi CASCADE;
DROP TABLE IF EXISTS nguyen_vong CASCADE;
DROP TABLE IF EXISTS thi_sinh CASCADE;

-- ==============================================================================
-- BẢNG 1: thi_sinh — Thông tin cá nhân và đăng ký thi chính
-- ==============================================================================
CREATE TABLE thi_sinh (
    id SERIAL PRIMARY KEY,
    
    -- Thông tin cá nhân
    ho_ten VARCHAR(100) NOT NULL,
    ngay_sinh VARCHAR(20) NOT NULL,
    gioi_tinh VARCHAR(10) NOT NULL,
    dan_toc VARCHAR(30) NOT NULL,
    noi_sinh VARCHAR(100) NOT NULL,
    
    -- Thông tin học tập
    ma_hoc_sinh VARCHAR(20) NOT NULL UNIQUE,
    lop VARCHAR(10) NOT NULL,
    co_so_giao_duc VARCHAR(100) NOT NULL,
    
    -- Đăng ký dự thi
    thi_cong_lap BOOLEAN NOT NULL DEFAULT TRUE,
    so_luong_nguyen_vong INTEGER NOT NULL,
    ngoai_ngu_hoc VARCHAR(20),
    ngoai_ngu_thi VARCHAR(20),
    diem_uu_tien REAL DEFAULT 0,
    diem_khuyen_khich REAL DEFAULT 0,
    
    -- Thông tin phòng thi & điểm thi
    diem_thi VARCHAR(200),
    dia_chi_diem_thi TEXT,
    so_bao_danh VARCHAR(20) NOT NULL UNIQUE,
    phong_thi VARCHAR(10),
    
    -- Thông tin tập trung làm thủ tục dự thi
    thoi_gian_tap_trung VARCHAR(100) DEFAULT '9h00 ngày 29/5/2026',
    
    -- Truy xuất nguồn gốc
    so_trang_nguon INTEGER,
    trang_thai_kiem_duyet VARCHAR(20) DEFAULT 'verified',
    tai_lieu_nguon VARCHAR(100) DEFAULT '9A5.pdf',
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- BẢNG 2: nguyen_vong — Nguyện vọng không chuyên (NV1, NV2, NV3)
-- ==============================================================================
CREATE TABLE nguyen_vong (
    id SERIAL PRIMARY KEY,
    thi_sinh_id INTEGER NOT NULL REFERENCES thi_sinh(id) ON DELETE CASCADE,
    thu_tu INTEGER NOT NULL,
    ten_truong VARCHAR(200) NOT NULL,
    CONSTRAINT uq_nguyen_vong_thu_tu UNIQUE (thi_sinh_id, thu_tu)
);

-- ==============================================================================
-- BẢNG 3: lich_thi — Lịch thi các môn (Ngữ văn, Ngoại ngữ, Toán)
-- ==============================================================================
CREATE TABLE lich_thi (
    id SERIAL PRIMARY KEY,
    thi_sinh_id INTEGER NOT NULL REFERENCES thi_sinh(id) ON DELETE CASCADE,
    ten_mon VARCHAR(50) NOT NULL,
    buoi_thi VARCHAR(20) NOT NULL,
    ngay_thi VARCHAR(20) NOT NULL,
    CONSTRAINT uq_lich_thi_mon UNIQUE (thi_sinh_id, ten_mon)
);

-- ==============================================================================
-- BẢNG 4: tuyen_sinh_chuyen — Thông tin thi môn chuyên (nếu có)
-- ==============================================================================
CREATE TABLE tuyen_sinh_chuyen (
    id SERIAL PRIMARY KEY,
    thi_sinh_id INTEGER NOT NULL UNIQUE REFERENCES thi_sinh(id) ON DELETE CASCADE,
    mon_thi_chuyen VARCHAR(50),
    ngay_thi_chuyen VARCHAR(30),
    diem_thi_chuyen VARCHAR(200),
    phong_thi_chuyen VARCHAR(10)
);

-- ==============================================================================
-- BẢNG 5: nguyen_vong_chuyen — Danh sách các NV chuyên
-- ==============================================================================
CREATE TABLE nguyen_vong_chuyen (
    id SERIAL PRIMARY KEY,
    tuyen_sinh_chuyen_id INTEGER NOT NULL REFERENCES tuyen_sinh_chuyen(id) ON DELETE CASCADE,
    thu_tu INTEGER NOT NULL,
    truong_chuyen VARCHAR(200) NOT NULL,
    lop_chuyen VARCHAR(50) NOT NULL,
    CONSTRAINT uq_nv_chuyen_thu_tu UNIQUE (tuyen_sinh_chuyen_id, thu_tu)
);

-- ==============================================================================
-- CÁC CHỈ MỤC (INDEX) — Tối ưu tốc độ tìm kiếm tra cứu
-- ==============================================================================
-- 1. Index tìm nhanh theo SBD và Mã học sinh
CREATE INDEX idx_thi_sinh_sbd ON thi_sinh(so_bao_danh);
CREATE INDEX idx_thi_sinh_ma_hs ON thi_sinh(ma_hoc_sinh);

-- 2. Index tìm kiếm theo điểm thi
CREATE INDEX idx_thi_sinh_diem_thi ON thi_sinh(diem_thi);

-- 3. GIN Trigram Index — Tối ưu tìm kiếm mờ (fuzzy search) họ tên tiếng Việt
CREATE INDEX idx_thi_sinh_ho_ten_trgm ON thi_sinh USING gin (ho_ten gin_trgm_ops);
