-- 1. Tạo bảng categories (Danh mục sản phẩm)
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 2. Tạo bảng products (Sản phẩm)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(255),
    sale_price NUMERIC NOT NULL DEFAULT 0,
    compare_price NUMERIC DEFAULT 0,
    buying_price NUMERIC DEFAULT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    short_description VARCHAR(165) NOT NULL,
    product_description TEXT NOT NULL,
    product_type VARCHAR(64) DEFAULT 'simple',
    published BOOLEAN DEFAULT FALSE,
    disable_out_of_stock BOOLEAN DEFAULT TRUE,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    
    -- Các trường bổ sung khớp với mô hình Product trong Flutter Frontend
    brand VARCHAR(255),
    image_urls TEXT,         -- Lưu chuỗi JSON của mảng URL hình ảnh (ví dụ: '["img1.png", "img2.png"]')
    colors TEXT,             -- Lưu chuỗi màu sắc (ví dụ: '["black", "red", "blue"]')
    sizes TEXT,              -- Lưu chuỗi kích thước (ví dụ: '["S", "M", "L", "XL"]')
    rating NUMERIC DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    is_new BOOLEAN DEFAULT FALSE,
    discount_percent INTEGER,
    
    CONSTRAINT chk_compare_price CHECK (compare_price > sale_price OR compare_price = 0),
    CONSTRAINT chk_product_type CHECK (product_type IN ('simple', 'variable'))
);

-- 3. Bảng trung gian product_categories (Mối quan hệ Nhiều-Nhiều giữa Sản phẩm và Danh mục)
CREATE TABLE IF NOT EXISTS public.product_categories (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE CASCADE NOT NULL
);

-- 4. Tạo bảng tags (Nhãn sản phẩm)
CREATE TABLE IF NOT EXISTS public.tags (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    tag_name VARCHAR(255) NOT NULL,
    icon TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 5. Bảng trung gian product_tags (Mối quan hệ Nhiều-Nhiều giữa Sản phẩm và Thẻ tag - được ánh xạ bằng ProductTag.java)
CREATE TABLE IF NOT EXISTS public.product_tags (
    tag_id UUID REFERENCES public.tags(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (tag_id, product_id)
);
