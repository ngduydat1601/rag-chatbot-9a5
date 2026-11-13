--
-- PostgreSQL database dump
--

\restrict BDCSHsu3Cp74xeOUhGfwFRyKtBQSc7Z9SSQhH02VmIwDBHa3jSvNksdUJx9Mn4b

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg12+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg12+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: lich_thi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lich_thi (
    id integer NOT NULL,
    thi_sinh_id integer NOT NULL,
    ten_mon character varying(50) NOT NULL,
    buoi_thi character varying(20) NOT NULL,
    ngay_thi character varying(20) NOT NULL
);


--
-- Name: COLUMN lich_thi.ten_mon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.lich_thi.ten_mon IS 'Tên môn thi (Ngữ văn, Ngoại ngữ, Toán)';


--
-- Name: COLUMN lich_thi.buoi_thi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.lich_thi.buoi_thi IS 'Buổi thi (Sáng, Chiều)';


--
-- Name: COLUMN lich_thi.ngay_thi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.lich_thi.ngay_thi IS 'Ngày thi (30/5, 31/5)';


--
-- Name: lich_thi_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lich_thi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lich_thi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lich_thi_id_seq OWNED BY public.lich_thi.id;


--
-- Name: nguyen_vong; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nguyen_vong (
    id integer NOT NULL,
    thi_sinh_id integer NOT NULL,
    thu_tu integer NOT NULL,
    ten_truong character varying(200) NOT NULL
);


--
-- Name: COLUMN nguyen_vong.thu_tu; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nguyen_vong.thu_tu IS 'Thứ tự nguyện vọng xét tuyển (1 = NV1, 2 = NV2, 3 = NV3)';


--
-- Name: COLUMN nguyen_vong.ten_truong; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nguyen_vong.ten_truong IS 'Tên trường THPT đăng ký nguyện vọng';


--
-- Name: nguyen_vong_chuyen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nguyen_vong_chuyen (
    id integer NOT NULL,
    tuyen_sinh_chuyen_id integer NOT NULL,
    thu_tu integer NOT NULL,
    truong_chuyen character varying(200) NOT NULL,
    lop_chuyen character varying(50) NOT NULL
);


--
-- Name: nguyen_vong_chuyen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nguyen_vong_chuyen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nguyen_vong_chuyen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nguyen_vong_chuyen_id_seq OWNED BY public.nguyen_vong_chuyen.id;


--
-- Name: nguyen_vong_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nguyen_vong_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nguyen_vong_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nguyen_vong_id_seq OWNED BY public.nguyen_vong.id;


--
-- Name: tai_lieu_vector; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tai_lieu_vector (
    id integer NOT NULL,
    ma_doan character varying(50) NOT NULL,
    tieu_de character varying(200) NOT NULL,
    noi_dung text NOT NULL,
    nguon character varying(200),
    vector_noi_dung public.vector(768) NOT NULL,
    ngay_tao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: tai_lieu_vector_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tai_lieu_vector_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tai_lieu_vector_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tai_lieu_vector_id_seq OWNED BY public.tai_lieu_vector.id;


--
-- Name: thi_sinh; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.thi_sinh (
    id integer NOT NULL,
    ho_ten character varying(100) NOT NULL,
    ngay_sinh character varying(20) NOT NULL,
    gioi_tinh character varying(10) NOT NULL,
    dan_toc character varying(30) NOT NULL,
    noi_sinh character varying(100) NOT NULL,
    ma_hoc_sinh character varying(20) NOT NULL,
    lop character varying(10) NOT NULL,
    co_so_giao_duc character varying(100) NOT NULL,
    thi_cong_lap boolean DEFAULT true NOT NULL,
    so_luong_nguyen_vong integer NOT NULL,
    ngoai_ngu_hoc character varying(20),
    ngoai_ngu_thi character varying(20),
    diem_uu_tien real DEFAULT 0,
    diem_khuyen_khich real DEFAULT 0,
    diem_thi character varying(200),
    dia_chi_diem_thi text,
    so_bao_danh character varying(20) NOT NULL,
    phong_thi character varying(10),
    thoi_gian_tap_trung character varying(100) DEFAULT '9h00 ng??y 29/5/2026'::character varying,
    so_trang_nguon integer,
    trang_thai_kiem_duyet character varying(20) DEFAULT 'verified'::character varying,
    tai_lieu_nguon character varying(100) DEFAULT '9A5.pdf'::character varying,
    ngay_tao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: COLUMN thi_sinh.ho_ten; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thi_sinh.ho_ten IS 'Họ tên thí sinh (lưu CHỮ IN HOA có dấu, ví dụ: ĐẶNG LINH AN). Khi tìm kiếm theo tên, dùng unaccent(ho_ten) ILIKE unaccent(''%...%'')';


--
-- Name: COLUMN thi_sinh.diem_thi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thi_sinh.diem_thi IS 'Tên trường THPT làm điểm thi (ví dụ: THPT Nguyễn Quốc Trinh)';


--
-- Name: COLUMN thi_sinh.so_bao_danh; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thi_sinh.so_bao_danh IS 'Số báo danh 6 chữ số (ví dụ: 204001)';


--
-- Name: COLUMN thi_sinh.thoi_gian_tap_trung; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.thi_sinh.thoi_gian_tap_trung IS 'Thời gian tập trung làm thủ tục thi (9h00 ngày 29/5/2026)';


--
-- Name: thi_sinh_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.thi_sinh_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thi_sinh_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.thi_sinh_id_seq OWNED BY public.thi_sinh.id;


--
-- Name: tuyen_sinh_chuyen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tuyen_sinh_chuyen (
    id integer NOT NULL,
    thi_sinh_id integer NOT NULL,
    mon_thi_chuyen character varying(50),
    ngay_thi_chuyen character varying(30),
    diem_thi_chuyen character varying(200),
    phong_thi_chuyen character varying(10)
);


--
-- Name: COLUMN tuyen_sinh_chuyen.mon_thi_chuyen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tuyen_sinh_chuyen.mon_thi_chuyen IS 'Môn thi chuyên (ví dụ: Tin)';


--
-- Name: tuyen_sinh_chuyen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tuyen_sinh_chuyen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tuyen_sinh_chuyen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tuyen_sinh_chuyen_id_seq OWNED BY public.tuyen_sinh_chuyen.id;


--
-- Name: lich_thi id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lich_thi ALTER COLUMN id SET DEFAULT nextval('public.lich_thi_id_seq'::regclass);


--
-- Name: nguyen_vong id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong ALTER COLUMN id SET DEFAULT nextval('public.nguyen_vong_id_seq'::regclass);


--
-- Name: nguyen_vong_chuyen id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong_chuyen ALTER COLUMN id SET DEFAULT nextval('public.nguyen_vong_chuyen_id_seq'::regclass);


--
-- Name: tai_lieu_vector id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tai_lieu_vector ALTER COLUMN id SET DEFAULT nextval('public.tai_lieu_vector_id_seq'::regclass);


--
-- Name: thi_sinh id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thi_sinh ALTER COLUMN id SET DEFAULT nextval('public.thi_sinh_id_seq'::regclass);


--
-- Name: tuyen_sinh_chuyen id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tuyen_sinh_chuyen ALTER COLUMN id SET DEFAULT nextval('public.tuyen_sinh_chuyen_id_seq'::regclass);


--
-- Data for Name: lich_thi; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.lich_thi VALUES (1, 1, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (2, 1, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (3, 1, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (4, 2, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (5, 2, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (6, 2, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (7, 3, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (8, 3, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (9, 3, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (10, 4, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (11, 4, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (12, 4, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (13, 5, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (14, 5, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (15, 5, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (16, 6, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (17, 6, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (18, 6, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (19, 7, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (20, 7, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (21, 7, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (22, 8, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (23, 8, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (24, 8, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (25, 9, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (26, 9, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (27, 9, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (28, 10, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (29, 10, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (30, 10, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (31, 11, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (32, 11, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (33, 11, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (34, 12, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (35, 12, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (36, 12, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (37, 13, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (38, 13, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (39, 13, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (40, 14, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (41, 14, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (42, 14, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (43, 15, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (44, 15, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (45, 15, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (46, 16, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (47, 16, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (48, 16, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (49, 17, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (50, 17, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (51, 17, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (52, 18, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (53, 18, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (54, 18, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (55, 19, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (56, 19, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (57, 19, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (58, 20, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (59, 20, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (60, 20, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (61, 21, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (62, 21, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (63, 21, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (64, 22, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (65, 22, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (66, 22, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (67, 23, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (68, 23, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (69, 23, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (70, 24, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (71, 24, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (72, 24, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (73, 25, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (74, 25, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (75, 25, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (76, 26, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (77, 26, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (78, 26, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (79, 27, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (80, 27, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (81, 27, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (82, 28, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (83, 28, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (84, 28, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (85, 29, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (86, 29, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (87, 29, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (88, 30, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (89, 30, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (90, 30, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (91, 31, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (92, 31, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (93, 31, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (94, 32, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (95, 32, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (96, 32, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (97, 33, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (98, 33, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (99, 33, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (100, 34, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (101, 34, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (102, 34, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (103, 35, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (104, 35, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (105, 35, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (106, 36, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (107, 36, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (108, 36, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (109, 37, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (110, 37, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (111, 37, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (112, 38, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (113, 38, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (114, 38, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (115, 39, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (116, 39, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (117, 39, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (118, 40, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (119, 40, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (120, 40, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (121, 41, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (122, 41, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (123, 41, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (124, 42, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (125, 42, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (126, 42, 'Toán', 'Sáng', '31/5');
INSERT INTO public.lich_thi VALUES (127, 43, 'Ngữ văn', 'Sáng', '30/5');
INSERT INTO public.lich_thi VALUES (128, 43, 'Ngoại ngữ', 'Chiều', '30/5');
INSERT INTO public.lich_thi VALUES (129, 43, 'Toán', 'Sáng', '31/5');


--
-- Data for Name: nguyen_vong; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.nguyen_vong VALUES (1, 1, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (2, 1, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (3, 1, 3, 'Vân Tảo');
INSERT INTO public.nguyen_vong VALUES (4, 2, 1, 'Đỗ Mười');
INSERT INTO public.nguyen_vong VALUES (5, 2, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (6, 2, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (7, 3, 1, 'Việt Nam-Ba Lan');
INSERT INTO public.nguyen_vong VALUES (8, 3, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (9, 3, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (10, 4, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (11, 4, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (12, 4, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (13, 5, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (14, 5, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (15, 5, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (16, 6, 1, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (17, 6, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (18, 6, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (19, 7, 1, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (20, 7, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (21, 7, 3, 'Vân Tảo');
INSERT INTO public.nguyen_vong VALUES (22, 8, 1, 'Việt Nam-Ba Lan');
INSERT INTO public.nguyen_vong VALUES (23, 8, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (24, 8, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (25, 9, 1, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (26, 9, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (27, 9, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (28, 10, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (29, 10, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (30, 10, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (31, 11, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (32, 11, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (33, 11, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (34, 12, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (35, 12, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (36, 12, 3, 'Vân Tảo');
INSERT INTO public.nguyen_vong VALUES (37, 13, 1, 'Việt Nam-Ba Lan');
INSERT INTO public.nguyen_vong VALUES (38, 13, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (39, 13, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (40, 14, 1, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (41, 14, 2, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (42, 14, 3, 'Đại Cường');
INSERT INTO public.nguyen_vong VALUES (43, 15, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (44, 15, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (45, 15, 3, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (46, 16, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (47, 16, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (48, 16, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (49, 17, 1, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (50, 17, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (51, 17, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (52, 18, 1, 'Đỗ Mười');
INSERT INTO public.nguyen_vong VALUES (53, 18, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (54, 18, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (55, 19, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (56, 19, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (57, 19, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (58, 20, 1, 'Thạch Bàn');
INSERT INTO public.nguyen_vong VALUES (59, 20, 2, 'Nguyễn Văn Cừ');
INSERT INTO public.nguyen_vong VALUES (60, 20, 3, 'Phúc Lợi');
INSERT INTO public.nguyen_vong VALUES (61, 21, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (62, 21, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (63, 21, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (64, 22, 1, 'Đỗ Mười');
INSERT INTO public.nguyen_vong VALUES (65, 22, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (66, 22, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (67, 23, 1, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (68, 23, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (69, 23, 3, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (70, 24, 1, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (71, 24, 2, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (72, 24, 3, 'Bất Bạt');
INSERT INTO public.nguyen_vong VALUES (73, 25, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (74, 25, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (75, 25, 3, 'Đan Phượng');
INSERT INTO public.nguyen_vong VALUES (76, 26, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (77, 26, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (78, 26, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (79, 27, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (80, 27, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (81, 27, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (82, 28, 1, 'Thường Tín');
INSERT INTO public.nguyen_vong VALUES (83, 28, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (84, 28, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (85, 29, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (86, 29, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (87, 29, 3, 'Vân Tảo');
INSERT INTO public.nguyen_vong VALUES (88, 30, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (89, 30, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (90, 30, 3, 'Đan Phượng');
INSERT INTO public.nguyen_vong VALUES (91, 31, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (92, 31, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (93, 31, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (94, 32, 1, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (95, 32, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (96, 32, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (97, 33, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (98, 33, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (99, 33, 3, 'Tô Hiệu-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (100, 34, 1, 'Đỗ Mười');
INSERT INTO public.nguyen_vong VALUES (101, 34, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (102, 34, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (103, 35, 1, 'Việt Nam-Ba Lan');
INSERT INTO public.nguyen_vong VALUES (104, 35, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (105, 35, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (106, 36, 1, 'Việt Nam-Ba Lan');
INSERT INTO public.nguyen_vong VALUES (107, 36, 2, 'Đỗ Mười');
INSERT INTO public.nguyen_vong VALUES (108, 36, 3, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (109, 37, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (110, 37, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (111, 37, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (112, 38, 1, 'Trương Định');
INSERT INTO public.nguyen_vong VALUES (113, 38, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (114, 38, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (115, 39, 1, 'Việt Nam-Ba Lan');
INSERT INTO public.nguyen_vong VALUES (116, 39, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (117, 39, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (118, 40, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (119, 40, 2, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (120, 40, 3, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (121, 41, 1, 'Nguyễn Quốc Trinh');
INSERT INTO public.nguyen_vong VALUES (122, 41, 2, 'Nguyễn Trãi-Thường Tín');
INSERT INTO public.nguyen_vong VALUES (123, 41, 3, 'Lý Tử Tấn');
INSERT INTO public.nguyen_vong VALUES (124, 42, 1, 'Đỗ Mười');
INSERT INTO public.nguyen_vong VALUES (125, 42, 2, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (126, 42, 3, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (127, 43, 1, 'Ngọc Hồi');
INSERT INTO public.nguyen_vong VALUES (128, 43, 2, 'Đông Mỹ');
INSERT INTO public.nguyen_vong VALUES (129, 43, 3, 'Nguyễn Trãi-Thường Tín');


--
-- Data for Name: nguyen_vong_chuyen; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.nguyen_vong_chuyen VALUES (1, 1, 1, 'Chuyên Sơn Tây', 'Tin/1');
INSERT INTO public.nguyen_vong_chuyen VALUES (2, 1, 2, 'Chuyên Nguyễn Huệ', 'Tin/2');


--
-- Data for Name: tai_lieu_vector; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tai_lieu_vector VALUES (1, 'gioi_thieu', 'Giới thiệu phiếu báo thi', 'Phiếu báo thi vào lớp 10 THPT năm học 2026-2027. Được cấp bởi trường THCS Chu Văn An, thuộc UBND Phường Yên Sở, theo ủy quyền của Giám đốc Sở Giáo dục và Đào tạo Hà Nội. Phiếu này báo cho thí sinh biết các thông tin cần thiết để dự kỳ thi tuyển sinh vào lớp 10 THPT công lập tại Hà Nội.', 'Phần đầu phiếu báo thi, tất cả các trang', '[-0.016190944,-0.012566219,-0.005485316,-0.052017108,-0.025531495,0.011652505,-0.022383146,-0.021396719,-0.019272061,0.037789848,0.008114265,-0.00918629,0.0029960694,0.022897845,0.12618327,0.018129457,0.006231861,-0.009095869,0.013558639,-0.016517086,-0.02709209,0.024873186,0.0042864834,-0.006952384,0.0021743055,0.026088431,0.010922796,0.020524597,0.017500734,-0.009761108,-0.03422335,0.0076523633,0.011789317,0.027947625,0.022251675,-0.0009824246,0.016546767,-0.023057327,0.012952248,-0.015930094,-0.025776092,0.0110951355,0.019307483,-0.0028364104,0.004080449,-0.032831892,-0.0042411014,0.0014847176,0.025069252,0.0079557225,0.009843656,0.0045419275,-0.037553947,-0.17419773,-0.015794259,-0.004963106,-0.035280675,-0.0071215075,-0.00016866773,-0.023928365,-0.007901356,0.020682849,-0.013724486,-0.0008472231,0.009690204,-0.019300325,0.034278575,0.015540615,-0.02912934,-0.032272432,-0.012486843,-0.012399708,0.007933992,0.018430099,0.016423546,-0.0026931292,0.032243382,-0.009566032,-0.008448356,-0.02291689,0.008192023,-0.010014154,0.0035701625,-0.038667154,-0.0004506268,-0.0064972094,-0.029961256,0.017318552,0.0044309027,0.0097383335,-0.0064630965,0.013934286,0.025699407,-0.020027896,0.0072615645,-0.0028263337,-0.00959446,0.0025531643,0.0027309388,-0.0126093635,0.0069080526,-0.0067115244,-0.033422418,-0.008649954,0.01152068,-0.04334047,0.04253438,-0.009818244,-0.0016844972,-0.02118714,-0.0060027386,-0.012646482,0.0050267014,0.0093280375,0.022692185,-0.1321942,-0.0074218134,0.02082378,-0.018761221,-0.010629229,-0.022506883,-0.019687984,0.025118696,-0.0141355,-0.025335776,0.0154749155,-0.017490989,0.0020667673,-0.007840347,0.007923325,-0.01153199,0.0059364806,0.03432169,-0.02150228,-0.0035733066,0.01638709,0.00010265647,-0.031396672,0.012305254,0.0048170034,0.0078577455,-0.003973237,-0.009664968,-0.0034389333,-0.032022785,-0.0015636416,-0.039835602,-0.020933686,0.005341974,0.0072919205,-0.02086457,-0.01916363,0.007809493,0.00054946216,0.0022388801,-0.031978246,0.032727715,-0.023400713,-0.018610109,0.02740589,0.015139938,-0.014894645,-0.00123702,0.009107589,-0.00073688664,0.037694916,0.0017604404,0.023765655,-0.0030648033,0.0026256612,0.02733149,0.006164592,-0.0035296439,0.0104732765,-0.014463523,0.007470859,0.02605772,0.0032581287,0.021743318,0.00017320075,-0.0057295957,-0.010170025,-0.01047063,0.015096205,-0.011518163,-0.004317174,-0.01878194,0.0030288633,0.012337616,0.03252937,-0.00035895407,0.01784989,-0.040773675,-0.012526933,0.00046869172,-0.0326766,0.00135308,-0.029040806,0.0146646835,-0.003333184,0.016970966,0.003644107,-0.0011722841,0.016714023,0.0058393744,-0.013057737,-0.012815465,-0.011514092,0.0035571768,0.020192955,0.01314047,0.025741346,0.014562843,-0.008953068,-0.0068262187,-0.01346838,0.035365354,0.004699087,-0.007706806,2.2658778e-05,0.016531473,0.0006524252,0.006645038,0.03328886,-0.009090237,-0.010924555,-0.0016467015,0.0129082585,-0.032357648,-0.022611322,0.0028577808,0.003962119,0.027874917,0.029388605,-0.014191043,-0.025780806,0.005628533,0.01535582,0.0017127749,-0.024247857,-0.0073897257,0.02025029,0.004203471,0.023015298,-0.0057453634,0.0018925626,0.0037452502,0.0028426116,-2.2967728e-05,0.02894461,-0.00962494,-0.01062056,-0.026736846,0.0055996506,-0.026454847,0.018093556,-0.004151538,-0.015138711,0.0069939205,0.027827626,-0.024395226,0.018605225,-0.015142702,-0.008777829,0.0064284215,-0.0032214646,0.021695478,0.007666575,-0.031907473,-0.012361605,-0.010810996,-0.01103794,-0.0021177514,-0.02596911,0.004327902,-0.023149835,-0.08092137,0.004728986,0.005253094,-0.016074728,-0.009242797,-0.0039276443,-0.022887435,-0.007041514,0.014341697,-0.0025855175,-0.01942927,0.0019398307,-0.0035553062,0.003889846,-0.0074810623,0.015249755,0.02065785,-0.012306597,0.024237162,-0.002351123,-0.019350033,-0.0057200897,-0.020366032,-0.01753495,0.001122881,0.012546921,0.01764738,0.022361238,0.01753813,-0.007248095,0.014553115,-0.0057760673,0.0075213406,-0.030052392,-0.015167541,-0.0011977754,0.0005715712,0.0060213795,-0.0024711015,-0.015754977,-0.002795167,-0.0020053687,0.022951046,-0.00044231777,-0.013938664,0.013593747,-0.020030016,0.030031547,0.015550183,0.0049893563,-0.0012979555,0.011601496,0.006509558,0.027092377,0.017853525,0.014286271,0.0034065766,0.016117638,0.043892123,0.024555074,-0.006594705,0.034345917,-0.014324052,0.012501858,-0.013003392,-0.01318916,0.0006849888,-0.024646308,-0.040109683,-0.008518113,-0.0036373695,-0.0062267263,-0.01112,0.0112982765,0.02391556,-0.00454761,-0.03977741,-0.021746024,-0.0028431239,0.0001509157,-0.012540108,0.0011926844,0.003151867,0.033783738,-0.0061860867,-0.010426941,-0.011003733,0.0011872434,-0.0039847577,-0.002524328,0.024653487,-0.008549218,0.008407382,-0.010687424,-0.022301415,-0.016407747,0.013766859,0.011853016,-0.029095856,-0.013266071,-0.016129833,-0.0018269002,0.006749559,-0.005835713,0.017107813,-0.01080538,-0.009059901,-0.030980185,0.019819159,0.03986644,0.019810664,-0.013502519,-0.004630827,0.004642897,-0.010047178,-0.005805166,0.013289325,0.01679073,0.010103161,0.0023866566,-0.008848743,-0.010768933,-0.00060062064,0.0093308985,0.02252388,0.040907048,0.022430826,-0.020242093,0.016599653,0.01828353,-0.012782113,-0.0067903064,0.0032116475,-0.011249988,-0.028621104,-0.0048650135,-0.0021244625,0.002269698,0.003792047,-0.00268616,-0.032629997,0.0016209589,0.01640748,-0.0040268423,-0.011714901,0.010844714,-0.020145645,0.015053654,0.008163666,-0.0012858761,-0.00030927628,0.00047624452,-0.00086007273,-0.011574087,-0.005657199,-0.005659693,-0.020927694,0.003382637,0.010177847,0.0051652207,-0.021585751,-0.0148328,-0.021482162,-0.0073836194,-0.00093016244,0.012271859,-0.004465358,-0.0070477948,0.025819167,0.004906989,0.003524628,-0.014376568,-0.035147175,0.013594967,0.018388117,0.009550455,-0.020654334,0.023667563,0.005282658,0.011271249,-0.005766686,-0.0007232936,-0.03326992,-0.017918995,0.032732412,-0.0041422225,0.012353095,0.012802465,-0.006619642,-0.016223183,-0.03465563,-0.026762184,-0.015676368,0.01805564,-0.016187599,0.028300716,0.03023919,0.0059937043,-0.005480968,0.026147943,0.010662979,0.03009622,0.02289809,-0.0072326176,-0.0014116155,-0.014362799,-0.019689681,-0.05560865,0.006357299,0.019266386,0.010629217,-0.011114109,0.0031214673,0.0034214333,0.017665166,-0.008022087,-0.00781456,-0.009224235,-0.025407366,-0.004295414,-0.014278667,0.014333377,0.01357022,-0.007997938,0.024783522,-0.005525497,0.006561397,-0.022664825,-0.007963768,0.017514769,-0.014327466,-0.02414193,-0.022994975,0.016757537,0.0035725872,-0.003617988,0.025841266,-0.00011606206,-0.008323167,-0.0242735,-0.009869616,0.022394186,0.005924609,0.0010655577,0.007767709,0.0040560775,0.0012911872,-0.001816988,-0.0063216477,-0.007973534,0.0070533683,-0.013489394,0.013917119,-0.014679078,0.0079034725,0.010920256,0.020735316,-0.026245737,0.023568196,-0.026184097,0.0021215188,0.003556626,0.014363989,0.00828644,-0.010507855,-0.008248327,-0.0018865027,0.0028183903,0.0124038365,-0.11880461,-0.013514771,-0.0052862675,-0.038814828,-0.008658336,-0.030013567,0.029948713,-0.015448661,-0.013081073,0.006253139,0.015587753,-0.026008336,0.005709157,0.010009857,0.026906535,-0.005417282,-0.0043131704,-0.025989152,-0.01947895,-0.019114109,-0.013599104,-0.0019755994,0.0029493596,-0.01376307,0.014989629,-0.013972471,0.014622599,-0.02491891,0.00015562824,-0.0045307414,-0.0050719846,-0.00094773894,-0.01978629,0.013297937,0.029503003,-0.0047328514,-0.0075276094,0.0023790777,0.010614493,0.01891249,0.0046177763,0.010594167,-0.01913579,-0.02229678,0.01624856,-0.018085351,0.020146064,-0.008240128,-0.009776034,-0.0034556855,-0.04248267,-0.00480951,0.018249728,-0.021867303,-0.007007276,-0.020667654,-0.0030735955,-0.0011901641,0.007866557,-0.00083469244,-0.008774105,-0.021554057,-0.012882498,0.03307936,-0.0037024235,0.0008672526,0.013788051,-0.014170227,-0.020450644,0.0069774175,-0.013577202,-0.007504703,-0.016847484,0.010397042,0.018876754,0.028731443,0.00760897,0.013576478,0.0053665,-0.00077448296,0.00640346,0.016996965,-0.088739835,-0.008529043,0.0049797683,-0.029091107,0.007453288,0.0007694238,3.653475e-05,-0.015646651,-0.00031310754,-0.005161863,0.020857075,0.017254705,-0.0057603805,-0.01763339,-0.023537247,-0.01879345,0.008562982,-0.0059273154,-0.016167637,0.006560107,0.006704871,0.014644955,-0.010958057,-0.004879759,-0.012547217,0.004437295,0.012868335,0.005289761,0.021431029,-0.021063624,-0.018399049,-0.14539191,0.003548923,0.012183026,-0.04408107,-0.0070340796,0.020066053,-0.0009036516,0.030458521,0.0028357934,-0.012820762,-0.015090698,-0.025354203,-0.019501017,0.018538812,0.01962655,0.09152542,0.042851415,0.022440255,-0.019341785,-0.032857582,-0.00058196054,0.00080342015,-0.00804295,-0.0030746618,-0.0020669238,-0.012146014,-0.0049845674,-0.0021017296,0.019458946,0.03168672,-0.02255017,-0.000877102,-0.014834688,-0.0065838126,-0.0070622605,0.02376696,0.0021249198,0.010777215,0.030959575,0.0095480895,-0.0036857463,0.023754464,0.023380987,0.02333188,-0.011338276,0.00014733014,0.0070634666,0.01788369,-0.0060390816,0.03312114,-0.032246824,-0.07679079,0.019666763,-0.012791014,-0.010380787,0.00040322973,0.0030542032,0.024930175,0.003265981,0.011390692,0.01911751,-0.02013337,0.011801004,0.026827902,0.00039158404,0.017952,0.029845616,0.014716943,-0.013710055,0.0075110835,-0.0019178094,0.014842553,-0.015035304,-0.052418754,-0.01272308,0.013647221,0.003173047,0.010903689,0.016570695,-0.025811074,0.012820893,0.02449277,0.0154244695,-0.00219394,0.021889314,0.01640493,0.01779007,-0.0282491,0.004090024,0.019500863,-0.014193817,0.013125783,-0.00047995202,-0.016594805,0.019325666,0.0127279265,0.0039608423,0.008251634,-0.0054350058,0.01574898,-0.009411914,-0.019446572,-0.00080924784,-0.026538407,0.040194,0.009439486,-0.018866666,-0.0149192335,0.017033415,0.00080748]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (2, 'thong_tin_ca_nhan', 'Cấu trúc thông tin cá nhân trên phiếu', 'Phiếu báo thi chứa các mục thông tin cá nhân sau: họ tên thí sinh, ngày sinh, giới tính, dân tộc, nơi sinh, mã học sinh, lớp (ví dụ: 9A5), cơ sở giáo dục (trường THCS đang học ở năm lớp 9), và ảnh thẻ 4x6 cm. Mỗi thí sinh có một mã học sinh duy nhất gồm 10 chữ số.', 'Phần trên của phiếu, bên trái', '[-0.008225148,0.016979028,0.0010897685,-0.041362453,-0.015582537,0.0056709833,-0.008057265,-0.011113308,-0.006450597,0.0011750195,-0.03142388,0.015708078,0.013157871,0.010888904,0.14083704,0.027260708,-0.012706766,0.019363891,-0.0058293887,-0.013392193,0.0017313414,0.02526345,-0.0023659684,-0.016684324,-0.025504261,-0.00094579504,0.012006707,0.019454917,0.02386162,-0.005932524,-0.03744298,0.019229544,0.021834066,0.024143556,0.017699178,0.002690437,-0.004334512,-0.023198038,-0.017900124,-0.02503449,-0.009299655,-0.00820595,0.028145729,0.007073834,0.022800302,-0.02032667,0.002495206,0.002632401,0.015630284,0.030961026,0.013913426,0.02861925,-0.0570413,-0.18224247,0.015905838,-0.015238358,-0.02118259,0.0029207899,-0.03482645,0.0034946976,0.0099687,0.0058269138,0.00015958856,-0.0077940696,0.027011117,-0.01376435,0.030224307,0.0355712,0.0005157716,-0.022926647,-0.01330888,-0.0049655875,0.005998605,0.015013941,0.026959924,-0.022829406,0.025589336,-0.02444417,-0.0059115826,-0.0022175396,0.015709065,0.008318261,0.009048815,0.010089957,-0.019294282,-0.030166635,-0.020826995,0.016964007,-0.003174435,-0.0064942795,-0.010922088,0.006267245,0.008426703,-0.042118404,-0.01045201,-0.014021912,-0.014009413,0.0097195245,0.004853534,-0.027846284,-0.004313124,-0.039373774,-0.027682526,-0.024775853,0.031243404,-0.03702205,0.022543129,-0.0127836205,0.03447907,-0.039315294,0.0038191276,-0.026919417,0.0069630183,0.00064231694,0.045715507,-0.14553127,-0.00849416,0.0011157794,-0.008581834,0.0037410802,-0.010032683,-0.013130261,0.0010671712,0.0128899785,-0.0029335225,0.01121782,-0.0014192214,-0.0132319,0.021901706,-0.015224112,-0.0036687225,0.006805627,0.011970509,-0.0012315346,-0.015296024,-0.0076565975,-0.004752666,-0.0059931623,-0.009276982,0.0067114374,0.0028412591,0.0044531357,-0.023598202,-0.0002987537,-0.024315622,-0.009991488,-0.028088097,0.00967638,-0.017131947,0.0014833919,-0.003136928,-0.021938637,-0.0073859342,-0.006243761,0.007738783,-0.015014224,0.02196828,-0.01899559,-0.041654993,0.058169805,0.022469293,-0.023127502,0.0024495532,0.012347335,0.021027986,0.024522493,0.025860569,0.010000423,0.011690116,0.006113576,0.028706776,0.023428345,-0.008267044,-0.00013797355,-0.011932199,-0.01860747,0.01077,0.01237804,0.013841314,0.012338598,-0.021369416,-0.009436617,-0.0022759316,0.0032682135,-0.008929415,0.0016100709,0.018313793,-0.0052576107,0.024550775,0.019099517,0.0013392887,0.017726313,-0.02741442,-0.022600716,0.01783899,-0.029270442,-0.014517027,0.0016107911,0.02241452,0.0058365623,0.010820942,0.0048934915,-7.984185e-06,0.005021586,0.0058935466,0.013580859,-0.008315029,-0.018439956,-7.700152e-05,0.03332451,-0.01436907,0.02745606,0.025058784,0.014232279,0.01010105,-0.0024663724,0.021457996,-0.008168601,-0.032415982,0.00056140375,0.0062341425,0.012027926,0.024029123,0.019524124,0.010905701,0.004306419,-0.0018180269,-0.01021019,0.009965357,-0.0014784381,0.041263983,0.023221027,0.02276468,-0.002895004,0.0035539125,-0.0022927497,-0.027848583,-0.003063483,0.008829931,-0.016985906,-0.0062027415,0.0066480925,0.023677597,0.032876637,0.03246075,0.007719661,-0.018672792,0.010343986,0.0065955943,-0.0010222874,0.0048962343,-0.0224225,-0.011187955,-7.4607495e-05,-0.023166228,-0.02082805,0.01729933,0.007560976,-0.010533674,-0.003176306,-0.03966139,-0.007688145,-0.021946939,-0.02395586,0.007658574,0.008342143,0.012025269,0.023686145,-0.02000423,0.00859462,-0.009360994,0.005204841,-0.015638815,-0.013644395,0.023046175,0.022694377,-0.074261345,0.0022739917,0.007917285,-0.022886492,-0.0170718,0.009465224,-0.024566287,-0.023461094,-0.0083651785,-0.0062294984,-0.012978247,-0.020033693,-0.0096106725,0.007657899,-0.011908148,0.011424671,-0.004400843,-0.010372364,0.008470287,-0.0026959977,-0.021414042,-0.005532911,-0.0019987288,-0.007894475,0.0032063746,0.02223968,0.042275343,0.0162424,0.0067924852,-0.0059440997,-0.01020508,-0.0089265015,0.008802057,-0.029333187,-0.033152793,0.006714022,0.0041360795,0.018434944,0.00042991224,0.0045345244,0.0011490086,-0.007949491,0.024266994,0.0038735627,-0.0021567692,0.026503744,-0.035610802,0.0046752756,-0.0065489346,-0.001364787,-0.03062502,0.016735628,-0.0076850895,0.0058185123,-0.013259533,-0.004940968,-0.015307203,0.020616205,0.024733137,0.0036779563,-0.0012095373,0.021654118,-0.025792092,0.0056822896,-0.022076536,-0.02272631,-0.0102509605,-0.029712053,-0.028344253,-0.0047364742,0.00432287,-0.014578376,-0.01300665,-0.019677367,-0.005351249,0.004952436,-0.018007345,-0.009577308,0.01620828,0.027780617,-0.021767616,0.026741255,0.021845339,0.029728841,0.009695552,-0.0010860986,0.0059239357,-0.0031901023,0.002791824,-0.017629024,0.01479732,0.0012514603,-0.0046820864,-0.00010377081,-0.0056812866,-0.036854964,0.014507292,0.0042141513,-0.02458192,-0.0048371237,-0.0018376056,-0.00917741,-0.0015486865,0.015433414,0.013078738,-0.011947848,-0.0015429856,-0.01011985,-0.002489567,0.03576851,-0.0005091751,-0.015842585,0.004620628,-0.017988672,-0.009127849,-0.0037573534,-0.008282788,-9.0963396e-05,-0.0038864617,-0.016076574,-0.015667625,0.0030770258,-0.016214788,0.0029073812,-0.0061322106,0.007056016,0.016345534,-0.011318375,0.018057086,0.00075278827,0.013845672,-0.03396075,0.00071110914,0.009816322,-0.008433842,-0.029585825,-0.0023834717,0.027857745,0.021730166,0.018151158,-0.014109348,0.008731041,0.014450644,-0.0070931003,-0.010384612,-0.0130166225,0.009608161,0.0074372306,0.02138292,0.02822248,-0.018718379,0.015854446,0.020051923,-0.0186404,-0.018530868,-0.0018863592,-0.026734421,-0.0062050237,0.009530432,0.027552916,-0.024169348,-0.022220114,-0.030456815,-0.014429162,0.004447918,0.025931697,0.01601773,-0.018906642,0.024014207,-0.01395522,-0.005720604,-0.02008426,-0.015270735,-0.0088897,0.0038464502,0.008254319,-0.036517255,-0.0030052583,-0.02657789,-0.0009475413,-0.01586016,-0.023342649,-0.019858774,-0.025548996,0.024369588,0.018375086,0.010136493,-0.003126534,-0.023666553,-0.009671356,-0.0025304584,-0.03419001,-0.021863606,0.0050695436,-0.024382513,0.019120105,0.005840516,0.012724875,-0.005006748,0.003995118,0.017338837,0.04364024,0.010533849,-0.021000506,-0.006840219,-0.016525755,-0.022882544,-0.03435119,0.0055033495,-0.00037318195,0.01765539,0.0022429202,0.01253027,0.0054846825,0.01327582,0.022114674,-0.010789322,0.006175803,-0.032703556,0.0070756804,-0.0029542262,-0.00080455106,-0.0036061741,0.0023619118,0.018612424,-0.0046141297,0.016435133,-0.029006708,-0.022924127,0.026633088,-0.01743306,-0.024344716,-0.002049988,0.000605392,0.0010359131,0.0031112253,-0.00064548134,-0.012826264,-0.014395481,8.9856505e-05,0.0026648138,0.019155614,-0.0027279346,-0.01275242,-0.024210285,0.004325436,0.02098457,-0.002179786,-0.012120214,0.016937688,0.019874694,-0.002368774,0.013525949,0.003736799,-0.004160793,0.0036157544,0.0108632725,-0.036011014,0.0027159934,-0.017179511,0.0031896904,-0.0014521634,0.03319257,-0.0014053511,-0.0042031663,-0.011082807,-0.014094126,-0.010629986,0.018383361,-0.106393464,-0.008207284,-0.0321905,-0.0026810474,-0.0052024326,-0.033924535,-0.01370825,-0.024651175,-0.029323308,0.025215395,0.011456116,-0.008891648,0.0134238545,-0.015288817,0.003155597,-0.009970476,-0.016739503,0.013806167,-0.013931213,-0.010205316,-0.002525285,0.017276023,-6.942265e-06,0.006359089,-0.00040034417,0.0057672192,0.006722857,0.020914463,-0.0037229462,0.0053647324,0.003344075,-0.009642339,0.003985438,0.019187063,0.031483684,-0.021619951,0.0056400797,0.011816558,0.019510908,0.02274641,0.014598999,0.0021442154,-0.008224191,-0.012947018,0.007027232,0.007067289,0.04417026,-0.015021422,-0.033753254,0.005034401,-0.03384024,-0.013462762,0.008988437,-0.020917457,-0.03222085,-0.024466235,-0.0074849157,-0.01124735,-0.013735806,0.007703338,0.004910105,-0.01655579,0.014209119,0.014250325,0.016806975,0.009214452,0.008646524,0.0014224511,-0.019649018,-0.00972147,0.0028309652,0.020534225,-0.0015138655,0.021819789,0.002066482,0.03520098,0.00087670947,0.01188289,-0.009911834,-0.013919426,0.0015553044,0.018183079,-0.093750276,-0.011305475,0.0279706,-0.036193237,0.01071727,0.023025017,0.012448002,-0.015427093,0.004757537,0.00353618,0.023773825,0.009158866,0.015410779,-0.023973014,-0.02772205,-0.027524386,0.013332513,-0.02786397,-0.015329381,-0.011751992,0.0062550297,0.0026716138,-0.0069332747,0.014188811,-0.032231096,0.0053918315,0.015877591,0.005701627,0.012199227,-0.02181887,0.009541031,-0.119175635,0.032819673,-0.015727142,-0.015060831,0.013940727,0.030496087,0.0025419209,-0.0050844005,-0.008068167,-0.011379566,-0.009323989,-0.027696056,-0.01639961,-0.001992262,0.014920991,0.10207997,0.019462788,-0.0068889796,-0.028472194,-0.009564227,0.0010914238,-0.014074051,-0.013231333,-0.02338486,0.0047445195,-0.0015951395,-0.004012294,-0.00016371525,0.012933818,0.023902198,0.013370649,0.00049069553,0.0048819804,-0.019232808,0.0054068603,0.035288494,0.003569257,0.0043701283,0.0238687,0.0036152538,-0.005675103,0.009324596,0.006093382,0.003544702,-0.003973528,-0.005845706,0.010559698,0.036345147,0.0012280097,-0.0005447779,-0.019343821,-0.05550765,0.0047589983,0.013434198,0.024260303,0.008456042,0.0010750861,0.013721017,0.0016510339,-0.032817014,0.02610341,-0.041493796,0.044028375,0.021778636,-0.025680201,-0.011087848,0.013155183,0.012383944,0.00784645,-0.008231584,-0.02406591,0.017452164,-0.0025496213,-0.023949185,-0.005855732,0.0063638147,0.0029377039,0.0072319666,-0.0002997995,-0.006404312,-0.002153023,-0.009747174,0.018454302,-0.0010137629,-0.005083935,-0.01150428,-0.0067900456,-0.021247609,-0.024712525,0.012892889,-0.0016564786,0.0062592374,0.013683635,-0.022500057,0.005096648,0.040942937,-0.020786336,-0.021713823,0.014014205,0.0050806026,-0.016390104,-0.016397083,-0.0024668155,-0.020861585,0.008771043,0.008698004,0.00484026,0.003438245,0.030146215,0.006481024]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (3, 'tuyen_sinh_khong_chuyen', 'Phần tuyển sinh không chuyên', 'Phần tuyển sinh không chuyên (PHẦN TUYỂN SINH KHÔNG CHUYÊN) ghi rõ: nguyện vọng xét tuyển, môn thi, số báo danh, phòng thi, và điểm thi. Thí sinh đăng ký thi vào công lập bằng cách đánh dấu [X] vào ô ''Thi vào công lập''. Phần này cũng ghi ngoại ngữ đăng ký học THPT và ngoại ngữ đăng ký thi. Thí sinh được đăng ký tối đa 3 nguyện vọng, sắp xếp theo thứ tự ưu tiên từ NV1 đến NV3. Mỗi nguyện vọng tương ứng với một trường THPT.', 'Phần giữa phiếu, tiêu đề in đậm', '[-0.011242392,-0.02931288,0.016840298,-0.041326843,0.0025181107,-0.0061312052,0.002987519,0.0041946364,0.013122026,-0.007808473,0.0010685603,0.038018227,-0.008976982,-0.008851684,0.118470475,0.03935391,-0.014404624,0.009273334,-0.013928656,-0.0024997143,-0.007465157,0.011259856,-0.0016161461,-0.024695339,-0.004484587,-0.018415071,0.030045643,0.0382703,0.024885496,-0.009091483,-0.0080438545,0.03782547,0.016763387,0.01030897,-0.0006210497,0.028954782,0.029718474,-0.028376771,0.03127091,-0.02812867,-0.015477512,-3.1697276e-05,0.00798588,-0.03639554,0.0035976658,-0.02166648,-0.012253193,-0.010785073,-0.00853678,0.0075391172,-0.017682413,0.00556472,-0.027131492,-0.17724507,0.004231238,-0.031042013,-0.003968089,-0.0077862027,-0.0048278174,0.00055182556,-0.006741091,0.026295654,-0.009765933,-0.0023912955,-0.0013101699,-0.009146419,0.013574789,0.010835974,0.017562184,0.00069742877,-0.0072843605,-0.006129173,0.012788236,0.0053169336,0.009524187,0.008332134,0.014050082,0.005002841,-0.015267553,-0.009922478,-0.019972654,-0.0154707115,-0.014626794,0.006507957,-0.005605479,-0.035121135,-0.0034751669,0.025591731,-0.014582161,-0.010997164,-0.005220951,-0.0010974768,0.0102654,-0.015498838,-0.016640628,-0.008452303,0.0026694636,0.013910356,-0.00238654,-0.021647155,0.004301939,-0.015975561,-0.017162284,-0.025275923,0.0013494419,-0.015473156,0.021899631,0.027618958,-0.008382273,0.00021592184,7.7777586e-05,-0.022709846,0.016153706,0.01078016,0.028694024,-0.1360495,-0.009250972,0.021309935,-0.022952044,0.029270345,-0.035830963,-0.011821733,0.0054934747,0.015537643,-0.022917252,-0.009154696,-0.018407347,0.0016267849,-0.008147054,-0.013838053,-0.014585965,0.010906143,0.036109004,-0.0117196245,-0.0033233985,-0.014151771,-0.0016729007,-0.020212507,-0.01715156,-0.017562423,0.012568408,-0.005896799,-0.022104982,-0.0038830752,0.012695645,-0.0025825887,-0.03139529,0.0012189932,-0.022879677,0.002545201,-0.026270181,-0.0285813,-0.01803454,0.0027123915,0.004149456,-0.013513159,-0.008340024,-0.016211228,-0.053948086,0.020458318,0.002665487,-0.025987512,0.0014561064,0.0089858305,0.029258566,0.035668258,0.010180836,0.020275524,0.021898212,0.014932049,0.00037597682,1.9165893e-05,0.0020955643,-0.006101214,-0.019282253,-0.00046243053,0.014037792,0.00939982,0.018147083,0.0005258112,0.004414398,-0.0049618646,-0.017308602,0.015548085,-0.0040602856,-0.0051892824,0.024769582,-0.021370467,0.028240088,0.01876682,0.0065411697,0.03581865,-0.028564913,-0.015587579,0.0017108795,-0.024689076,0.0018236283,0.02005379,-0.001643809,0.010810952,0.010312234,0.021938372,0.005936527,0.0139330095,0.00730403,-0.013215148,0.002318635,-0.016107865,0.0061045275,0.019726282,-0.010264893,0.0058771567,0.011567095,-0.009908236,0.0060396953,-0.021240998,0.026789097,-0.0028823446,-0.009521195,0.009574039,0.019500472,0.005739463,0.02386899,0.021032538,-0.0058942228,0.013385793,-0.011348962,-0.01521037,0.002602852,-0.008601233,0.0027419692,0.028137937,0.010306899,0.0072510885,0.010914651,-0.021601247,0.015650194,0.018347805,0.009755886,-0.016806839,-0.021974772,0.00015458847,0.0145665305,0.012398889,-0.0059593157,-0.005665535,-0.0024605761,0.0067620906,-0.01743385,0.016178444,0.006357545,0.009589924,0.0035761227,0.009921403,-0.028165447,-0.002375051,0.011473101,0.011090395,0.035378736,0.030869234,-0.030532032,-0.0037405693,-0.008172146,0.0032778275,0.017273888,0.013813581,0.02308752,0.010790102,-0.018679272,0.011335744,0.0030732672,0.0030437508,0.008045901,-0.029233338,0.0023342737,-0.027970325,-0.09794268,0.013869637,0.026166856,-0.002478065,0.0057845465,0.00064505625,-0.00014114124,0.015648885,-0.010102234,-0.01043063,0.0071572694,-0.0015737336,-0.01802155,-0.027500736,-0.0022195294,-0.007240863,-0.010487581,-0.02166138,-0.013030087,-0.02975264,-0.012316145,0.021387815,-0.018610094,-0.009290599,0.020457435,0.029227205,0.034015477,0.02701323,0.0038443299,-0.015291198,0.006812947,-0.014352163,0.0018079123,-0.021861356,-0.038276862,-0.0016886729,0.04348377,0.002561082,-0.012135646,0.0057210866,0.00018643706,-0.0032086123,0.010165125,-0.004949712,0.0049669417,0.022614647,-0.0070484676,0.034737363,0.006168148,-0.011952743,-0.01500954,-0.016344788,0.0070654424,0.013659047,0.008535764,0.014411483,0.013308022,0.009669743,0.034861915,0.012918068,-0.004163139,0.0064812917,-0.010985328,-0.008890913,-0.0048677255,0.024013542,-0.0018514487,-0.040127307,-0.019864984,-0.0068920916,-0.023187375,-0.00013995136,-0.010143285,-0.028669275,-0.007126204,0.006837741,-0.007718156,-0.004405768,0.009833182,0.01060566,-0.0029979418,-0.0031783169,0.014043868,0.036905017,-0.00610354,-0.009702142,0.034283224,-0.0056996187,0.026337445,-0.014532938,0.0012967609,0.019130634,0.021088867,0.02464531,-0.0037939956,-0.0055015073,0.010456651,0.001909178,-0.02102915,-0.0044614873,0.011307132,-0.0032810678,-0.0024746095,0.014581192,0.033447098,-0.02212217,0.005958001,-0.0009736093,-0.0023392332,0.030831808,0.015499783,-0.0017026954,0.026826326,0.0016295491,-0.004994411,-0.020028405,0.01888362,0.016604543,-0.016467214,-0.0028784708,0.014030011,0.0108379945,-0.011213912,-0.008185882,-0.00688607,0.009831581,0.0026227392,-0.011062178,0.010045123,0.0050351494,-0.003655644,-0.047144677,-0.02075769,-0.00031267176,-0.028914243,2.466915e-05,0.012652716,0.009311736,0.025450097,0.027604558,-0.010033049,0.0035035189,0.011431322,0.015170069,0.0047327867,-0.00389161,-0.019535983,0.0033201277,0.028823007,0.023276778,-0.011474462,0.021725515,0.0195276,-0.019409735,-0.019833669,0.008412696,-0.00058138475,-0.0103106145,0.0103202835,-0.0052521857,-0.021890817,-0.01878673,-0.0040015923,-0.029695697,0.027641118,0.009611839,-0.0016229686,-0.004755923,0.019610487,-0.00979714,0.019557472,-0.016058663,0.015482425,0.011933814,0.014201055,0.009140618,-0.00853228,0.014703121,0.00069757964,0.018370677,-0.033184256,-0.018750476,-0.02851995,-0.01490348,0.008764869,0.0006571505,-0.008024798,0.013113659,-0.018034073,-0.027351905,-0.014147979,-0.030906904,-0.013362126,0.0075585605,-0.00729916,0.014885113,0.015731253,0.0006611222,-0.013396047,0.028902132,0.0028061827,-0.005157534,0.008177319,0.00904267,-0.022461971,-0.026182111,-0.033580452,-0.043849103,0.01594318,0.002481176,0.009278389,-0.0058636875,0.010373776,-0.0066246614,0.00956617,0.007233975,0.012612122,-0.02168184,-0.013365162,0.008952692,-0.022257695,0.010089992,0.01123345,0.002396235,0.037022714,0.012199674,-0.0008674298,0.0045549134,-0.050080925,0.0011201306,-0.032336574,-0.010394276,0.015115396,-0.013806038,-0.015761677,-0.0067332597,0.0035836247,-0.00046034224,-0.023271468,-0.0010711951,-0.0073642917,0.012535652,-0.0014144271,0.015139478,-0.012636972,-0.012645934,-0.009078588,-0.023723217,-0.017931223,-0.013804787,-0.032969598,0.0025923043,0.012201381,-0.02703969,0.00023099902,0.019555213,0.0095868865,-0.0043004057,-0.008327585,-0.0133643,-0.004071203,-0.02433567,0.0022230828,0.015517321,-0.0026266691,-0.013045996,0.00914659,-0.027276676,0.03318755,-0.12097532,0.0120031545,-0.01695338,-0.011625805,-0.032419853,-0.0234744,-0.01714624,-0.048444293,-0.013543313,0.0020529546,-0.0065287305,-0.0052668257,-0.0007445992,0.0075170477,0.013462772,-0.0009967327,-0.004219363,0.011586854,0.0152878165,0.008880747,-0.0074123205,-0.0017808302,0.028566534,-0.002440636,-0.0042702123,-0.015202544,0.0260808,-0.012387942,-0.023689022,0.021657333,-0.010216433,-0.008523828,0.019193223,0.04231806,0.009093112,-0.012900357,0.018675,-0.022461738,0.00012531804,0.009632607,-0.0012652376,-0.012701038,-0.01662111,0.016777987,0.009781641,0.011484796,0.020652074,-0.008522809,-0.034336228,0.007853078,-0.039939493,-0.041394807,-0.017500285,-0.028310914,-0.007779385,-0.019707035,0.00072175136,-0.013636618,-0.0021563764,-0.014437459,-0.005505078,-0.023832517,0.016302003,0.020632153,-0.00085047807,0.010835094,-0.0011088238,-0.0048589273,-0.008921036,-0.0031886757,-0.012800286,-0.00013545348,0.0062230187,0.02277256,0.020772021,0.036354914,0.015426556,-0.010307357,0.0041200146,0.015736997,-0.005672614,0.008370417,-0.07401299,0.0016932456,0.014943826,-0.05115225,0.007914202,-0.0034586936,0.023086634,-0.0061201416,0.006142323,0.022366202,0.0036688743,-0.008878618,-0.006285684,-0.008651957,0.009945818,-0.024571642,0.018488688,-0.011420656,-0.008126474,0.0025396664,0.009920488,0.012602519,-0.0020338115,-0.018238375,-0.01690687,-0.0005826057,-0.0013337994,0.013908352,-0.0036466043,-0.027641099,-0.010094667,-0.13092767,0.022671185,-0.00061419705,0.0044795778,0.013554146,-0.0015975959,-0.007044343,-0.011645618,-0.0102108,-0.023096872,-0.028900566,-0.00830902,-0.013608643,-0.009301984,0.018509554,0.107963905,0.0057935324,0.005776438,-0.021968553,-0.007606406,0.0021670808,-0.012168329,0.012838939,-0.019165315,0.023169616,-0.0008201623,-0.027629443,-0.006264107,0.03745736,0.006381094,-0.0032451379,0.0024130791,0.00675675,-0.007568709,0.002812093,-0.017457746,0.012739353,0.0030942825,-0.0012834832,-0.0013052307,0.024726592,0.034521107,0.0069346707,0.022337675,0.0053630224,-0.02111231,0.0007972448,-0.0043390156,-0.0027101173,0.008822291,0.008693612,-0.0583846,0.025382513,-0.0017125368,-0.0128126405,0.022334138,0.0015385264,-0.011502726,0.013406572,-0.013945712,0.027245149,-0.02869018,0.0057056127,0.020591836,0.008945659,-0.020729382,0.020356225,0.0071895,0.007895618,0.012352718,-0.024418892,0.01986962,-0.011730673,-0.0050566727,-0.011217314,-0.00327919,-0.017826214,-0.015353137,0.0018603104,-0.013308337,0.023723952,0.027601693,0.021312075,-0.027163846,0.028616674,-0.010182537,0.02555515,0.009962017,0.0046240753,-0.014435505,-0.002594069,0.010661662,-0.010333963,-0.014681048,0.0113247605,0.0018737316,-0.0152830575,0.008864723,0.017662615,0.0131015405,-0.024818188,-0.013373536,0.013636665,-0.03561642,0.018272592,0.013348788,0.0019047217,-0.0066856625,0.013954423,-0.0015394309]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (4, 'tuyen_sinh_chuyen', 'Phần tuyển sinh chuyên', 'Phần tuyển sinh chuyên (PHẦN TUYỂN SINH CHUYÊN) chỉ áp dụng cho các thí sinh đăng ký thi vào trường chuyên. Phần này ghi: trường chuyên, lớp chuyên đăng ký (ví dụ: Tin/1, Toán/2), môn thi chuyên, ngày thi chuyên, điểm thi chuyên, phòng thi chuyên. Thí sinh có thể đăng ký nhiều nguyện vọng chuyên. Trong lớp 9A5 THCS Chu Văn An, chỉ có 1 thí sinh (Phùng Minh Vũ, trang 42) đăng ký thi chuyên môn Tin.', 'Phần dưới phiếu, chỉ hiển thị khi thí sinh có đăng ký thi chuyên', '[-0.009207787,-0.028755018,0.0025825847,-0.04201821,0.00014834745,0.024115711,0.015310358,-0.00904779,0.001021059,-0.00426802,-0.027501466,0.0076674367,0.014016574,0.017733969,0.1326709,0.029973362,-0.029476892,0.00077322137,-0.02021595,-0.004332961,-0.012357152,0.03044702,-0.0015783521,-0.02454358,-0.023302622,-0.007996165,0.043612983,0.03770399,0.042403966,-0.00031831668,-0.024396408,0.016825093,0.018397508,0.020133376,0.014175561,0.012314679,0.03699806,-0.030178135,0.02087011,-0.022832049,0.0005133444,0.024417108,-0.0019060632,-0.008463325,0.0069112116,-0.032713246,0.01728698,-0.022860188,-0.01741137,0.033944312,-0.004654001,0.00978064,-0.026056236,-0.17651737,0.0005232106,0.0006990294,0.0010969104,-0.01197044,-0.016955014,0.0029434036,-0.025891224,0.03246521,-0.015855169,0.024987053,-0.011714397,-0.0019168088,0.032092676,0.015614738,0.005467282,-0.016766883,-0.010966065,0.0029860719,-0.021391809,-0.0038416851,-0.010719794,-0.011289472,0.017769057,-0.0044351653,-0.011727175,-0.000733866,0.0036657068,-0.009031891,-0.004005488,0.0025285303,-0.0064479792,-0.005302059,-0.018802417,-0.00394981,-0.008026786,-0.016872436,-0.017576326,0.012430415,-0.007489816,-0.021292642,-0.025246037,-0.022740131,-0.0031567833,0.022578552,0.0020384395,-0.009681502,-0.012972377,-0.018352224,-0.03762559,-0.008249471,0.004733358,-0.028037662,0.011931552,0.0183862,0.0022970338,-0.0033637849,0.0032765833,-0.02885609,0.0023183865,0.03780448,0.027315235,-0.13750423,-0.00095670717,0.034174226,-0.01022048,0.015557975,-0.007317412,-0.0038782062,0.0144690145,0.0008748152,-0.0097007025,0.023215774,-0.0018408961,0.007414043,-0.00078885,-0.015912952,-0.009766399,-0.01062893,0.032213468,0.005522517,0.009398549,0.007504367,-0.023611778,-0.025462523,0.0003223091,-0.0027869146,-0.014231851,-0.023801526,-0.011345831,0.017278131,0.006292848,-0.025863344,-0.015728278,0.015952924,-0.026110033,-0.008768598,-0.010793231,-0.018505167,0.0004993375,0.0020234329,-0.0025674924,-0.015515763,-0.015612461,-0.024375007,-0.031097991,0.020100847,9.20116e-05,-0.016928738,-0.00031001738,0.0031553248,0.009322887,0.02572793,-0.007383545,0.036327682,0.013524089,0.021869909,0.008130833,0.0004450131,-0.0030177266,-0.009911745,-0.005671382,-0.011041437,0.008492576,0.016733779,-0.0076905717,-0.0045367233,-0.0013924924,-0.0067335744,0.0011523154,0.02264617,-0.010925478,-0.009337166,0.033997837,-0.015154105,0.028071187,0.011498072,-0.0017386772,0.005099926,-0.020772375,0.009986399,0.001057962,-0.019765371,0.0055645565,0.015755583,0.0035034386,-0.0008987523,0.0036379418,0.0088743735,-0.004407326,0.012030206,-0.008718641,-0.011835204,-0.010834321,-0.014917057,0.017299986,0.02086708,-0.0029639755,0.026364898,0.008231369,-0.0034576487,0.017372876,-0.01653594,0.03513844,-0.008768449,-0.015863907,-0.004530694,0.010085905,-0.007023238,0.025340877,0.010364151,0.019118613,0.021300515,-0.010008298,-0.03380253,-0.0017649821,0.0003848531,0.016956586,0.0012168346,0.0077987527,-0.0054967836,0.02200035,-0.027900225,-0.011384173,0.039213207,-0.0068412386,-0.01597406,-0.020309065,-0.0075219325,0.016686656,0.016311876,0.02649074,-0.00803584,-0.0066976994,0.031459447,0.009645317,0.00073884765,-0.015935116,0.0027193904,0.00014984906,0.005601307,-0.015739242,0.0047180797,0.034043368,0.016984645,0.008799232,0.024039999,-0.0061782235,-0.0046238047,-0.010920162,-0.014342113,0.00045254786,0.0106359925,0.026885884,0.0013135299,-0.027970774,0.0047814855,0.008625741,0.0054458673,-0.008888779,-0.01747817,0.018074654,-0.013558292,-0.09008316,-0.0024040882,0.03752697,-0.021922356,0.011098994,-0.0030648564,0.0063509266,0.009364503,-0.020797567,-0.008879133,-0.015100018,-0.033024497,-0.018257672,-0.012420934,-0.0007941328,-0.012908657,-0.025872895,-0.020158578,-0.0140725775,-0.0064599346,-0.026989663,-0.004107209,-0.02390774,-0.0036600356,0.015653249,0.03336635,0.012368149,0.038871318,0.015343822,-0.029383063,-0.008386715,0.012043744,0.012898756,-0.017495062,-0.039092153,-0.026055178,0.015153115,-0.008218654,0.021098072,-0.010829803,-0.008773688,-0.010505205,0.0033850782,-0.026428854,0.008652498,0.0127246445,-0.023504175,0.028730892,0.010568396,-0.011490859,-0.011317137,0.011760162,0.0020036853,0.012047198,-0.0021406768,-0.0128867095,-0.0052608084,0.0002704399,0.037757605,0.0050139166,0.019090766,0.013501943,-0.0033611038,-0.000113814334,-0.00576329,0.011483044,-0.0011714927,-0.001179161,-0.013241047,0.010711111,0.0012855512,-0.008782379,-0.0064833723,-0.020095805,-0.007485547,0.014247698,-0.02121912,-0.015653156,0.008133829,0.029675577,-0.0021497281,0.020710897,0.003605021,0.031238932,0.0024923754,-0.013432423,0.0085921,0.023260232,0.02712653,-0.012313432,-0.005034715,0.011045394,0.011313146,0.027606545,-0.014726921,-0.013361074,0.0112327,0.028056677,-0.015472101,-0.011531482,-0.026360597,0.0008810781,-0.0048929565,0.0078367395,0.034647282,-0.027095683,0.0060103694,-0.0029439528,0.014515423,0.012850179,0.016591422,-0.009414315,0.033809617,0.009520495,0.006742225,-0.0018505305,0.010407328,0.01674556,-0.014251348,-0.017026851,0.023922129,0.005925602,-0.021231929,-0.011001468,-0.010125754,0.013698198,-0.0028546406,-0.025175815,0.00066282053,0.018436119,0.0012590445,-0.030005295,-0.0016079916,0.0011096557,-0.008659224,-0.0049506105,-0.008550818,0.034053296,0.01935685,0.006495949,0.0008416252,-0.011666388,0.010754827,0.00394603,-0.0030394706,0.00586727,-0.0062615923,0.01064923,0.02225235,0.022754172,-0.021091642,0.023883946,0.04489118,-0.030711956,-0.036448225,0.016562544,0.0017834583,-0.016404172,0.0003959293,0.006501007,-0.018952409,-0.0089453235,-0.00984333,-0.016089462,0.013353415,-0.008165291,-0.017095184,-0.015728246,0.013069832,-0.0025413132,0.02286628,-0.004999397,-0.008535446,0.009801573,0.013418033,0.0058236755,-0.016074788,0.023481147,-0.0017841317,0.011416736,-0.0014413157,0.0048249373,-0.042166326,-0.019265417,0.013792563,-0.0061546303,-0.00071231293,0.0040698647,-0.025004664,-0.013028043,-0.034881953,-0.013924968,-0.027515206,-0.006182494,-0.0071514472,0.029392822,0.017045159,-0.0060355607,-0.01702776,0.017478487,0.008281842,-0.0031913684,0.0001266316,-0.0066483538,-0.0076593333,-0.0030280878,-0.01960846,-0.044566307,0.0065737646,0.0005966007,0.007786309,-0.001805787,0.012478963,-0.006210056,-0.008530625,0.017680978,0.004086167,-0.035072736,-0.0027195583,-0.025808163,-0.02298446,0.0078022312,-0.0091761,-0.0029955206,0.034057006,-0.008053336,0.013106919,-0.0044956584,-0.021167973,0.03261202,-0.03272805,-0.01805509,0.0030527054,0.009427304,-0.01186341,-0.0006528607,-0.007923223,-0.0016417784,-0.04349106,-0.00089045,0.016467482,0.0095938565,0.026901439,0.005481472,-0.008496693,-0.0049759815,0.0029340896,-0.017690033,-0.009614857,0.0089860335,0.0032476166,0.012699601,0.0012020728,-0.024275456,0.0056061414,0.021537099,0.020146241,-0.01067174,-0.00678171,-0.0074230586,0.0014276345,-0.020123517,0.01129701,0.0074429386,-0.0010746267,-0.0007407048,0.00255222,-0.040321197,0.01201266,-0.11301841,0.0035422205,-0.007475506,-0.016266165,-0.030318256,-0.0366876,-0.0014808057,-0.009134037,-0.005941729,0.0011880875,-0.007780527,0.0051299236,0.012070397,-0.001391043,0.01842861,-0.012018761,-0.0139955655,0.0052199047,0.019127462,0.011781752,0.00097093364,-0.020884814,0.0018728239,0.0027528706,-0.022659766,-0.005066755,0.0028205956,-0.0045802193,-0.013585656,0.011390017,-0.003682116,-0.0031357585,0.006346255,0.024526814,0.027158625,-0.017289365,0.0132531095,-0.014229908,-0.002223213,0.027700944,-0.015273086,-0.003814838,0.008154001,0.0006383655,-0.0074390597,0.016883653,0.025816973,-0.0051696887,-0.027590794,0.007052292,-0.033455845,-0.010449216,-0.0072627245,-0.032271013,-0.02543866,-0.01135399,0.0072053447,-0.0055686412,-0.024741916,0.012658791,0.006010558,-0.017872049,0.0039116563,0.026829539,-0.0031404216,0.007857743,-0.0031182657,-0.009003033,-0.0034003397,0.0026045514,-0.02746084,0.007168519,-0.0074144434,0.030061001,0.010893762,0.021468792,-0.00056167255,0.02156749,-0.00076224393,0.0021551342,-0.00017733272,-0.009644698,-0.08431882,-0.0053864764,0.01202128,-0.014451229,0.017526615,-0.010549957,-0.00029564594,-0.011322214,-0.00026737576,0.014715078,-0.0073030447,-0.0015632717,0.00790252,0.0009840885,0.007307367,-0.023267038,0.008872104,-0.0032659636,0.002213545,-0.00294467,0.009065418,0.0041718115,-0.0007397885,-0.024076942,-0.015213106,-0.008763643,0.013418708,9.755733e-05,0.0014572623,-0.016863305,-0.029833673,-0.12988566,0.025075894,0.0074100234,-0.013384685,0.00012514948,0.015102403,-0.00045089875,-0.014946472,-0.034964263,-0.033636425,-0.018076556,0.0036478017,-0.03635186,-0.013973242,0.0036389194,0.11142225,0.024072861,-0.0072987597,-0.0026466772,0.00018212786,-0.0122226365,-0.0226249,0.003938964,-0.015916897,0.007317269,0.00077701866,-0.026674014,0.0087831905,0.022186726,-0.012715279,-0.02836729,-0.004865121,-0.010280084,-0.02657713,0.0020282385,0.0032999753,0.003272389,0.0063907425,0.011337077,-0.0013997537,0.0058447467,0.0531287,0.0058818967,0.018847005,0.0037022773,-0.00048923504,-5.4770676e-06,0.0174179,0.001853828,0.029958254,-0.010866638,-0.06377187,0.021171244,-0.006493684,-0.0001746048,0.029934993,0.009444312,-0.009437626,0.0005059619,-0.026860645,0.03784705,-0.043482065,0.0022581564,0.007693908,0.015542173,-0.022800794,0.04074627,0.0038995687,-0.00081047206,-0.0015807104,-0.028042462,0.011649003,-0.008949546,-0.008483378,-0.003431865,-0.007938347,-0.014042442,-0.01726913,0.010756986,-0.007726479,0.014928631,0.0035218701,0.033826627,-0.022352733,0.03741967,0.0060932124,0.03594462,-0.009921828,0.0014611424,-0.0032386477,-0.01673406,0.013315848,-0.02147514,-0.01696521,0.007445733,0.009671593,-0.01089263,0.007215311,0.007408318,0.022249877,-0.034866188,-0.0021974856,0.015216518,-0.02536763,-0.0019729282,0.032113697,0.009206637,0.0053530415,0.022088287,0.014495426]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (5, 'lich_thi', 'Quy định về lịch thi các môn', 'Kỳ thi tuyển sinh vào lớp 10 THPT năm 2026-2027 diễn ra trong 2 ngày với 3 môn thi: Ngữ văn (Sáng ngày 30/5/2026), Ngoại ngữ (Chiều ngày 30/5/2026), và Toán (Sáng ngày 31/5/2026). Lịch thi này áp dụng chung cho tất cả thí sinh thi tuyển sinh không chuyên. Thí sinh thi chuyên có thêm 1 buổi thi riêng vào ngày 01/6/2026.', 'Cột ''Lịch thi các môn'' ở giữa phiếu', '[-0.021959675,-0.0018363065,0.000877207,-0.055764113,0.0100539755,0.007122738,-0.003943136,-0.01174043,0.0026187948,0.0054641194,-0.012971578,0.024917485,0.016135694,-0.0043109,0.108253986,0.036918633,-0.011252524,-0.0035858597,-0.013905854,-0.013930743,-0.0091323005,0.000549601,0.029886201,0.0009882838,-0.028386442,-0.0046392023,0.015375321,0.011955815,0.04391192,-0.008681431,-0.028617151,0.007883169,-0.0070608133,-0.00041100898,-0.0032814944,0.006751791,0.0046824017,-0.0014914857,0.017424908,-0.021172764,-0.024083626,0.00092601136,0.0077181645,-0.031223802,0.004263404,-0.043800935,-0.0055548283,-0.028051887,0.002014189,0.030574236,-0.021692116,0.008104553,0.0036499198,-0.1912776,0.001423237,-0.010606753,-0.026707733,-0.03806623,-0.013074745,-0.005599027,-0.025965657,0.0323447,-0.01418109,0.017148338,-0.0053030015,-0.004778544,0.003663714,0.02124201,-0.008559179,-0.015603352,-0.020998325,0.0124713965,-0.007779061,-0.0018182349,0.01554761,-0.013191854,0.010172821,0.011549559,-0.013408337,-0.018586703,0.007061808,-0.012058336,0.0066608577,0.0038161422,-0.012147137,-0.031720806,0.0007631404,0.015938535,0.00752045,0.020021059,-0.01926867,0.018918796,0.0052510966,-0.009313821,-0.02741811,-0.0076109325,-0.017606243,0.00888061,0.0017428083,-0.040313028,0.012126205,-0.011601799,-0.0058955844,-0.020099346,-0.001386617,-0.016877547,0.033305336,0.022470342,-0.0020547772,-0.014395604,-7.0804876e-05,-0.02307327,0.0018293149,0.01626821,0.006301481,-0.14143613,0.0014971758,0.005912412,-0.013035064,0.022907702,-0.017011104,-0.00887709,-0.0009712238,0.0072250576,-0.01979105,0.00027296337,-0.012824123,-0.0046328558,0.0038717703,0.004446667,-0.008170376,-0.010202004,0.02722172,-0.018465623,-0.01514786,0.040757257,-0.0080104,-0.016377892,-0.006737968,-0.0026947167,0.013894611,-0.0063536093,0.014274101,-0.011876719,-0.004626604,-0.011006934,-0.04604789,-0.000514693,0.01033185,-0.02394803,-0.014573035,-0.010141671,-0.010086319,0.0049568,-0.007516093,-0.017921064,0.008933405,-0.009180041,0.0039170487,0.022514084,0.008615464,-0.00062304223,-0.015219921,0.032419622,-0.0024628316,0.022840228,-0.0033157356,0.0147640845,-0.0020325829,0.02801006,0.03499619,0.002038375,-0.012738403,-0.0022847992,-0.020347515,-0.0036496797,-0.010381638,0.0018716771,0.0082433075,0.0097197825,-0.020243958,-0.012052778,-0.01628703,-0.004272427,0.010973511,0.009930722,0.028509615,0.0024047103,0.028327646,0.02610474,0.0064153373,-0.013705499,-0.035706703,-0.04582431,-0.015287553,-0.0063345493,0.0050273486,0.0049956576,-0.0054250127,-0.014945177,0.007224868,0.00059090037,-0.0012931535,0.007972245,0.0095681,-0.019956565,0.009168182,0.02414815,-0.011106051,-0.006647625,0.019043546,0.009087811,0.024992896,-0.017429704,-0.01571886,-0.042894688,0.0068980907,-0.012430167,-0.010862964,0.012546792,-0.002638458,0.014864658,0.006445322,0.028550074,0.0008051183,-0.020426776,0.004606306,0.0060519506,0.012361922,0.009531621,0.0051503745,0.0051932107,0.017275231,0.03625048,-0.026484376,-0.0032047217,0.0013962713,0.02783545,0.016105251,-0.0124449385,-0.027914368,0.023510158,0.0030448607,-0.0063132634,0.0035463143,0.0013503996,0.017683197,0.023697881,0.006930168,0.022792919,-0.0071220775,0.005351538,0.015642216,-0.012435262,-0.013172025,0.022456516,0.0020304236,0.010938256,0.011781877,0.015531799,-0.03368804,-0.016431564,-0.03504988,-0.01349883,0.033389475,-0.012596212,0.013280068,0.029448692,-0.02030572,-0.01881745,-0.010176645,0.0026376233,0.002115945,-0.019931562,0.0008277869,-0.022072447,-0.0929046,0.0067047942,0.023554787,0.009964254,-0.0012796366,-0.016637813,-0.008083925,-0.004936738,-0.007858708,-0.011974729,-0.00014916412,-0.009696944,-0.015288804,1.3584306e-06,0.014319378,0.01891284,-0.0008282258,-0.007187918,0.014024907,-0.01661444,-0.018528963,0.006412732,-0.020271964,-0.0014198883,0.021357382,0.019059028,0.004355019,0.03299828,-0.010010079,0.0017215632,-0.0014869376,-0.0042212117,-0.012169433,-0.026043743,-0.016528336,0.0021904337,0.026177684,0.009969612,-0.010650641,-0.021928782,0.000309547,0.008282051,0.02722511,-0.0026061942,0.011535883,-0.0060871826,-0.028473891,0.033872403,0.0155294,0.006014557,0.000991731,0.008443913,0.011333688,0.02196508,0.010833877,0.0018110132,0.009347263,-0.015832815,0.022926975,0.003018691,-0.0054116547,0.009820465,-0.0051647876,-0.0064819218,0.012997561,0.011616532,-0.007426269,-0.004145082,-0.010936972,0.013870355,-0.0053559295,-0.012579234,-0.02070623,-0.0068929736,0.0045309863,0.0024182023,-0.020180352,-0.0024736063,-0.018996397,-0.0005674764,0.001957499,0.008325576,-0.019190159,0.02578169,-0.010617338,-0.020897033,-0.009780127,0.0071573425,0.004512048,0.0041405004,0.0003945631,0.0015460195,0.0074090357,0.009068705,-0.02758381,-0.016497586,-0.0008011265,0.015750924,-0.03050322,0.012413243,-0.011310175,-0.029689223,0.03452345,-0.011820336,0.030478299,-0.012763316,-0.015002205,-0.018224785,0.008538854,0.02987508,0.01352621,-7.8149664e-05,0.008868237,-0.001694895,-0.022833103,-0.0063494286,0.016731104,0.005234077,-0.0009913737,-0.0053469515,-0.009810078,-0.014074774,-0.014315526,0.0060907407,-0.012118416,0.03221607,0.013972138,-0.0042322124,0.0032756417,0.018845774,0.0024286387,-0.018599823,8.536122e-05,-0.012793795,-0.009844768,0.0041444995,-0.010802626,0.011932484,0.022649476,0.021510331,-0.011477798,-0.019352997,0.011663966,0.0069376086,0.002209315,-0.0015755475,-0.010072636,0.015907709,0.025271632,0.0054762675,-0.010333155,0.0058280225,0.010905943,-0.04268526,0.013300869,-0.0031114884,-0.012984053,-0.017101636,0.016560148,-0.010153469,-0.014475265,-0.012191385,-0.00073522626,0.002855181,-0.0129831685,0.0015666682,-0.01897532,0.0069251345,0.0072142524,-0.026308995,0.0053543234,-0.0296473,-0.0023937507,0.01993879,0.04246998,-0.0075843595,-0.03594846,0.016993169,0.009343158,-0.013351009,-0.014276416,-0.020987034,-0.029216273,0.00092076417,0.015481492,-0.00615064,-0.021961583,0.034151718,-0.018935421,-0.007467562,-0.0016446146,-0.020636281,-0.01240036,0.008243847,-0.0067926995,-0.0046409266,0.0051737526,0.003219997,-0.011520006,0.0029844085,-0.011377054,-0.0038974297,0.038124926,0.011482662,0.017223034,-0.012322362,-0.0160136,-0.021375868,0.007815362,0.017638883,0.007935226,-0.027323786,0.0071516447,0.027691025,0.018028423,0.017434025,-0.00090536143,-0.0067260764,-0.008072223,-0.018941524,-0.00714466,0.0062687043,0.005862907,0.01516542,0.0182362,0.013426956,-0.015363104,-0.011018874,-0.034259602,-0.0003139823,-0.031098614,-0.020881014,-0.010572724,0.011796498,0.014395565,0.020523768,0.002149296,-0.0054441425,-0.01246708,-0.028601587,-0.011416492,0.025308521,-0.009961028,0.020941677,-0.010336362,0.0030216367,-0.0009437534,-0.008769496,-0.005568559,0.0069085946,-0.011424347,0.0047466364,0.015030736,-0.003630176,0.009612423,0.024441479,0.020671664,-0.012291916,-0.008014248,-0.015341503,0.0017249478,0.024326729,-0.018249018,0.025869597,-0.0027617519,-0.011794384,-0.0083213225,-0.0078204,0.042773463,-0.10325847,-0.005888803,0.0037216158,-0.028096426,-0.017111871,-0.013833456,0.0058852783,-0.024706827,-0.0012454467,0.008067002,-0.026590824,0.008498146,-0.013283553,0.004812579,0.000731331,-0.015008474,0.005530243,-0.0048339744,0.015592397,-0.013864343,-0.015388356,-0.0016910994,-0.010237313,-0.010055344,0.008846203,-0.0025025115,0.0039956365,-0.029037148,-0.012647708,-0.005922548,-0.030902086,0.013360628,0.0035929661,0.0499013,0.018102981,-0.00675217,-0.008265138,-0.010430163,0.012929977,0.0008061135,-0.0030066397,-0.005713063,-0.020040702,0.006449088,0.014687121,0.010976202,0.0038879367,-0.0098166345,0.0005078224,-0.0045212302,-0.028522538,0.004446429,0.0024346043,-0.037957285,0.0051043853,-0.04275458,-0.02006306,-0.00994843,-0.004977657,-0.00626676,0.018954663,-0.027990524,0.0048398864,0.002043276,-0.030955445,-0.0008432245,-0.018317295,-0.0108070215,0.0032684274,0.0054431004,-0.02072449,-0.012987576,-0.010629361,0.01750161,0.035857607,0.0149844205,0.016988756,0.0036438792,-0.0025564537,0.0066088154,0.0054786955,0.0021256334,-0.09567047,-0.014351933,0.0246906,-0.0065230355,-0.0035141394,0.020049097,0.024936346,-0.020477822,0.013335743,-0.0126274945,-0.015859134,0.028312532,0.0061696717,-0.009811964,-0.0032218464,0.007240733,0.027138678,0.015105754,-0.019836217,0.01679893,0.00419598,0.00045407357,-0.0009676647,-0.026171932,-0.018293364,0.011335538,0.01116683,0.028893525,-0.004488196,-0.021943728,-0.009579799,-0.15055442,0.0077522327,-0.0025365634,-0.014773715,-0.005021955,0.010442668,-0.006340114,-0.005509177,-0.010995301,-0.018444953,-0.016659403,-0.0055489363,-0.01137966,0.010608491,0.0019376323,0.07754705,0.028272908,-0.0010352259,-0.035268705,-0.022437695,0.0073154275,-0.019218143,0.008301851,0.0010469625,0.035911016,0.016740177,-0.0148729775,0.002048791,0.026241692,0.026670244,-0.0089805275,-0.0060140025,0.020324863,-0.0069652386,0.0069069187,0.016426964,0.00050055166,0.0023763988,0.021651685,0.001365339,0.017777393,0.016203279,0.026017457,0.007895382,-0.023427257,-0.020718617,-0.0043224758,0.0030472726,-0.00077148015,0.009574337,-0.03694844,-0.060329095,0.0115356995,-0.014871831,0.018010471,0.0089900885,-0.018112747,-0.0011245398,4.2328735e-05,-0.006651929,0.016845753,-0.0001149064,0.013754845,0.047043037,-0.008284434,-0.00034749776,-0.0043428587,-0.003699198,-0.0017118556,0.005423947,0.00092596863,0.016590679,-0.032344077,-0.02255927,-0.014096987,-0.0086509595,-0.010178241,0.026523849,-0.001491965,-0.034632694,0.044499636,0.042519145,0.005754412,-0.017476121,0.011670996,0.0077259773,0.017062536,0.012364531,0.0138252545,-0.015938453,-0.014491792,0.0084014,-0.019905547,-0.017209211,-0.0014976129,-0.011449072,-0.021968648,0.011486473,-0.011049041,0.029367106,-0.008767218,-0.031360056,0.007725906,-0.0070461635,0.010982163,0.015371604,0.00318165,-0.008691265,0.028636016,0.0056255464]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (6, 'thoi_gian_tap_trung', 'Thời gian và địa điểm tập trung làm thủ tục dự thi', 'Đúng 9h00 ngày 29/5/2026, thí sinh có mặt tại trường THPT được chỉ định (điểm thi) để làm thủ tục dự thi. Địa điểm tập trung chính là điểm thi ghi trên phiếu. Ví dụ: thí sinh thi tại THPT Nguyễn Quốc Trinh thì có mặt tại Thôn Đại Áng, xã Ngọc Hồi, Hà Nội. Thí sinh cần mang theo phiếu báo thi và giấy tờ tùy thân.', 'Dòng in nghiêng ở giữa phiếu, ngay dưới thông tin cơ sở giáo dục', '[-0.019186236,-0.01504001,0.014254687,-0.033273686,-0.0036577964,0.003622326,-0.0048002056,-0.014864763,-0.0024152792,0.0075171804,-0.033888068,0.023006229,0.003331611,0.016115222,0.12376439,0.03323989,0.012079505,0.0145326,0.018781466,-0.008906199,-0.034906607,-0.016335325,0.0090422975,-0.0065100216,-0.0017511523,0.01528383,0.0061404943,0.00788623,0.023628589,0.012027268,-0.026878368,0.012563766,0.007962629,0.04418562,-0.009074176,-0.0026019984,-0.01208552,-0.028072476,0.018404994,-0.019891422,-0.02017729,0.0018745486,0.0068355217,-0.01981976,0.002215926,-0.034965374,-0.0043514683,-0.019887147,0.027817233,-0.0067652706,-0.0076762163,0.0074341465,-0.024756204,-0.1920466,0.008459118,-0.013527069,-0.016107703,-0.008933741,-0.030916398,-0.012114044,0.0015080473,0.022353662,-0.011055173,0.0021921333,-0.0019176543,0.007459821,0.004203796,-0.0012147744,-0.03018968,-0.013850741,-0.012336172,-0.0031549407,0.0042896103,0.0035522294,0.014407184,-0.025268918,0.0039032886,-0.01205291,-0.006134191,-0.01774202,0.004625101,-0.019466888,0.017529462,-0.0213777,-0.016801998,-0.023171756,-0.021183867,0.0039084395,-0.0015080879,4.6977716e-06,-0.012907815,0.016157884,-0.006607123,-0.03222895,-0.0013805822,0.00079904025,0.0050383634,-0.0076092337,-0.008990434,-0.01701792,-0.005383072,-0.020959284,-0.02663669,-0.033154488,0.026568912,-0.03657839,0.048189536,0.009770518,0.039881147,-0.036201116,0.0016208929,-0.00778432,-0.011408677,0.0073621464,0.018999493,-0.15387161,-0.0095288325,0.003189008,0.009439796,0.01583398,-0.020530794,-0.034422927,0.023515927,-0.027492875,-0.0060142027,-0.0005985146,-0.041152027,-0.0048184087,0.010297084,-0.013025769,-0.008703983,-0.013514137,0.025042692,-0.017399486,-0.0033009066,0.010403065,-0.007724695,-0.009578781,0.014858509,-0.006189822,-5.397254e-05,0.007191084,-0.015892243,-0.023893017,0.0016662668,0.005478642,-0.039832305,-0.010330019,0.014107135,0.0067758295,-0.025054958,-0.012796228,-0.0028328223,-0.009792955,0.007346653,-0.018211251,0.027672421,-0.0041771964,-0.006374507,0.03618933,0.032030113,-0.005283293,0.007546424,0.0016239962,0.008696522,0.032876432,0.010952222,0.007381794,0.02241559,-0.009249857,0.017457489,0.0034809783,-0.005414016,6.436155e-05,0.001046546,0.008109801,0.013029587,-0.0069106612,0.010815361,0.020923534,0.0048704958,-0.019289078,-0.011686499,0.0006633117,-0.004860682,-0.0093690725,-0.005998231,-0.018273477,0.0054460973,0.008931315,-0.0026235066,0.016396314,-0.036996067,-0.0288706,0.006908912,0.0015947862,-0.0030126893,0.01759806,0.014348948,-0.016555618,0.0074448036,0.013927655,0.02204699,0.00577292,-0.0025246441,-0.0064643417,-0.0011893928,-0.0013798166,-0.021704441,0.015407581,0.0054032207,0.0044173873,0.032031983,-0.013228126,-0.01203506,-0.02989441,0.015993012,-0.019675525,0.004677008,0.023827448,0.033722386,-6.282616e-05,0.004884082,0.042621046,-0.009249821,-0.0012759917,0.012914854,-0.0044117505,-0.011921423,-0.009011347,0.030554011,0.0028181104,0.02960873,0.024129653,-0.027065158,0.0010974378,-0.007916076,0.0019598186,0.026294999,-0.01690058,-0.01942015,0.02273345,-0.0024026183,-0.0091307,0.00951386,0.004099914,0.01079862,0.020158788,0.014848555,0.0034130546,0.0042304485,-0.025947066,0.013290504,0.0029401192,-0.031328086,0.013461157,0.015238355,0.01942408,0.0013408457,-0.0014796132,-0.03299869,0.007033008,-0.022301612,-0.013939658,0.0006677525,0.0149442265,0.006132749,0.025329385,-0.018951727,-0.0047391993,0.01481928,-0.0021294195,0.0044449787,-0.006962356,0.0127918,-0.0047340854,-0.08750055,0.023840405,0.03062751,-0.0035251067,-0.04874541,-0.008531044,-0.006129748,-0.00769106,0.002128522,-0.024447508,-0.015809076,-0.029480968,-0.017362988,0.0021569887,-0.0028020926,0.008928176,0.01641608,-0.021684418,0.014803958,-0.015468013,-0.014985726,-0.007923881,-0.043654498,-0.013634704,0.0030666878,0.020511044,0.033334322,0.028453903,0.014314351,0.002815135,0.006051921,-0.00494397,0.011556858,-0.014911031,-0.027188854,-0.017553335,0.0058295056,0.0124565745,-0.003683616,-0.021700904,-0.0013008623,-0.0005448786,0.03408353,0.00840057,-0.009033408,-0.0019559732,-0.03171904,0.03740876,0.0007744749,0.01872117,-0.0035437183,0.009980456,-0.012944559,0.022208016,-0.00045661506,-0.02535746,0.017280927,-0.01301077,0.0124779185,0.013707725,0.008286874,0.014954359,-0.016462866,0.0164935,0.0023025265,-0.005778361,0.008325043,-0.004823898,-0.017531663,0.007556625,0.0010637201,-0.01573248,-0.023949316,-0.02486028,0.004486129,0.008623517,-0.037835687,0.007170177,-0.0009333983,0.008477441,-0.014074591,0.02174878,0.0075452016,0.038490057,-0.013370961,-0.029605735,-0.0067226854,0.005641982,0.012866301,-0.03059758,0.0062313424,-0.010493731,0.01861159,0.0063209706,-0.025491742,-0.007669548,0.019408774,-0.003523441,-0.019766359,0.012965113,-0.012540316,-0.019563744,0.019700812,-0.02337451,0.009120023,-0.024649894,-0.0043686167,-0.0038288077,0.005784803,0.021388363,0.017557714,0.001762338,0.0023184903,0.0022977628,-0.0020439834,-0.011361409,0.00029378748,0.0018677962,-0.0065649776,-0.0027168558,-0.0036167263,-0.01513698,-0.0023473548,-0.0024018495,0.013724152,0.02246987,0.008950959,-0.006981302,0.028587274,-0.010174957,0.015789386,-0.030572664,-0.01576329,-0.0029272318,-0.017681962,0.012322165,-0.0032298602,0.031752717,0.04250275,-0.003684376,-0.041165654,0.0037908358,0.01943556,0.01072576,-5.8093945e-05,-0.003827539,0.003369695,-0.0049554235,0.015897619,-0.0032051587,-0.01186606,0.027427204,0.0012715331,-0.014851081,0.0053584143,-0.01722268,-0.010884994,-0.004323876,0.0076027396,0.010712382,-0.011414149,0.0023608934,-0.013790801,0.0018955563,-0.011538954,0.02812923,0.013078691,-0.012035735,0.017939214,0.0177065,-0.014698889,-0.0039797816,-0.025905386,0.033644598,0.01443682,-0.0023382069,-0.014954061,0.011318312,-0.0077655884,0.019410936,-0.012606263,0.013282218,-0.0231521,-0.015714722,0.025784776,0.0007521587,-0.004429793,0.020615777,-0.009554801,0.0068312883,-0.005878169,-0.02029118,-0.0037224165,0.01132572,0.007913736,0.011946516,-0.006074506,0.010478727,0.009645538,-0.0042984467,-0.00052629394,0.019201254,0.021250047,-0.00033467414,-0.00562342,-2.5047399e-05,-0.020110782,-0.024896046,-0.0057979324,7.8093144e-05,-0.0014334511,0.0048995176,0.019056562,0.008258632,0.005602153,0.024872735,0.008737559,-0.016048025,-0.03149239,0.019491741,-0.010265425,-0.002255412,0.0122004,0.016260361,0.011528791,0.0094761085,0.0027312895,-0.028368,-0.013094339,-0.016204705,0.003523725,-0.006469142,-0.0017717088,0.012515197,0.017692028,-0.0021516893,0.003089374,0.011208678,0.0020351904,-0.0022638482,-0.023348758,0.018988619,0.018391076,0.014851227,-0.005443535,-0.0048539904,-0.009819516,0.0042100726,-0.024650307,0.00060685404,-0.014754837,0.01397189,0.024679555,-0.0114753395,0.006860022,0.0030587325,0.032023177,-0.021664003,0.0011760123,-0.0047931666,-0.0112656215,0.033087954,-0.011306242,0.008626908,-0.01275148,-0.013718518,0.0039908504,-0.005733576,0.021387888,-0.12714793,-0.016948663,-0.0014344617,-0.0037049977,-0.01764964,-0.021215042,-0.0073139635,-0.039710693,-0.0075018797,0.024435405,-0.02161642,-0.026065897,-0.003276205,-0.014835325,0.0020007398,0.00015193087,-0.0031297712,-0.004457518,-0.0055941823,-0.033418167,-0.008996723,0.019861054,0.0012657163,-0.011033194,0.0003280925,-0.019552674,0.028328346,-0.0033251096,0.008023608,-0.00010592868,-0.01480195,-0.020295577,-0.005258364,0.033350766,0.03718982,-0.0114983,0.016419724,-0.020382587,-0.003977588,0.03379171,-0.0020694677,-0.007710147,-0.01838471,0.0126312245,0.018940553,0.0047118613,0.023449669,-0.04807058,-0.013198514,0.016339324,-0.011664615,0.009310742,0.013718956,-0.018973019,-0.020224787,-0.0056870095,-0.01166158,0.0005679776,-0.020541275,0.0008357333,-0.0016381143,-0.0165386,0.010381938,0.0067639733,-0.0054195207,0.011893467,0.0081958445,-0.019676993,0.0048041022,0.0035025594,-0.015843062,0.017345455,-0.0186287,0.018497353,0.010963583,0.027859554,0.027233496,0.0077021,-0.012155022,0.000108057604,-0.009954678,0.02288575,-0.0958471,-0.023658406,0.016890418,-0.012800861,0.0067230687,0.03141314,0.025622608,-0.012419685,-0.00916305,-0.006945338,0.008265584,0.003936991,-0.0036662603,-0.0075337016,-0.030382263,-0.0082709845,0.0038951389,-0.012725876,-0.037769563,-0.005543374,0.011642689,0.0019530351,-0.014854501,-0.004806035,-0.010740982,0.014055164,0.034786467,0.02945543,0.023219356,-0.021943906,-0.007427624,-0.12528916,0.019310832,-0.008546361,0.008716807,0.016957926,-0.002122391,-0.020060247,-0.0059832376,0.012703011,-0.023349896,-0.008120045,-0.016307456,-0.00021138754,0.011532767,0.003588793,0.08850706,0.03409994,0.017605118,-0.02208357,-0.011211622,0.006059839,0.0013565152,-0.009704162,-0.018672828,0.029615816,-0.005572331,-0.010108158,0.016585335,0.027079837,0.019157005,0.0018296881,-0.0041878824,0.0062846527,0.008077651,0.017206658,0.016728995,0.0047305026,-0.0008590826,0.016400605,0.022937536,0.003789799,0.0152825,0.0065069026,-0.0026980033,-0.006943688,-0.014769009,-0.01297856,0.023009833,0.0053615985,0.0053912234,-0.030049138,-0.035884857,0.0080131665,0.0029579143,0.015599214,0.012269543,-0.02441327,0.02106371,0.0048700864,-0.014845837,0.007506182,-0.016097877,0.0023555448,0.007900933,0.0054353555,0.004017513,-0.0042206906,0.030272685,-0.0050469986,0.014134064,-0.01612698,-0.0016922543,-0.023151163,-0.019470615,-0.016100736,0.028686656,0.010431527,0.01426859,-0.01650702,-0.010972483,0.039394215,0.02287241,0.0008952331,-0.0010558675,0.0026634778,-0.00044073505,0.009540663,0.021862278,0.0012491731,0.0046526887,-0.018563142,-0.012223409,-0.0060899877,-0.019522619,0.012963227,-0.011961358,-0.011719959,0.011708666,0.023202345,0.014719532,-0.013527073,-0.038783357,-0.011460684,-0.010752901,0.0010968853,0.031014167,0.0078043276,-0.01863356,0.01276206,-0.011707856]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (7, 'thoi_gian_du_thi', 'Quy định giờ có mặt để dự thi', 'Thời gian có mặt để dự thi: Buổi sáng 7h00, Buổi chiều 13h00. Đây là giờ thí sinh phải có mặt tại phòng thi, không phải giờ bắt đầu làm bài. Lưu ý thời gian này khác với thời gian tập trung làm thủ tục (9h00 ngày 29/5/2026).', 'Phần ''Lưu ý'' cuối phiếu', '[-0.0038325307,-0.0034235013,-0.0017380523,-0.048550867,0.0010818029,-0.007937065,-0.003441328,-0.029631194,0.0032021385,-0.009659453,-0.036213562,0.017885445,0.008960254,0.0018661814,0.11387266,0.02537244,0.008124929,0.0032221393,-0.0057759094,0.009982362,-0.013800462,-0.013554341,0.025793705,-0.002880568,-0.010004707,0.010379761,0.0053824997,-0.010320999,0.039075017,0.0057059024,-0.033367198,0.004143347,0.01078237,0.033656046,0.0034763317,-0.018932814,0.006127395,-0.013292349,0.012717539,-0.007725591,-0.01540358,0.01542424,0.0007661711,-0.0012859594,-0.008946702,-0.020099,-0.007753276,-0.0018450064,0.017149754,0.015978495,-0.01578985,0.010810545,-0.017603057,-0.18585096,-0.0039324784,-0.007097961,-0.012559738,0.0063388813,-0.022754584,-0.0065322937,-0.019725392,0.022160113,-0.0018515784,0.0038351463,0.011600527,0.011905314,-0.0059853187,-0.009110925,-0.01422154,0.00020281087,0.0016732111,0.000572519,-0.0051804027,-0.00296959,0.007628234,-0.010586388,-0.0050741197,0.0042802356,-0.026075369,-0.028157532,0.00504541,-0.030115517,0.002099859,-0.011938522,-0.00871649,-0.007065114,-0.011691164,0.0041723275,0.010213752,-0.0063434155,-0.01501176,0.026541287,0.004743753,-0.026858954,-0.0035966155,-0.002058657,-0.0027101624,-0.0040644743,-0.011683229,-0.016042456,-0.007406239,-0.013037431,-0.015969265,-0.020414121,0.017424379,-0.036782317,0.028168688,0.017227713,0.017012438,-0.025862293,0.009061484,0.001034842,-0.01101728,0.006635379,0.0072438563,-0.1521411,-0.0007954922,-0.0062701497,0.0072432165,0.023817323,-0.031234413,-0.011083896,0.0025298765,-0.019102478,-0.015171832,0.0030864843,-0.0093241725,-0.0051351893,0.012816376,-0.004390774,-0.005175582,-0.00095286284,0.041096587,-0.0012113724,0.0142988,0.027311606,-0.0057878317,-0.022417821,0.01923947,-0.0154357245,0.0012227023,0.006545402,-0.0045630685,0.0034757531,-0.022012092,-0.009022202,-0.029166203,-0.007686364,0.015794083,-0.014187796,-0.025382876,-0.010612343,-0.029398236,-0.0018324031,0.0025708512,-0.018658642,0.040467776,-0.01354572,0.01737949,0.025455344,0.014526783,-0.007669986,-0.010169102,0.016450675,0.013747602,0.029863829,-0.0033746932,0.020065414,0.032382358,0.021923916,0.0022250547,0.024879433,-0.011192636,0.0031218827,0.0011912871,-0.008728794,0.011618505,-0.016841274,0.0076552234,0.015578846,-0.010054871,-0.015711648,-0.017510727,-0.002583107,-0.00053125416,-0.0035678959,0.012308668,0.011844772,0.023744227,0.0024571687,-0.0016699377,-0.010444337,-0.033558346,-0.03754336,0.016152434,-0.0015398905,0.0056394334,0.013563006,0.009208979,-0.0028613138,0.0031957491,0.021797951,0.0027262499,0.003878011,-0.014718996,-0.014962316,-0.01187773,0.02496759,-0.0213036,0.014929985,0.008780753,0.0026487263,0.015101985,-0.014426834,-0.0057011317,-0.03887282,-0.010463036,-0.024080442,0.010632983,0.008512799,0.023899322,-0.015206204,0.007818497,0.028371181,0.005313734,-0.009839875,0.005518487,-0.0068189697,0.01925395,0.027427888,0.039647892,-0.01144709,0.030626127,0.0074564125,-0.027302107,-0.014995534,-0.0052087666,0.0150792925,0.059954118,-0.01635805,-0.034998305,0.028753858,0.01195202,-0.0038437024,0.018244011,0.004105775,-0.010954889,0.014215586,0.035605814,0.010846453,-0.0048547173,-0.017014392,0.015898595,-0.003410126,-0.009206286,0.012459471,0.014832547,0.023779666,-0.0035960656,0.0055267913,-0.027920287,-0.0029098215,-0.015294018,-0.002709097,0.02024293,0.0040109204,0.016956367,0.015091681,-0.011330717,-0.0028128186,0.019194206,-0.017240187,0.0020604017,-0.0010080996,0.00052761595,-0.025017519,-0.0905214,0.020040827,0.030065913,-0.013364221,-0.023636458,-0.034336273,-0.0074617085,0.007084829,-0.0022450874,-0.04749555,-0.0044845263,-0.009779102,7.977814e-05,-0.0043412,-0.0060389605,0.022956943,0.0010731437,-0.008254368,0.0033004165,0.0038604948,-0.008873197,0.0013196954,-0.032173686,-0.0043990305,0.010174128,0.02177895,0.0393863,0.03700304,6.892407e-05,0.006703524,0.011136436,-0.00037654012,-0.005534437,-0.027638625,-0.01980955,-0.015105913,0.007722399,0.02136674,-0.018709768,-0.014115157,0.017988674,-0.0051068035,0.018219046,-0.0036738766,0.0034738567,0.015555373,-0.035374586,0.02890117,-0.02703055,0.008495218,0.0068960167,0.013597041,0.0016628342,0.022989696,0.016130518,-0.01642903,0.038584024,0.00455916,-0.006306215,0.018032642,0.017885415,0.02774849,-0.02033113,0.0124356225,0.007405453,-0.021139102,0.004145305,-0.01126245,-0.0141748525,0.024618518,-0.0032807589,-0.012656967,-0.0328811,-0.039585043,0.019850992,0.00083492516,-0.015283469,-0.0034946257,-0.0009423332,0.0071545932,0.00791284,0.024620935,-0.005777443,0.038576674,-0.005596562,-0.02512846,0.004728853,-0.003710768,0.011966744,-0.0035733515,-0.006512938,-0.01298076,0.0049144537,-0.0027505488,-0.016645523,-0.016316682,0.016328998,-0.012279373,-0.0075821206,0.027675867,-0.0036549952,-0.004977339,0.032062657,-0.01624532,-0.012101208,-0.027566107,-0.021296818,0.0030641512,0.003922459,0.01742653,-0.007021313,0.008725265,0.0018183906,-0.015059916,-0.017536853,-0.028184745,0.017678017,0.0060777897,-0.0013093894,-0.012967138,0.002827486,-0.012476549,0.016652124,-0.010242157,-0.0088802595,0.031455122,-0.002997513,-0.008834357,0.01022879,-0.011309389,-0.006899941,-0.031646688,-0.0002975338,-0.005571655,0.001397312,-0.00015707208,-0.008852639,0.045980424,0.023400584,-0.0066881883,-0.0226275,-0.0044626156,0.024249258,0.016531115,0.010554459,-0.010815165,-0.0034242226,0.011719996,0.014966089,-0.005993863,-0.009550373,0.026592612,0.01800987,-0.010280775,0.012629963,-0.013264785,-0.018800693,-0.0007474112,0.011487348,-0.013767211,0.0021495072,0.003749862,-0.01821366,0.011841059,0.005053357,0.018852027,0.008099174,-0.025351092,0.003214236,0.011019796,-0.013562544,-0.0050420645,-0.013337696,0.031368863,0.017978558,-0.0056979666,-0.020994458,-0.00807193,0.0020961508,0.008501228,-0.025012035,0.00608782,-0.022680074,-0.028428016,0.016405001,-0.01746352,0.0076706433,0.024686588,0.010534573,-0.004677928,-0.0012923542,-0.02630088,0.008969153,0.021824209,-0.0055284714,0.011099896,-0.012524168,0.008956889,-0.001442417,-0.032715376,-0.0075075277,0.003653488,0.015892338,0.010130349,-0.0015763966,-0.00829182,-0.022898072,-0.009829111,-0.0065907957,-0.014433717,0.00058350735,0.002505955,-0.00028761046,0.011072577,-0.0004143233,0.023540186,0.0050493693,0.0029725353,-0.014835638,0.005503261,-0.013826066,-0.013699758,0.013426476,0.022014566,0.003807761,-0.0056515755,-0.027001368,-0.033757806,-0.021927238,0.0045067305,0.0032319506,-0.00027012435,-0.005589475,0.009554231,0.03604373,0.0071539553,0.013866911,-0.003787144,-0.015827855,0.0003320323,0.004007282,0.027955523,-0.015561847,0.02200591,-0.0047048987,-0.013830902,0.006814622,0.012310434,-0.023690283,0.011350503,0.0050113574,0.0025344237,0.02083789,0.00692179,0.014358343,0.0025575086,0.040673397,0.007389907,0.017287487,-0.0037558994,-0.022353334,0.03843686,-0.01813822,0.0040224786,-0.0067451177,-0.024914496,-0.017576126,0.00719435,0.0011938277,-0.12162221,-0.019533303,0.001223154,-0.020131966,-0.0061077313,0.0026732741,0.0073005413,-0.027715907,-0.0013066152,0.010280195,-0.0297211,-0.006806111,-0.0062594796,-0.025642864,0.0077072787,-0.0010847773,-0.012527928,-0.0018175681,-0.014158026,-0.033574183,-0.031902883,0.018908395,-0.001995839,-0.030817494,0.002960162,-0.026696641,0.025099969,-0.021953288,0.0004705417,0.00056148146,-0.0026970739,-0.025622312,-0.005745375,0.010598537,0.02600975,-0.0072765164,0.0045266612,-0.012712257,-0.0011500962,0.044055365,0.0099468315,-0.010200982,-0.0034648087,0.008376421,0.015718548,0.00036731502,0.019526215,-0.040279523,0.0046407473,0.015524105,-0.007146669,0.014356315,0.0012696909,-0.026148045,-0.01693102,-0.0053863088,-0.0044828164,-0.00015671235,-0.032652386,-0.0056920364,0.0036663017,-0.028178439,0.019785587,-0.0028467206,-0.01641764,0.002344841,-0.028710563,-0.012414912,0.0077743717,0.0047301324,-0.018920094,0.013062742,-0.02473536,0.025085773,-0.013004569,0.012830454,0.026086593,0.019605704,-0.014581559,0.01513041,-0.017273245,0.0070530525,-0.08867583,-0.019420655,0.015432215,-0.016453244,0.008192944,0.015918382,0.016618477,-0.004483611,0.005171797,-0.015647883,0.006478594,0.014299745,0.019705031,-0.01763395,-0.018371547,-0.0016111208,0.015740328,-0.023011114,-0.009988521,-0.018868772,-0.0038986693,-0.0042139525,-0.013554574,-0.010782969,-0.022521064,0.019889332,0.028212983,0.022947708,0.0075735813,-0.021269139,-0.010361293,-0.12854755,0.0037617595,0.0009483535,0.02395083,-0.0073652966,0.014141436,-0.024582246,-0.020412479,0.01571507,-0.0021646037,-0.0078059486,-0.004240229,0.0047639054,0.01024634,-0.007444809,0.081581496,0.04358556,0.021754032,-0.03965528,-0.010213274,0.0033481999,-0.0054652113,0.00851296,-0.021239115,0.027198814,0.024429405,-0.01108157,0.024556758,0.024659358,0.037143122,0.02359036,0.0008084231,0.0040394287,-0.007652922,0.0001172076,0.019287951,-0.0007624645,-0.003249028,0.020873617,0.009334384,-0.01032107,0.0019414674,0.015874723,0.010094663,-0.016423795,-0.009117825,-0.014533937,0.0041068015,0.015214921,0.014928404,-0.034032665,-0.04365414,0.02434233,-0.007084216,0.027867043,0.0049739876,-0.014408344,-0.0033010212,0.009708838,-0.0037878498,-0.007863548,-0.014007676,0.003920838,0.005061688,0.0073219864,-0.009000769,-0.0183802,0.026720751,0.0009871494,-0.010518625,0.011299435,0.007345445,-0.01281701,0.0036332814,-0.01852038,0.035369385,0.022868894,0.02057398,-0.004968325,-0.017453182,0.021751583,0.02026735,-0.004148275,-0.013036882,-0.009889701,-0.0036834746,0.033916514,0.019040953,0.002810858,-0.016743062,-0.014248444,-0.020816581,-0.009303789,-0.020482482,0.0074399333,-0.008411322,-0.013807093,-0.02246683,0.0069002574,0.010508025,-0.031469572,-0.037509732,0.008373461,-0.028574945,0.010784188,0.056574587,0.00028529606,-0.022553496,0.015144121,-0.011094352]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (8, 'diem_thi', 'Thông tin về điểm thi và địa chỉ điểm thi', 'Mỗi thí sinh được phân công một điểm thi cụ thể ghi trên phiếu. Điểm thi là một trường THPT tại Hà Nội. Phiếu ghi rõ tên điểm thi, số báo danh, phòng thi, và địa chỉ chi tiết của điểm thi (ở phần Lưu ý cuối phiếu). Trong lớp 9A5 THCS Chu Văn An, các thí sinh được phân bổ thi tại nhiều điểm thi khác nhau trên địa bàn Hà Nội.', 'Dòng ''Điểm thi'' và phần ''Địa chỉ Điểm thi'' cuối phiếu', '[0.002233577,-0.01177298,-0.012598705,-0.0301857,-0.024235664,0.012278913,0.00093756255,-0.014339663,-0.0091059115,0.01852205,9.163052e-06,0.014940664,0.014579401,0.008968876,0.11702658,0.028013144,-0.00319638,-0.0015447368,0.0046539544,0.0027646678,-0.011059488,0.0111319935,-0.0020911298,-0.008151729,0.0032959646,-0.005739069,0.023243954,0.019576676,0.016802384,-0.0032969269,-0.02940647,0.0041985596,0.012077655,0.04863635,0.009055888,-0.005410467,-0.0023217776,-0.030090207,-0.0028839137,-0.023000373,-0.017227262,0.002097042,0.014947478,0.005901998,0.020785596,-0.02906302,0.013531816,-0.030245507,0.007918142,0.008005425,0.0240989,0.017754849,-0.022441119,-0.19195387,0.008725238,-0.03025213,-0.026064884,-0.0012789734,-0.0018413455,-0.004600004,-0.010194824,0.011219217,-0.03198232,-0.0037962212,0.02623358,-0.020418901,0.02507284,0.010099684,-0.032780852,-0.025400924,-0.009439073,-0.00010549875,0.0010037172,-0.009603174,0.020159958,0.0040874113,0.014469176,-0.017534522,-0.0030746383,0.001186969,0.01231326,-0.004404683,0.0010994689,-0.011378753,-0.011762185,-0.024642246,-0.030823918,0.00436738,-0.005548413,-0.004562009,0.00096377474,0.00969599,0.009040581,-0.019621562,0.0046854317,-0.002975617,-0.0021495712,0.012342796,-0.00087583956,0.00045084712,0.002925347,-0.010195065,-0.033052325,-0.017486373,0.01299662,-0.039467957,0.04341998,-0.0038711857,0.012683565,-0.031180924,-0.015983038,-0.011641908,0.005627051,-0.0030051859,0.039297286,-0.1446708,-0.016229106,-0.005866744,-0.00044680657,-0.019555602,-0.016738484,-0.004449529,0.0039181965,-0.0035539009,0.0026716494,0.008369869,-0.012059456,-0.011586234,0.038007036,-0.005644202,0.0008937206,-0.00750231,0.019226102,-0.013582544,-0.016195,-0.0046680486,-0.016926127,-0.02588726,-0.0032622705,-0.006183391,-0.0024785893,-0.008608785,-0.01456359,-0.007750844,-0.00038038963,0.006485329,-0.038253907,0.0003511823,-0.021915345,0.0037425924,-0.02702439,-0.01753626,-0.010858913,-0.004935602,0.008234301,-0.0035431597,0.025088416,-0.020985221,-0.019710425,0.03425554,0.022598293,0.00039612027,-0.00536445,-0.006189884,0.003198245,0.04818268,0.009392792,0.01958715,0.008891339,0.012281416,0.021644723,0.007584488,0.0045837625,-0.0017258284,-0.02034189,0.0025226302,0.048170216,0.002221081,0.030209396,0.015674055,0.024810761,-0.009579008,0.013745456,0.0063958843,-0.007807697,-0.0020789157,0.0048597422,-0.022728136,-0.0035551882,0.017168965,0.0060867495,0.020928461,-0.035023853,-0.0013995706,0.0066467826,-0.03013131,-0.0088573815,0.008459398,0.0008678227,0.00077826355,0.016994018,-0.01510251,-0.018165994,-0.011949406,-0.009314747,0.005381044,-0.0013932107,-0.011532693,0.010198629,0.011993842,-0.013656253,0.021915741,0.032527212,-0.013019136,-0.009543281,-0.015887324,0.01471872,-0.017119111,-0.008873538,0.01073549,0.015076575,0.00053310476,-0.0019193635,0.043528173,0.0027007703,0.018490266,0.000952546,-0.00014039385,-0.0175428,-0.022932349,0.036407214,-0.0073072747,0.013756671,0.0011491609,0.013823034,-0.00511853,-0.011805973,0.026017496,0.007753567,-0.021266568,-0.014953253,0.005725877,0.007009393,0.02984648,0.020047238,-0.015172532,-0.01355768,0.023494868,-0.0047409344,0.01754772,0.010714313,-0.014360483,-0.0015276461,-0.013347916,-0.029330894,0.0077469754,0.009543753,0.009738217,-0.006124928,0.019748181,-0.02433041,0.008944431,-0.024801694,-0.02081627,-0.004131278,0.01897332,0.027732389,0.012114691,-0.03215993,0.01889388,0.0017639406,0.007705777,-0.010466003,-0.018808642,0.025172293,-0.0040772413,-0.0734728,0.0105528,0.022493333,-0.029236563,-0.016782377,-0.0051424,-0.012063015,-0.011360723,-0.011785944,0.0044753347,-0.035723288,-0.007434275,-0.009269813,0.0002576484,0.002596061,-0.01246761,0.005935948,-0.015335661,0.029192368,-0.011166829,-0.016663902,-0.0022190937,0.0018083295,-0.0096256975,0.015783498,0.022250796,0.019704306,0.029289806,0.019132433,-0.009187897,-0.011082222,-0.017326547,0.0010981526,-0.03146014,-0.03921575,-0.0010300411,0.016189367,0.0053034285,-0.0013761091,-0.022553569,-0.02168959,0.01392051,0.02573664,0.00470181,-0.015724763,0.018852273,-0.021987792,0.03696117,0.004591399,-0.0059622666,-0.0073955664,0.014253444,0.0045865867,0.02550578,-0.004358268,0.00064646127,-0.009247774,0.008180376,0.036084466,0.029085854,-0.005954397,0.018247394,-0.030635582,0.0076739886,0.0070543974,0.0057124565,0.0057991464,-0.012122511,-0.03738869,0.008702584,0.0017045483,-0.010131316,0.00097620825,-0.024350315,0.014456133,-0.00011140163,-0.016987253,-0.028928071,0.03815382,0.029953761,-0.015643138,0.0061650486,0.010683308,0.03586659,-0.016232455,-0.026153196,-0.007116882,0.0054296106,0.01647138,-0.055266093,0.008665625,-0.005821214,0.015428417,0.0021011734,0.002897013,-0.01726838,0.020833267,0.011616197,-0.014261474,0.01707267,-0.025575314,-0.00028864425,-0.008325595,-0.0062398384,-0.0017546039,-0.030779924,0.0006811653,-0.0238956,0.023274213,0.015393208,0.029124137,-0.006431037,0.009658791,0.0047493256,-0.0060829283,-0.00425429,0.023556875,0.015850963,0.0013163105,0.008894416,0.0021050305,-0.012655695,-0.001505755,-0.0080792485,-0.0012613415,0.02203459,0.014033228,-0.020935597,0.013475606,-0.004352131,0.0022016773,-0.036817823,-0.001593087,-0.01026028,-0.017564107,-0.0016401296,-0.011844194,0.019523479,0.03317617,0.004283609,-0.022846904,-0.0105214305,0.0048935274,0.011341152,-0.0069278404,0.00838105,0.0004843002,-0.008337584,0.0048814854,0.009711572,-0.015504572,0.0069664004,0.016494837,-0.026683746,0.001759067,-0.010384157,-0.040106222,-0.001124283,-0.0053746295,-0.004579282,0.010698493,-0.027512869,-0.022825468,-0.023137346,-0.01680945,0.017192533,0.0018951354,-0.03592067,0.015045548,-0.004876099,-0.000820025,-0.011931473,-0.012736912,0.0005599663,-0.0030242414,-0.0008625234,-0.010739395,0.0022443375,0.0034955973,0.01547401,-0.012390355,-0.005825293,-0.03668919,-0.026420835,0.013137999,-0.013868773,0.0002239748,0.010898792,-0.020129358,0.007824026,-0.028180143,-0.026461935,-0.034974203,0.0035842725,-0.01029623,0.03613128,0.029659213,0.016798677,0.008363975,-0.001907107,-4.5432014e-05,0.039539926,0.009724693,-0.009149901,-0.009790344,-0.009240943,-0.018521324,-0.0652379,0.0111937905,0.0067898817,0.0011899598,0.0082889395,-0.00035780232,-0.004424683,0.0013098454,-0.011045642,-0.014385112,-0.017189236,-0.026005834,0.009629292,-0.014927182,-0.004240868,0.0064237528,-0.013453977,0.024562763,-0.015621935,0.027151642,-0.014441881,-0.022143783,0.016924009,0.0040147086,-0.0136505505,-0.003066136,0.004931431,0.0005765359,0.004862483,-0.0049448595,0.020237373,-0.010300683,-0.005102325,0.0018629975,0.006303468,0.012582161,-0.004716667,-0.014830875,-0.021786392,0.00329369,-0.012497639,-0.016203158,0.016412582,8.7437395e-05,0.013307088,0.009452003,0.010623404,0.01666288,0.02378479,0.021835113,-0.021218495,-0.010873127,-0.013611596,-0.0072703054,0.005806965,0.015917642,-0.001830582,-0.010150007,0.0007181735,-0.00025640416,-0.0025817533,0.006565912,-0.12567441,-0.017105764,-0.0123354625,-0.011047076,-0.0031981368,-0.031598464,0.014523718,-0.014317597,-0.025665062,0.003089724,-0.0072299237,-0.011635955,-0.0058139614,-0.0006921691,0.00532193,-0.014663486,-0.015998378,-0.010176204,-0.01234331,-0.008500716,0.012684186,0.008386828,0.01414312,-0.0074401074,0.0085056415,0.0034841793,-0.0030329938,0.0015781281,0.0072701033,-0.011114745,0.00889813,-0.008566033,-0.0060419273,0.0287431,0.026129581,-0.017947182,0.017796967,0.0011060761,0.0061078295,0.032396607,0.011418641,0.01758916,-0.013398157,-0.012428734,0.0076496154,0.006017061,0.03041043,-0.018868633,-0.01827899,-0.002923845,-0.03868469,-0.0027125345,0.002766038,-0.0116516845,-0.025751047,-0.004794162,0.002902078,-0.007798626,-0.004893133,-0.00095877587,0.017021326,-0.01840982,-0.005844428,0.012727269,0.010435312,0.009597328,0.010977765,-0.0045888796,-0.01268151,0.008593239,-0.02624303,-0.001703474,-0.0322152,0.029430987,0.007865877,0.035725124,0.03705546,0.011788075,0.006056453,0.00924978,-0.008034395,0.0038182363,-0.09519426,0.019601727,0.02710381,-0.006714348,0.016940583,0.009588035,0.007195763,-0.026591565,-0.006485965,-0.005988431,0.016406743,-0.008726423,-0.0016747079,-0.0100917015,-0.031809468,-0.025880191,-0.0016934747,-0.014541906,-0.010223846,-0.005035142,0.012156367,-0.025477605,-0.0027213532,-0.01517253,-0.012469454,-0.01772494,0.03272645,0.028593376,0.016349139,-0.00859544,-0.030423844,-0.11981689,0.014447837,-0.0013163077,-0.030548004,0.0033454278,0.01878873,-0.008554991,-0.010389237,-0.00813195,-0.019982826,-0.007597553,-0.023572173,0.0025526264,0.018453492,-0.009003406,0.09890836,0.00080255215,0.019987362,-0.0166947,-0.019311754,-0.0013811847,-0.00515063,-0.0012106575,-0.013670325,0.0083752135,-0.0057416735,-0.030363342,0.0015560203,0.015465239,0.03522195,-0.025726853,-0.006982805,-0.0064364243,-0.0061361785,0.013267998,0.008828226,0.010963058,-0.001442767,0.01622301,0.021282723,0.0043368475,0.015799861,0.014663668,-0.0086306315,0.002893643,-0.022723887,-0.0019764034,0.021016575,-0.0063645295,0.019432828,-0.03536649,-0.05998667,-0.0003440821,0.025531633,0.0032824366,0.012916434,0.0033366068,0.0311384,0.0016029731,-0.00855121,0.0039854143,-0.02452844,0.009089127,0.0036009296,0.009670187,-0.02462203,0.022180788,0.004716437,-0.0018476113,0.0020228678,-0.011943281,-0.0037842144,-0.017444488,-0.026401253,-0.0034636443,0.017823722,0.0013268944,-0.0031010958,-0.01692959,-0.020493776,0.018985922,0.012069465,0.0047846707,-0.014335476,0.015612468,0.008561054,0.027576128,-0.0037820488,-0.011789468,0.009985262,-0.015566113,0.0023613875,-0.0051451367,-0.009388764,0.0067444365,0.013259777,-0.0067143296,0.013809815,0.009419261,0.024174515,-0.018536128,-0.01984565,-0.004432899,-0.041575436,0.019188177,0.005481332,0.0064029647,-0.010503386,0.021194031,0.0043397537]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (9, 'nguyen_vong', 'Quy định về nguyện vọng tuyển sinh', 'Thí sinh được đăng ký tối đa 3 nguyện vọng vào các trường THPT công lập. Các nguyện vọng được sắp xếp theo thứ tự ưu tiên: NV1 (nguyện vọng 1) được xét trước, sau đó đến NV2 và NV3. Mỗi nguyện vọng tương ứng với một trường THPT khác nhau. Số lượng nguyện vọng thực tế của mỗi thí sinh được ghi trên phiếu (từ 1 đến 3). Ngoài nguyện vọng thường, thí sinh thi chuyên có thêm nguyện vọng chuyên riêng.', 'Phần danh sách NV1, NV2, NV3 bên trái phiếu', '[-0.0040411605,-0.03313724,0.008758429,-0.03943832,0.0029157468,-0.0030245632,0.00779996,-0.0042777937,0.012918975,-0.006104688,-0.007549578,0.037787955,0.0049001286,0.011360559,0.11674596,0.034043007,-0.0029620146,-0.011572177,-0.017750943,0.0101377545,-0.012814211,0.010043334,0.010435906,-0.028918166,-0.009021657,-0.006354185,0.033894297,0.027089437,0.010847868,-0.00084231485,-0.0019584943,0.028222408,0.0033201713,0.03265419,0.011785305,0.015831051,0.039720308,-0.02405346,0.026061552,-0.020424299,-0.009909441,0.014926305,0.017683927,-0.022897521,-0.011647974,-0.037906863,-0.0037718897,-0.02731408,-0.005540675,-0.0016779582,-0.019000294,-0.001991214,-0.024367431,-0.18084612,0.0147412075,-0.02148255,0.0030405177,-0.02568915,-0.01200502,0.010943836,0.0028537156,0.018573212,-0.013230822,-0.008395291,0.00070277107,-0.0069262856,0.011966641,0.03285769,0.011880768,0.007090911,0.006178953,-0.00789441,0.005411888,0.006388459,0.005085472,0.015455049,0.012357741,0.011412337,-0.012363714,-0.016180754,-0.008929554,-0.014372877,-0.0258489,0.014766752,-0.005137822,-0.03824878,-0.0041460125,0.009273282,-0.016978681,-0.010733226,-0.020081047,-0.0011911722,0.011020615,-0.0028354705,-0.01038932,-0.010915072,0.00068892364,0.03400227,-0.010916937,-0.020534866,-0.014828547,-0.0133571,-0.0153993005,-0.023159664,-0.0057057184,-0.010398812,0.01619223,0.018644806,-0.0024966816,0.0026432432,0.017114177,0.0016949493,0.030018663,0.0041608335,0.004211518,-0.13908915,-0.023996448,0.0012719417,-0.024333138,0.014261897,-0.040450692,-0.0119111985,0.004846363,0.016652267,-0.006436468,-0.0025932922,-0.029453969,-0.0053395955,-0.002525138,-0.023225933,-0.012026543,0.009613577,0.03624632,-0.007830296,0.0064434274,0.002688813,0.005118572,-0.023918089,-0.032436945,-0.018268216,0.005652131,-0.008870821,-0.018496016,-0.006652857,-0.0005186666,-0.006466319,-0.0273499,0.01011233,-0.0032349129,0.0032639997,-0.028501565,-0.01822541,-0.0186581,0.025675423,-0.0038469466,0.002739597,-0.0067986427,-0.01524074,-0.042631008,-0.004448566,-0.0018268593,-0.019599693,-0.0053759506,0.0040890262,0.015111015,0.034672886,0.0062879887,0.02500528,0.009203806,0.013812122,0.00810113,0.012073647,-0.008325689,-0.0011868627,-0.01441556,0.0053486056,0.011821784,0.00080651033,0.025744505,0.0046276646,0.015020858,-0.0053721126,-0.009376424,0.0075280196,-0.00078762765,-0.0014293308,0.021643061,-0.01383267,0.018616129,0.018825065,0.0020123108,0.021213185,-0.031955298,-0.025481204,0.0002814156,-0.019733269,0.019229228,0.0049772994,-0.0041773403,-0.009117865,0.007353937,0.029012956,0.010010538,0.017805694,-0.0075437203,-0.007995466,0.013003651,-0.011055301,-0.008231562,0.03396535,-0.017530477,-0.0032005284,-0.00036796628,-0.034783896,-0.008757552,-0.022102738,0.0335572,-0.005228691,-0.008925392,0.010513357,0.01610964,0.02454888,0.020828316,0.02057624,0.00884117,0.0105768265,-0.0071558645,0.003918616,0.0016695061,-0.011918669,-0.00087518775,0.026916707,0.0056785652,0.007807862,0.024946203,-0.007861272,0.019621342,0.01705627,0.018900257,-0.020618787,-0.025599439,0.016728887,0.008685351,0.01434294,-0.004037051,-0.01734041,-0.015508048,0.005508761,-0.007856507,0.0019827858,0.0038938934,-0.0042618294,0.0073250304,0.016187109,-0.009434051,-0.0010994562,0.0072159343,0.025841622,0.020599961,0.026857836,-0.029796435,-0.004615392,-0.019576464,-0.0047355676,0.011129384,0.01884316,0.024843948,-0.0015685615,-0.009311203,0.008107504,-0.012065641,0.010218657,0.015729956,-0.01777714,-0.009510637,-0.024383046,-0.08456441,0.010935072,0.0011909897,-0.020791821,0.019537963,-0.01841346,0.005264453,0.011632694,0.016034547,-0.002237057,-0.012632425,-0.008157093,-0.0078060776,-0.01545038,0.0020920206,-0.0006955372,-0.022215506,-0.021248892,-0.0052729533,-0.026839431,-0.019459352,0.028322345,-0.012797897,-0.008476219,0.028223714,0.017934738,0.023429703,0.037811834,0.00183889,-0.011301071,0.008607613,-0.015036672,-0.021147976,-0.014152873,-0.035343297,0.0026365332,0.036194872,0.009583647,-0.0034414856,-0.017593354,-0.006971091,0.0058780806,0.0070526516,0.0013086776,0.007247648,0.015418145,-0.0047318363,0.042835806,0.009952621,0.00011620019,-0.011917211,-0.020724429,0.0033990014,0.019897325,0.012815236,-0.0019383498,0.013739526,0.012869947,0.030411825,-0.00406742,-0.009052865,0.0051350617,0.0053425436,-0.005628788,0.009162164,0.042554542,-0.020504542,-0.026388021,-0.022894429,-0.002809697,-0.006115313,0.0029401572,-0.003799931,-0.049419098,-0.00532169,0.003999874,0.00724707,-0.0053446153,0.012187243,0.020035584,-0.00073072774,-0.00968181,-0.0058979387,0.047874317,-0.00086762593,-0.0011457157,0.031693723,0.010501391,0.028371979,-0.0077198274,-0.010733502,0.023242667,0.0041792993,0.021680702,0.0002331131,-0.013561047,0.004640845,0.0014650302,-0.028302219,-0.014017098,0.009030709,-0.008131101,0.0026949265,0.010040028,0.03508278,-0.008114638,-0.011767383,0.009899024,-0.006745243,0.034627624,0.015071785,-0.0071251374,0.024694439,0.005526607,0.0055932347,-0.012864823,0.018884402,0.024914943,-0.01701136,-0.013628376,0.020443305,0.011360293,-0.008092692,-0.014233335,-0.0041344594,0.01196724,0.006062901,-0.018623495,0.010187598,0.0060467464,0.0013147168,-0.041976653,-0.02146611,-0.009471939,-0.02866511,0.008642437,-0.0077884453,0.012607879,0.036264736,0.02743244,-0.0057301833,0.011878171,0.012627989,0.0029580768,-0.001838223,0.008172562,-0.02888494,0.014612755,0.01692163,0.006598295,-0.01267192,0.015518139,0.015959946,-0.013351717,-0.015552831,0.004070927,0.0028412265,0.0015479272,0.016119013,-0.0014387668,-0.022186102,-0.009186721,-0.005803693,-0.0391692,0.018653689,0.015160276,0.004782395,0.0008919749,0.013323208,-0.026877193,0.017390354,-0.0073959315,0.010679681,0.012915932,0.020624138,0.014589501,-0.007581776,-0.008499606,0.0020014737,0.0086230375,-0.03130398,-0.012702467,-0.033864547,-0.0009833258,0.012340598,0.0027232047,-0.007251136,0.019522421,-0.021287924,-0.028387437,-0.0062969206,-0.0062667215,-0.003535739,0.0064071054,0.003764831,0.007107159,-0.0005582349,-0.0013151858,-0.006050337,0.010888175,-0.00094910944,-0.017220031,0.0008995821,0.012118387,-0.005054953,-0.01598977,-0.04711307,-0.03375641,0.016822277,-0.004469671,0.007880253,-0.022112371,0.00302731,0.0021284434,0.009982206,0.00043540238,0.0045831543,-0.011611711,0.013383002,0.02692776,-0.016138142,0.01488938,0.0077872872,0.0037358988,0.035937224,-0.003467141,-0.0017672902,-0.0025899268,-0.04486831,-0.00027841525,-0.049219534,-0.020995345,0.0029035255,-0.028787566,-0.0011840443,0.0028824836,0.0046746554,0.0019047594,-0.020412212,0.0061575593,-0.018569876,0.002299977,-0.0004288489,0.031766742,-0.0122059705,-0.014423368,-0.009120034,-0.015018877,-0.024491312,-0.01779617,-0.02410498,-0.019600235,0.013246389,-0.017507214,-0.006922836,0.012482079,0.030573694,-0.011983247,-0.017159754,-0.017714784,-0.00046148428,-0.017337272,-0.004719536,0.004274498,0.005121559,-0.006012023,0.00019095046,-0.029753339,0.02764498,-0.12539,0.003971572,-0.01917635,-0.0037361148,-0.021786608,-0.03467156,-0.01679852,-0.0381779,-0.0072449283,0.024754183,-0.008735069,-0.00589349,0.005029005,0.017091943,-0.00810924,-0.022520525,0.0007359776,0.0066204867,0.02258834,-0.006471306,-0.00022168393,0.0072715376,0.035627082,-0.0013595729,0.010299528,-0.024275133,0.014421033,-0.011611867,-0.018152755,0.01791058,0.004086923,-0.01433146,0.022768825,0.053725038,0.0070711463,0.0059406725,0.017546453,-0.00850688,-0.002468184,0.015938303,0.010504408,-0.00985384,-0.022892235,0.0019868468,0.019922966,0.01569868,0.016294165,0.0053226277,-0.02236162,0.010823189,-0.041269757,-0.06309583,-0.020048618,-0.016311532,-0.004598439,-0.01017093,0.0050038937,-0.02390603,-0.016828507,-0.008009275,-0.008798954,-0.01335884,0.0017918946,0.014392677,-0.000706701,-0.0015718932,-0.012282615,-0.012399036,-0.004292212,-0.002285914,-0.013177319,0.0023117445,0.009923913,0.029578751,0.010535861,0.026681265,0.024229212,-0.009646871,0.010856954,0.0074612554,-0.009076089,0.0069849426,-0.07695836,0.00613835,0.023659213,-0.038931407,0.006010408,0.007762948,0.006794001,-0.015522423,0.0015955176,0.019454997,-0.00051795435,-0.0013753135,6.0667597e-05,-0.010094101,0.007819715,-0.016152492,0.010731132,-0.017255168,-0.007716823,0.006421219,0.018539866,0.0047754855,0.011074278,-0.024711156,-0.0100799715,-0.013434083,-0.0018620114,-0.00066027703,-0.010293509,-0.03893802,-0.01653129,-0.13041718,0.009862355,-0.005470341,0.0065825675,0.0022120336,-0.0014321631,-0.018439855,-0.011653214,-0.022291224,-0.0018250397,-0.018184159,0.0030691498,-0.027943095,0.0062654302,0.010818169,0.088783145,0.0041020857,0.0056445496,-0.015142583,-0.008850107,-0.014724578,-0.016580619,0.010153364,-0.011784136,0.027218593,0.016247857,-0.02551591,-0.008683778,0.04544185,-0.002220885,-0.011878993,0.0027004401,0.001217852,0.0012878282,0.0073384363,-0.013032398,0.027152129,0.0057942215,-0.0070425784,0.010583462,0.027104579,0.022167966,0.007529405,0.0013310869,-0.0006489415,-0.020606963,0.0022147428,0.01811108,0.0035048532,-0.0023510703,-0.0034515709,-0.08360403,0.031933438,-0.0060797627,-0.009808661,0.010121563,0.017911213,0.017643575,0.021188544,-0.020584747,0.008818802,-0.016566223,-0.0016748388,0.028961428,0.002439804,-0.031275332,0.02010416,0.025604554,0.008120861,0.01351434,-0.008051931,0.025875263,-0.00623313,-0.011216885,-0.020858243,2.8784678e-05,-0.021633122,-0.0071337577,0.013905008,-0.01125924,0.022999657,0.021082606,0.030957563,-0.03272474,0.028485164,0.0053218952,0.022957344,0.015274263,-0.014347889,-0.0013358819,-0.015912635,-0.0014479454,-0.014643988,-0.02649736,0.0225948,0.006744165,-0.004766866,0.00837021,0.024858577,-0.00222121,-0.00737468,-0.009355993,0.018619353,-0.03962053,0.009219141,0.007499177,0.0033018463,0.0054106633,0.015741797,0.0020304015]', '2026-11-04 08:15:13.169824');
INSERT INTO public.tai_lieu_vector VALUES (10, 'diem_uu_tien_khuyen_khich', 'Điểm ưu tiên và điểm khuyến khích', 'Phiếu báo thi ghi rõ 2 loại điểm cộng: Điểm ưu tiên (UT) và Điểm khuyến khích (KK). Đa số thí sinh lớp 9A5 có điểm ưu tiên = 0 và điểm khuyến khích = 0. Tuy nhiên, có trường hợp đặc biệt: thí sinh Nguyễn Như Quỳnh (trang 31) có điểm ưu tiên = 1. Điểm ưu tiên được cộng vào tổng điểm thi khi xét tuyển vào trường THPT.', 'Dòng ''Điểm UT'' và ''Điểm KK'' trên phiếu', '[0.024811419,-0.009863587,-0.00055652956,-0.040418796,-0.013947744,0.019536564,-0.0021236762,-0.021983005,0.026020348,0.024598246,-0.01503337,0.025035456,0.011429484,-0.009544847,0.117352396,0.030765837,-0.0226545,-0.018640224,0.006258715,-0.0036563948,-0.0039589233,-0.0046882383,-0.007596626,-0.021929564,-0.008074592,-0.01962693,0.015579299,0.01622797,0.010120189,0.002689011,-0.018540034,0.00045294868,0.027611136,0.029147347,0.013005054,0.020931982,0.012281958,-0.017384611,-0.003485736,-0.04266498,0.021542713,0.025906973,-0.00845917,0.01079771,-0.017111072,-0.025337521,0.0018610959,-0.0060184216,-0.007483666,0.0072074807,-0.0023851814,0.0113915745,-0.025504995,-0.18181825,0.018930154,-0.025052676,-0.016984697,-0.0018979239,-0.007935161,0.0037638547,-0.0030744458,0.03093412,0.0020534105,0.011123377,0.011143135,-0.0011167082,0.030547706,0.026355306,-0.003996233,-0.021210412,0.017083319,-0.009652591,-0.0030246184,-0.0027476584,0.030871345,-0.027442457,0.002989839,-0.009393602,-0.02342882,-0.03287684,0.013600595,-0.010457117,0.017191298,-0.0023181036,-0.017424172,-0.023994002,-0.017568728,-0.009907715,0.0023973589,0.0006196004,0.017523129,-0.008152306,-0.0056544156,-0.005347514,-0.013223166,0.012966672,0.011082706,0.020811006,-0.0104974,-0.008622503,-0.014803261,-0.003186188,-0.0064787515,0.0065733837,0.009488294,-0.027279437,0.034990545,0.0009000603,0.0078088744,-0.006468424,0.019386305,-0.002403987,0.004610573,0.01739584,0.017845238,-0.14373581,-0.019139735,0.021114627,-0.015410599,0.0075379885,-0.033438075,0.0008196514,-0.029563395,0.012591348,0.016759012,0.02155724,-0.024334947,-0.022015246,0.002522582,-0.009464943,0.0113096945,0.01569065,0.036629297,0.006662457,0.005339281,0.019401362,0.0033627835,-0.0048024314,-0.016843766,-0.004033876,-0.018971393,-0.0038787702,-0.040984888,-0.002987336,0.017670488,0.007917679,-0.01035936,0.0057122726,-0.0041385894,-0.011222128,-0.017737696,-0.019209344,-0.0012280905,-0.0014795687,0.0048649195,-0.014330238,0.013047105,-0.017023237,-0.002625484,0.015171811,0.0027259083,0.004475765,-0.0032845768,-0.02142679,0.00152628,0.028531779,0.0066171647,0.019025201,-0.003021533,0.0015777193,0.009457948,0.008035724,-0.009776245,-0.012574176,-0.029914277,-0.024289535,0.013345931,0.014776757,0.0042041754,0.018764848,0.0045379517,-0.018003594,-0.0018185183,-0.00070951215,-2.9853189e-05,-0.004828811,0.011062074,-0.007643623,0.020183755,0.003773994,0.004736602,0.011349588,-0.008656649,-0.02321103,-0.00016657414,0.0010576444,0.008220504,0.015555554,-0.00066478935,-0.002405912,0.0046641724,0.019009683,-0.024816358,-0.0063278773,0.010431817,-0.002983856,0.0006581726,-0.018083554,0.0018592933,0.0103995735,-0.007869421,0.00912919,0.024710337,-0.018901173,-0.012475944,-0.026219899,0.01918527,-0.025642205,-0.008410725,-0.009368208,-0.004975513,-0.012663182,0.017464647,0.027837435,-0.01962419,0.003953855,0.003771841,-0.0007796611,-0.021266155,-0.013595831,-0.0035696311,-0.0069477926,-0.0013056208,0.0051201438,0.004804906,-0.008165045,-0.011920804,0.022546986,0.008722272,-0.020675268,-0.023573605,0.03142944,0.00142656,-0.0038105284,0.024686636,-0.019870494,-0.011341698,0.024374278,-0.011350765,-0.004224483,0.031285577,0.013182575,0.008495737,-0.014237905,-0.0071670017,-0.00058381085,0.00015299514,0.00012564185,0.011457691,0.034165096,-0.013444199,0.02779729,-0.013668198,-0.028641012,0.012178183,0.01280387,-0.0078091505,-0.0057894285,-0.02191154,0.017434359,-0.01256448,0.020333357,0.0073202583,-0.02490222,0.012401519,-0.02061441,-0.09912138,0.010556356,0.012278447,-0.020199375,-0.005848747,-0.008952218,0.017967086,0.008142651,-0.00031716077,-0.003528531,-0.018267093,-0.032894474,-0.008978328,0.00810743,-0.008501603,0.0015882616,-0.020303512,-0.0020313787,-0.000903104,-0.016818456,-0.008264555,0.0021947783,0.007274212,0.0010526993,-0.0014321139,0.03487981,0.024804357,0.046781763,0.029672254,-0.005574187,-0.014133642,-0.011795636,0.0073708296,-0.032352775,-0.029703265,-0.005643378,0.00776687,0.01254344,-0.012197668,-0.017366515,-0.00655346,0.010107065,0.005451491,-0.028565237,-0.016628362,0.013610739,-0.0249114,0.030216549,0.0011571501,-0.0055714706,-0.017992668,0.0035884657,0.003039936,0.051510952,0.008444346,-0.022026831,0.009498503,0.0063030007,0.0063590594,0.0030256454,-0.004260856,0.006621962,-0.02711188,-0.03127002,0.003918578,-0.0041118115,-0.019679146,-0.019269397,-0.03788731,-0.019063585,-0.0077632996,-0.006973275,-0.0149408635,-0.028631687,-0.018827513,-0.010547001,0.0051053474,-0.013741997,0.028012557,0.022471204,0.00457423,-0.008400349,0.022307076,0.008607402,0.014654328,0.0055737486,0.025827298,-0.015026595,0.022162126,-0.032954633,-0.003278539,0.011388642,0.009453127,0.011298686,-0.004698528,-0.016886646,0.0058711255,-0.012102513,-0.015473384,-0.0059139524,0.0012415474,-0.009441364,0.0028399841,0.0063667106,-0.020024365,-1.8177176e-05,0.003561011,-0.0047932686,0.0060279365,0.012204024,-0.001094484,-0.017168133,0.026496064,0.012176688,-0.0061715636,-0.0023069275,0.016947057,0.0012167539,-0.0011992705,-9.70334e-05,-0.018830433,-0.010576124,0.012492199,-0.02003996,-0.009833877,0.012449345,0.018834703,-0.034591608,-0.0036235994,0.017286817,0.017401202,-0.039092198,-0.027052248,-0.001209698,-0.028888049,0.0033824507,-0.00423818,-0.0051028086,0.0227234,0.005693187,0.009337299,-0.0049701896,0.023124563,-0.00070939615,0.01568454,-0.0019311893,-0.005881072,0.008668336,0.026221339,0.0199687,-0.011588799,-0.007195182,0.009131751,-0.022335043,-0.0029983073,-0.0067720413,-0.018561222,-0.009409144,0.015056232,0.03034709,-0.010749394,-0.01673922,0.0104943765,-0.0076085418,0.017899698,0.004844892,-0.0012606989,0.0031982523,0.009671617,-0.0071313037,-0.011710892,-0.0232414,-0.015758254,-0.013736733,0.027823461,0.0053722337,-0.004718045,0.007126743,-0.0148308175,0.034588072,0.015513967,-0.010049353,-0.045899525,-0.011849556,0.030077176,-0.039728016,-0.01291513,-0.00053749635,-0.022659283,-0.020399263,-0.0021940523,-0.04084285,-0.018925603,0.012854442,-0.008426333,0.009212268,0.003658944,0.033985306,-0.008311756,-0.012945642,0.0022967523,0.02621658,-0.010180979,-0.009087455,0.0077094976,-0.0045080897,-0.029383074,-0.03490102,0.03802624,-4.410108e-05,-0.0048065362,0.0104869045,0.006001489,0.010276733,-0.0022590898,0.0122503,0.017388312,-0.0052256235,-0.010484554,0.014994031,0.0050411182,-0.027087415,0.015667146,-0.0026678347,0.02171638,-0.00050600985,0.0004377761,-0.011444272,-0.018951047,0.019435558,-0.016107198,-0.015425321,-0.014046583,-0.019165464,-0.01716638,-0.008511726,0.0027996302,0.04474433,-0.051587377,-0.008360882,0.0030442,0.0056869374,0.0042563556,-0.008167875,-0.044342835,-0.025663832,0.0011729072,-0.020826558,-0.02710784,0.006343967,0.029308341,0.0029589126,0.009930953,-0.010527809,-0.017981043,0.04343972,0.009764501,-0.05175852,0.0016608626,-0.01620243,0.007022933,0.013104153,0.015885184,0.009195318,-0.0046970625,0.010484859,0.004258288,-0.024287306,-0.01808213,-0.11675928,-0.0099133225,-0.009037847,-0.038290206,-0.014910001,-0.03535418,-0.011941072,-0.019835472,-0.009203945,-0.00020747387,0.016004652,0.002465931,-0.008656801,-0.008953955,-0.007081174,-0.0359091,-0.007013297,0.008053909,-0.026161201,0.023655415,0.004324507,0.029658183,0.020139225,-0.012400915,-0.007657279,-0.0017322521,-0.008194576,-0.027344264,0.0022251396,-0.0032410251,-0.018037863,-0.0068411874,0.023077613,0.037861295,0.0113331005,0.0031707769,0.018198755,-0.0049823765,0.004052865,0.0047649154,0.009717783,-0.0159524,-0.016943378,-0.014645233,0.023934325,0.014720112,0.036361873,0.0009897848,-0.0068199267,-0.0030228803,-0.022970017,-0.037538424,-0.014975098,0.014397096,-0.032979224,0.00073138496,0.013839436,-0.017624343,0.0013622496,-0.016757814,-0.0070144567,-0.029444732,-0.0033112841,0.029450374,0.008121916,-0.014018773,0.0066771377,0.018144513,0.009196371,0.0041367495,-0.018766,0.014431018,-0.016309801,0.011928406,0.009738825,0.02443054,0.020046929,0.007600802,-0.0017076309,0.0043990095,0.006136973,-0.0046916464,-0.08522227,0.024947863,-0.0002794536,-0.023246767,0.008515384,0.012484648,0.0035561551,0.009286594,0.0068158987,-0.020455405,-0.021889709,0.0007447199,0.011943065,-0.020738736,-0.008404478,-0.02408031,0.0041048564,-0.00086136546,-0.020427343,0.0037858465,-0.003990637,-0.024054391,-0.0042858985,-0.02167534,-0.028584125,-0.003535696,0.036143504,0.006736856,0.020770201,-0.011632065,-0.01724119,-0.13805121,0.013982677,-0.011828951,0.00053291797,-0.015785793,0.043553863,-0.0031962981,-0.00012768734,-0.012259454,-0.012076414,-0.016755251,0.0024501656,-0.025087161,0.0005430409,-0.0076706656,0.08499412,-0.003644553,0.0044240034,0.0012201655,-0.0004710064,0.006631684,-0.020328026,0.0072303894,-0.016857779,0.020212343,-0.008781191,-0.026994241,0.0020584972,0.027029522,0.010080464,0.008380745,-0.009919218,0.0055830544,0.0019751592,0.00012566314,0.0067712558,0.0037729735,0.009044801,0.035721935,0.009148521,0.008871353,0.023312824,0.020992424,-0.0007593867,0.0007938679,-0.008476496,-0.0006728386,0.018218892,0.020873157,0.016119933,-0.005604371,-0.04323239,0.013662773,0.01898571,-0.0022500148,0.013739143,-0.0029412617,0.004755507,-0.0025124871,-0.013044358,0.019322718,-0.02186142,0.02735912,-0.0004552124,0.015619934,-0.00095783157,0.028955754,0.0031811248,-0.0031901726,-0.005755819,-0.050786175,-0.009768622,-0.008800678,-0.017544793,-0.0034980115,-0.015754854,-0.018053984,-0.0174736,0.0070698117,-0.017691143,0.0167711,-0.009643348,0.0014682867,0.005208495,0.035176136,0.0026747945,0.016830124,-0.024905754,0.0124700675,0.014271762,-0.0043189917,-0.0017787439,-0.015282898,-0.033592634,-0.002410807,0.017766641,-0.0034097938,0.02000773,0.0039671287,-0.0072709634,-0.00934249,-0.005768525,-0.0142337885,-0.03840501,-0.005607458,-0.00095352693,-0.014310521,0.005446573,0.022225646,-0.011719757]', '2026-11-04 08:15:13.169824');


--
-- Data for Name: thi_sinh; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.thi_sinh VALUES (1, 'ĐẶNG LINH AN', '26/12/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118117832', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'THPT Nguyễn Quốc Trinh: Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204001', '1', '9h00 ngày 29/5/2026', 1, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (2, 'LÊ MAI KHÁNH AN', '29/01/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118497742', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đỗ Mười', 'THPT Đỗ Mười: Số 286 Phố Trần Thủ Độ, phường Yên Sở, Hà Nội.', '111004', '1', '9h00 ngày 29/5/2026', 2, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (3, 'ĐỖ HOÀNG BẢO ANH', '29/06/2011', 'Nữ', 'Kinh', 'Hà Nội', '0130486316', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Việt Nam-Ba Lan', 'Số 1 ngõ 48 đường Ngọc Hồi, phường Hoàng Liệt, Hà Nội.', '110032', '2', '9h00 ngày 29/5/2026', 3, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (4, 'TRỊNH ĐỨC ANH', '22/09/2011', 'Nam', 'Kinh', 'Hà Nội', '0118468555', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'THPT Ngọc Hồi: Đường Lưu Phái, xã Thanh Trì, Hà Nội.', '199090', '4', '9h00 ngày 29/5/2026', 4, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (5, 'NGUYỄN GIA BẢO', '02/07/2011', 'Nam', 'Kinh', 'Hà Nội', '0118202281', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204109', '5', '9h00 ngày 29/5/2026', 5, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (6, 'PHẠM HƯƠNG BÌNH', '21/09/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118118610', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đông Mỹ', 'THPT Đông Mỹ: Thôn 1 Đông Mỹ, xã Nam Phù, Hà Nội.', '203130', '6', '9h00 ngày 29/5/2026', 6, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (7, 'PHẠM NGUYỄN HÒA BÌNH', '09/02/2011', 'Nam', 'Kinh', 'Nam Định', '3618118285', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đông Mỹ', 'THPT Đông Mỹ: Thôn 1 Đông Mỹ, xã Nam Phù, Hà Nội.', '203131', '6', '9h00 ngày 29/5/2026', 7, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (8, 'NGÔ HÀ CHI', '27/03/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118118230', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Việt Nam-Ba Lan', 'Số 1 ngõ 48 đường Ngọc Hồi, phường Hoàng Liệt, Hà Nội.', '110152', '7', '9h00 ngày 29/5/2026', 8, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (9, 'TRẦN QUỲNH CHI', '01/01/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118087338', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đông Mỹ', 'THPT Đông Mỹ: Thôn 1 Đông Mỹ, xã Nam Phù, Hà Nội.', '203158', '7', '9h00 ngày 29/5/2026', 9, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (10, 'NGUYỄN THỊ NGỌC DIỆP', '05/09/2011', 'Nữ', 'Kinh', 'Hà Nội', '0117730767', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'Đường Lưu Phái, xã Thanh Trì, Hà Nội.', '199179', '8', '9h00 ngày 29/5/2026', 10, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (11, 'LÊ XUÂN ĐỨC', '13/11/2011', 'Nam', 'Kinh', 'Hà Nội', '0118118166', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'Đường Lưu Phái, xã Thanh Trì, Hà Nội.', '199241', '11', '9h00 ngày 29/5/2026', 11, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (12, 'VŨ MINH ĐỨC', '30/01/2011', 'Nam', 'Kinh', 'Hà Nội', '0117718476', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'THPT Ngọc Hồi: Đường Lưu Phái, xã Thanh Trì, Hà Nội.', '199255', '11', '9h00 ngày 29/5/2026', 12, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (13, 'TRẦN HƯƠNG GIANG', '16/09/2011', 'Nữ', 'Kinh', 'Nam Định', '0169077497', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Việt Nam-Ba Lan', 'THPT Việt Nam-Ba Lan: Số 1 ngõ 48 đường Ngọc Hồi, phường Hoàng Liệt, Hà Nội.', '110288', '12', '9h00 ngày 29/5/2026', 13, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (14, 'VŨ MINH HÀ', '09/03/2011', 'Nữ', 'Kinh', 'Lào Cai', '1003544765', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Trãi-Thường Tín', 'THPT Nguyễn Trãi-Thường Tín: Thôn Thượng Đình, xã Thường Tín, Hà Nội.', '212239', '10', '9h00 ngày 29/5/2026', 14, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (15, 'NGUYỄN THANH HẰNG', '25/12/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118439403', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'THPT Ngọc Hồi: Đường Lưu Phái, xã Thanh Trì, Hà Nội.', '199295', '13', '9h00 ngày 29/5/2026', 15, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (16, 'NGUYỄN TIẾN HUY', '26/12/2011', 'Nam', 'Kinh', 'Hà Nội', '0118201678', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204294', '13', '9h00 ngày 29/5/2026', 16, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (17, 'NGUYỄN LÂM CHẤN HƯNG', '16/02/2011', 'Nam', 'Kinh', 'Hà Nội', '0118114913', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đông Mỹ', 'THPT Đông Mỹ: Thôn 1 Đông Mỹ, xã Nam Phù, Hà Nội.', '203338', '15', '9h00 ngày 29/5/2026', 17, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (18, 'LƯU THIÊN HƯƠNG', '18/02/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118118205', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đỗ Mười', 'THPT Đỗ Mười: Số 286 Phố Trần Thủ Độ, phường Yên Sở, Hà Nội.', '111425', '18', '9h00 ngày 29/5/2026', 18, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (19, 'MAI VIẾT KHOA', '04/11/2011', 'Nam', 'Kinh', 'Hà Nội', '3641148900', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'THPT Ngọc Hồi: Đường Lưu Phái, xã Thanh Trì, Hà Nội.', '199407', '17', '9h00 ngày 29/5/2026', 19, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (20, 'PHẠM MINH LÂM', '12/12/2011', 'Nam', 'Kinh', 'Hà Nội', '0169077507', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Thạch Bàn', 'Phố Vũ Đình Tụng, phường Long Biên, Hà Nội.', '118543', '23', '9h00 ngày 29/5/2026', 20, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (21, 'ĐỖ GIA LINH', '18/06/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118088947', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'Đường Lưu Phái, xã Thanh Trì, Hà Nội.', '199450', '19', '9h00 ngày 29/5/2026', 21, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (22, 'PHẠM PHƯƠNG MAI', '17/08/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118468370', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đỗ Mười', 'Số 286 Phố Trần Thủ Độ, phường Yên Sở, Hà Nội.', '111551', '23', '9h00 ngày 29/5/2026', 22, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (23, 'BÙI TIẾN MẠNH', '20/05/2011', 'Nam', 'Kinh', 'Hà Nội', '0118118131', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đông Mỹ', 'Thôn 1 Đông Mỹ, xã Nam Phù, Hà Nội.', '203461', '20', '9h00 ngày 29/5/2026', 23, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (24, 'LÊ HOÀNG NHẬT MINH', '24/05/2011', 'Nam', 'Kinh', 'Thừa Thiên Huế', '0118061374', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Trãi-Thường Tín', 'Thôn Thượng Đình, xã Thường Tín, Hà Nội.', '212444', '19', '9h00 ngày 29/5/2026', 24, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (25, 'NGUYỄN ĐỨC MINH', '08/05/2011', 'Nam', 'Kinh', 'Hà Nội', '0118117950', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204438', '19', '9h00 ngày 29/5/2026', 25, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (26, 'NGUYỄN THU BẢO MINH', '16/08/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118223469', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Ngọc Hồi', 'Đường Lưu Phái, xã Thanh Trì, Hà Nội', '199534', '23', '9h00 ngày 29/5/2026', 26, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (27, 'NGUYỄN KIM NGÂN', '02/07/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118202285', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204474', '20', '9h00 ngày 29/5/2026', 27, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (28, 'HOÀNG GIA NGUYÊN', '17/08/2011', 'Nam', 'Kinh', 'Hà Nội', '0118118270', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THCS Nguyễn Trãi A, xã Thường Tín', 'Số 195 Thôn Trần Phú, xã Thường Tín, Hà Nội.', '217073', '4', '9h00 ngày 29/5/2026', 28, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (29, 'VŨ HẢI PHƯƠNG', '10/10/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118468723', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204595', '25', '9h00 ngày 29/5/2026', 29, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (30, 'PHẠM HỒNG QUANG', '07/10/2011', 'Nam', 'Kinh', 'Hà Nội', '0118117947', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204604', '26', '9h00 ngày 29/5/2026', 30, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (31, 'NGUYỄN NHƯ QUỲNH', '12/09/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118118190', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 1, 0, 'THCS Ngũ Hiệp, xã Nam Phù', 'THCS Ngũ Hiệp, xã Nam Phù: Thôn Việt Yên, xã Nam Phù, Hà Nội.', '200116', '5', '9h00 ngày 29/5/2026', 31, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (32, 'ĐỖ NGỌC TÂN', '13/02/2011', 'Nam', 'Kinh', 'Hải Dương', '0118223822', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đông Mỹ', 'Thôn 1 Đông Mỹ, xã Nam Phù, Hà Nội.', '203653', '28', '9h00 ngày 29/5/2026', 32, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (33, 'NGUYỄN HỒNG THÁI', '09/03/2011', 'Nam', 'Kinh', 'Hà Nội', '0118117824', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THCS Ngũ Hiệp, xã Nam Phù', 'THCS Ngũ Hiệp, xã Nam Phù: Thôn Việt Yên, xã Nam Phủ, Hà Nội.', '200143', '6', '9h00 ngày 29/5/2026', 33, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (34, 'ĐỖ VĂN CÔNG THÀNH', '19/02/2011', 'Nam', 'Kinh', 'Hà Nội', '0118468587', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Đỗ Mười', 'Số 286 Phố Trần Thủ Độ, phường Yên Sở, Hà Nội.', '111761', '32', '9h00 ngày 29/5/2026', 34, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (35, 'LƯU ANH THẢO', '24/08/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118201836', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Việt Nam-Ba Lan', 'THPT Việt Nam-Ba Lan: Số 1 ngõ 48 đường Ngọc Hồi, phường Hoàng Liệt, Hà Nội.', '110853', '36', '9h00 ngày 29/5/2026', 35, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (36, 'HỨA MINH THỦY', '13/03/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118118216', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Việt Nam-Ba Lan', 'Số 1 ngõ 48 đường Ngọc Hồi, phường Hoàng Liệt, Hà Nội.', '110867', '37', '9h00 ngày 29/5/2026', 36, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (37, 'NGUYỄN HUYỀN TRANG', '27/05/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118118201', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THCS Ngũ Hiệp, xã Nam Phù', 'Thôn Việt Yên, xã Nam Phù, Hà Nội.', '200201', '9', '9h00 ngày 29/5/2026', 37, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (38, 'NGUYỄN LINH TRANG', '05/06/2011', 'Nữ', 'Kinh', 'Hà Nội', '2248216028', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THCS Tân Mai, phường Tương Mai', 'THCS Tân Mai, phường Tương Mai: Số 147 phố Tân Mai, phường Tương Mai, Hà Nội.', '109405', '17', '9h00 ngày 29/5/2026', 38, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (39, 'NGUYỄN MINH TRIẾT', '11/12/2011', 'Nam', 'Kinh', 'Hà Nội', '0118223693', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Việt Nam-Ba Lan', 'THPT Việt Nam-Ba Lan: Số 1 ngõ 48 đường Ngọc Hồi, phường Hoàng Liệt, Hà Nội.', '110911', '38', '9h00 ngày 29/5/2026', 39, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (40, 'NGUYỄN TRẦN HUY TUÁN', '21/03/2011', 'Nam', 'Kinh', 'Hà Nội', '0118116750', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THCS Ngũ Hiệp, xã Nam Phù', 'Thôn Việt Yên, xã Nam Phù, Hà Nội', '200234', '10', '9h00 ngày 29/5/2026', 40, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (41, 'NGUYỄN BẢO UYÊN', '10/08/2011', 'Nữ', 'Kinh', 'Hà Nội', '0118114930', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THPT Nguyễn Quốc Trinh', 'Thôn Đại Áng, xã Ngọc Hồi, Hà Nội.', '204749', '32', '9h00 ngày 29/5/2026', 41, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (42, 'PHÙNG MINH VŨ', '06/07/2011', 'Nam', 'Kinh', 'Hà Nội', '0118468421', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THCS Phùng Hưng, phường Sơn Tây', 'Đường Quang Trung, phường Sơn Tây, Hà Nội.', '171496', '21', '9h00 ngày 29/5/2026', 42, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');
INSERT INTO public.thi_sinh VALUES (43, 'VŨ QUANG VỸ', '30/09/2011', 'Nam', 'Kinh', 'Hà Nội', '0118118002', '9A5', 'THCS Chu Văn An', true, 3, 'Anh', 'Anh', 0, 0, 'THCS Ngũ Hiệp, xã Nam Phù', 'Thôn Việt Yên, xã Nam Phù, Hà Nội.', '200293', '13', '9h00 ngày 29/5/2026', 43, 'verified', '9A5.pdf', '2026-11-02 04:19:03.43205');


--
-- Data for Name: tuyen_sinh_chuyen; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tuyen_sinh_chuyen VALUES (1, 42, 'Tin', 'Sáng 01/6', 'THPT chuyên Sơn Tây', '9');


--
-- Name: lich_thi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lich_thi_id_seq', 129, true);


--
-- Name: nguyen_vong_chuyen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.nguyen_vong_chuyen_id_seq', 2, true);


--
-- Name: nguyen_vong_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.nguyen_vong_id_seq', 129, true);


--
-- Name: tai_lieu_vector_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tai_lieu_vector_id_seq', 10, true);


--
-- Name: thi_sinh_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.thi_sinh_id_seq', 43, true);


--
-- Name: tuyen_sinh_chuyen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tuyen_sinh_chuyen_id_seq', 1, true);


--
-- Name: lich_thi lich_thi_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lich_thi
    ADD CONSTRAINT lich_thi_pkey PRIMARY KEY (id);


--
-- Name: nguyen_vong_chuyen nguyen_vong_chuyen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong_chuyen
    ADD CONSTRAINT nguyen_vong_chuyen_pkey PRIMARY KEY (id);


--
-- Name: nguyen_vong nguyen_vong_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong
    ADD CONSTRAINT nguyen_vong_pkey PRIMARY KEY (id);


--
-- Name: tai_lieu_vector tai_lieu_vector_ma_doan_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tai_lieu_vector
    ADD CONSTRAINT tai_lieu_vector_ma_doan_key UNIQUE (ma_doan);


--
-- Name: tai_lieu_vector tai_lieu_vector_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tai_lieu_vector
    ADD CONSTRAINT tai_lieu_vector_pkey PRIMARY KEY (id);


--
-- Name: thi_sinh thi_sinh_ma_hoc_sinh_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thi_sinh
    ADD CONSTRAINT thi_sinh_ma_hoc_sinh_key UNIQUE (ma_hoc_sinh);


--
-- Name: thi_sinh thi_sinh_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thi_sinh
    ADD CONSTRAINT thi_sinh_pkey PRIMARY KEY (id);


--
-- Name: thi_sinh thi_sinh_so_bao_danh_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.thi_sinh
    ADD CONSTRAINT thi_sinh_so_bao_danh_key UNIQUE (so_bao_danh);


--
-- Name: tuyen_sinh_chuyen tuyen_sinh_chuyen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tuyen_sinh_chuyen
    ADD CONSTRAINT tuyen_sinh_chuyen_pkey PRIMARY KEY (id);


--
-- Name: tuyen_sinh_chuyen tuyen_sinh_chuyen_thi_sinh_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tuyen_sinh_chuyen
    ADD CONSTRAINT tuyen_sinh_chuyen_thi_sinh_id_key UNIQUE (thi_sinh_id);


--
-- Name: lich_thi uq_lich_thi_mon; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lich_thi
    ADD CONSTRAINT uq_lich_thi_mon UNIQUE (thi_sinh_id, ten_mon);


--
-- Name: nguyen_vong uq_nguyen_vong_thu_tu; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong
    ADD CONSTRAINT uq_nguyen_vong_thu_tu UNIQUE (thi_sinh_id, thu_tu);


--
-- Name: nguyen_vong_chuyen uq_nv_chuyen_thu_tu; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong_chuyen
    ADD CONSTRAINT uq_nv_chuyen_thu_tu UNIQUE (tuyen_sinh_chuyen_id, thu_tu);


--
-- Name: idx_thi_sinh_diem_thi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thi_sinh_diem_thi ON public.thi_sinh USING btree (diem_thi);


--
-- Name: idx_thi_sinh_ho_ten_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thi_sinh_ho_ten_trgm ON public.thi_sinh USING gin (ho_ten public.gin_trgm_ops);


--
-- Name: idx_thi_sinh_ma_hs; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thi_sinh_ma_hs ON public.thi_sinh USING btree (ma_hoc_sinh);


--
-- Name: idx_thi_sinh_sbd; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thi_sinh_sbd ON public.thi_sinh USING btree (so_bao_danh);


--
-- Name: idx_vector_hnsw; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vector_hnsw ON public.tai_lieu_vector USING hnsw (vector_noi_dung public.vector_cosine_ops);


--
-- Name: lich_thi lich_thi_thi_sinh_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lich_thi
    ADD CONSTRAINT lich_thi_thi_sinh_id_fkey FOREIGN KEY (thi_sinh_id) REFERENCES public.thi_sinh(id) ON DELETE CASCADE;


--
-- Name: nguyen_vong_chuyen nguyen_vong_chuyen_tuyen_sinh_chuyen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong_chuyen
    ADD CONSTRAINT nguyen_vong_chuyen_tuyen_sinh_chuyen_id_fkey FOREIGN KEY (tuyen_sinh_chuyen_id) REFERENCES public.tuyen_sinh_chuyen(id) ON DELETE CASCADE;


--
-- Name: nguyen_vong nguyen_vong_thi_sinh_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nguyen_vong
    ADD CONSTRAINT nguyen_vong_thi_sinh_id_fkey FOREIGN KEY (thi_sinh_id) REFERENCES public.thi_sinh(id) ON DELETE CASCADE;


--
-- Name: tuyen_sinh_chuyen tuyen_sinh_chuyen_thi_sinh_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tuyen_sinh_chuyen
    ADD CONSTRAINT tuyen_sinh_chuyen_thi_sinh_id_fkey FOREIGN KEY (thi_sinh_id) REFERENCES public.thi_sinh(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict BDCSHsu3Cp74xeOUhGfwFRyKtBQSc7Z9SSQhH02VmIwDBHa3jSvNksdUJx9Mn4b

