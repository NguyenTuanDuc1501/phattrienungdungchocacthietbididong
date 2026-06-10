-- Cấu trúc cơ sở dữ liệu E-Commerce mở rộng đầy đủ cho auth_db

-- 1. Bảng Quốc gia (Countries)
CREATE TABLE IF NOT EXISTS public.countries (
    id SERIAL PRIMARY KEY,
    iso CHAR(2) NOT NULL,
    name VARCHAR(80) NOT NULL,
    upper_name VARCHAR(80) NOT NULL,
    iso3 CHAR(3) DEFAULT NULL,
    num_code SMALLINT DEFAULT NULL,
    phone_code INT NOT NULL
);

-- 2. Khu vực vận chuyển (Shipping Zones)
CREATE TABLE IF NOT EXISTS public.shipping_zones (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT FALSE,
    free_shipping BOOLEAN DEFAULT FALSE,
    rate_type VARCHAR(64) CHECK (rate_type IN ('price')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 3. Bảng trung gian Khu vực vận chuyển - Quốc gia (Shipping Country Zones)
CREATE TABLE IF NOT EXISTS public.shipping_country_zones (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    shipping_zone_id UUID REFERENCES public.shipping_zones(id) ON DELETE CASCADE NOT NULL,
    country_id INTEGER REFERENCES public.countries(id) ON DELETE CASCADE NOT NULL
);

-- 4. Biểu phí vận chuyển (Shipping Rates)
CREATE TABLE IF NOT EXISTS public.shipping_rates (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    shipping_zone_id UUID REFERENCES public.shipping_zones(id) ON DELETE CASCADE NOT NULL,
    weight_unit VARCHAR(10) CHECK (weight_unit IN ('g', 'kg')),
    min_value NUMERIC NOT NULL DEFAULT 0,
    max_value NUMERIC DEFAULT NULL,
    no_max BOOLEAN DEFAULT TRUE,
    price NUMERIC NOT NULL DEFAULT 0,
    CONSTRAINT chk_max_value CHECK (max_value > min_value OR no_max IS TRUE)
);

-- 5. Khách hàng (Customers)
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Địa chỉ khách hàng (Customer Addresses)
CREATE TABLE IF NOT EXISTS public.customer_addresses (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    phone_number VARCHAR(255) NOT NULL,
    dial_code VARCHAR(100) NOT NULL,
    country VARCHAR(255) NOT NULL,
    postal_code VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL
);

-- 7. Giỏ hàng (Carts - Table name: cards)
CREATE TABLE IF NOT EXISTS public.cards (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE NOT NULL
);

-- 8. Chi tiết giỏ hàng (Cart Items - Table name: card_items)
CREATE TABLE IF NOT EXISTS public.card_items (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    card_id UUID REFERENCES public.cards(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    quantity INTEGER DEFAULT 1
);

-- 9. Nhà cung cấp (Suppliers)
CREATE TABLE IF NOT EXISTS public.suppliers (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_name VARCHAR(255) NOT NULL,
    company VARCHAR(255),
    phone_number VARCHAR(255),
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    country_id INTEGER REFERENCES public.countries(id) ON DELETE RESTRICT NOT NULL,
    city VARCHAR(255),
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 10. Bảng trung gian Sản phẩm - Nhà cung cấp (Product Suppliers)
CREATE TABLE IF NOT EXISTS public.product_suppliers (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE CASCADE NOT NULL
);

-- 11. Mã giảm giá (Coupons)
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_value NUMERIC,
    discount_type VARCHAR(50) NOT NULL,
    times_used NUMERIC NOT NULL DEFAULT 0,
    max_usage NUMERIC DEFAULT NULL,
    order_amount_limit NUMERIC DEFAULT NULL,
    coupon_start_date TIMESTAMPTZ,
    coupon_end_date TIMESTAMPTZ
);

-- 12. Bảng trung gian Sản phẩm - Khuyến mãi (Product Coupons)
CREATE TABLE IF NOT EXISTS public.product_coupons (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    coupon_id UUID REFERENCES public.coupons(id) ON DELETE CASCADE NOT NULL
);

-- 13. Kích thước & Khối lượng vận chuyển (Product Shipping Info)
CREATE TABLE IF NOT EXISTS public.product_shipping_info (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE UNIQUE,
    weight NUMERIC NOT NULL DEFAULT 0,
    weight_unit VARCHAR(10) CHECK (weight_unit IN ('g', 'kg')),
    volume NUMERIC NOT NULL DEFAULT 0,
    volume_unit VARCHAR(10) CHECK (volume_unit IN ('l', 'ml')),
    dimension_width NUMERIC NOT NULL DEFAULT 0,
    dimension_height NUMERIC NOT NULL DEFAULT 0,
    dimension_depth NUMERIC NOT NULL DEFAULT 0,
    dimension_unit VARCHAR(10) CHECK (dimension_unit IN ('l', 'ml'))
);

-- 14. Bộ sưu tập ảnh sản phẩm (Gallery)
CREATE TABLE IF NOT EXISTS public.gallery (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    image TEXT NOT NULL,
    placeholder TEXT NOT NULL,
    is_thumbnail BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. Thuộc tính sản phẩm (Attributes)
CREATE TABLE IF NOT EXISTS public.attributes (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    attribute_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 16. Giá trị của thuộc tính (Attribute Values)
CREATE TABLE IF NOT EXISTS public.attribute_values (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    attribute_id UUID REFERENCES public.attributes(id) ON DELETE CASCADE NOT NULL,
    attribute_value VARCHAR(255) NOT NULL,
    color VARCHAR(50) DEFAULT NULL
);

-- 17. Thuộc tính liên kết với sản phẩm (Product Attributes)
CREATE TABLE IF NOT EXISTS public.product_attributes (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    attribute_id UUID REFERENCES public.attributes(id) ON DELETE CASCADE NOT NULL
);

-- 18. Liên kết cụ thể giữa thuộc tính sản phẩm và các giá trị (Product Attribute Values)
CREATE TABLE IF NOT EXISTS public.product_attribute_values (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_attribute_id UUID REFERENCES public.product_attributes(id) ON DELETE CASCADE NOT NULL,
    attribute_value_id UUID REFERENCES public.attribute_values(id) ON DELETE CASCADE NOT NULL
);

-- 19. Các lựa chọn biến thể sản phẩm (Variant Options)
CREATE TABLE IF NOT EXISTS public.variant_options (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    image_id UUID REFERENCES public.gallery(id) ON DELETE SET NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    sale_price NUMERIC NOT NULL DEFAULT 0,
    compare_price NUMERIC DEFAULT 0,
    buying_price NUMERIC DEFAULT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    sku VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_var_compare_price CHECK (compare_price > sale_price OR compare_price = 0)
);

-- 20. Biến thể của sản phẩm (Variants)
CREATE TABLE IF NOT EXISTS public.variants (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_option TEXT NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    variant_option_id UUID REFERENCES public.variant_options(id) ON DELETE CASCADE NOT NULL
);

-- 21. Liên kết biến thể và thuộc tính sản phẩm cụ thể (Variant Values)
CREATE TABLE IF NOT EXISTS public.variant_values (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID REFERENCES public.variants(id) ON DELETE CASCADE NOT NULL,
    product_attribute_value_id UUID REFERENCES public.product_attribute_values(id) ON DELETE CASCADE NOT NULL
);

-- 22. Trạng thái đơn đặt hàng (Order Statuses)
CREATE TABLE IF NOT EXISTS public.order_statuses (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    status_name VARCHAR(255) NOT NULL,
    color VARCHAR(50) NOT NULL,
    privacy VARCHAR(10) CHECK (privacy IN ('public', 'private')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 23. Đơn đặt hàng (Orders)
CREATE TABLE IF NOT EXISTS public.orders (
    id VARCHAR(50) NOT NULL PRIMARY KEY,
    coupon_id UUID REFERENCES public.coupons(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    order_status_id UUID REFERENCES public.order_statuses(id) ON DELETE SET NULL,
    order_approved_at TIMESTAMPTZ,
    order_delivered_carrier_date TIMESTAMPTZ,
    order_delivered_customer_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 24. Chi tiết các sản phẩm trong đơn đặt hàng (Order Items)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    order_id VARCHAR(50) REFERENCES public.orders(id) ON DELETE CASCADE,
    price NUMERIC NOT NULL,
    quantity INTEGER NOT NULL
);

-- 25. Báo cáo doanh số sản phẩm (Sells)
CREATE TABLE IF NOT EXISTS public.sells (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID UNIQUE REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    price NUMERIC NOT NULL,
    quantity INTEGER NOT NULL
);

-- 26. Banner trình chiếu quảng cáo trang chủ (Slideshows)
CREATE TABLE IF NOT EXISTS public.slideshows (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(80),
    destination_url TEXT,
    image TEXT NOT NULL,
    placeholder TEXT NOT NULL,
    description VARCHAR(160),
    btn_label VARCHAR(50),
    display_order INTEGER NOT NULL,
    published BOOLEAN DEFAULT FALSE,
    clicks INTEGER NOT NULL DEFAULT 0,
    styles TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES public.staff_accounts(id) ON DELETE SET NULL
);

-- 27. Thông báo hệ thống cho quản trị viên (Notifications)
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES public.staff_accounts(id) ON DELETE CASCADE,
    title VARCHAR(100),
    content TEXT,
    seen BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    receive_time TIMESTAMPTZ,
    notification_expiry_date DATE
);

-- 28. Đánh giá và nhận xét sản phẩm (Product Reviews)
CREATE TABLE IF NOT EXISTS public.product_reviews (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.staff_accounts(id) ON DELETE CASCADE NOT NULL,
    rating INTEGER NOT NULL,
    title VARCHAR(255),
    comment TEXT NOT NULL,
    helpful_count INTEGER NOT NULL DEFAULT 0,
    is_approved BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(product_id, user_id)
);

-- 29. Ảnh của đánh giá sản phẩm (Review Images)
CREATE TABLE IF NOT EXISTS public.review_images (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID REFERENCES public.product_reviews(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
