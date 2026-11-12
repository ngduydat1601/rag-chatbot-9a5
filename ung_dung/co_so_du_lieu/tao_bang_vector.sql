-- ==============================================================================
-- TẠO BẢNG VECTOR SEARCH BẰNG PGVECTOR
-- Lưu các đoạn tài liệu đã embedding để tìm kiếm theo ý nghĩa
-- ==============================================================================

DROP TABLE IF EXISTS tai_lieu_vector CASCADE;

CREATE TABLE tai_lieu_vector (
    id SERIAL PRIMARY KEY,

    -- Nội dung gốc
    ma_doan VARCHAR(50) NOT NULL UNIQUE,
    tieu_de VARCHAR(200) NOT NULL,
    noi_dung TEXT NOT NULL,
    nguon VARCHAR(200),

    -- Vector embedding (768 chiều — kích thước của Gemini text-embedding-004)
    vector_noi_dung vector(768) NOT NULL,

    -- Thời gian tạo
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index HNSW để tìm kiếm vector nhanh
-- (cosine distance: đo độ tương đồng ý nghĩa giữa 2 đoạn văn)
CREATE INDEX idx_vector_hnsw ON tai_lieu_vector
    USING hnsw (vector_noi_dung vector_cosine_ops);