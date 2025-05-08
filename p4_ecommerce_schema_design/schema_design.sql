-- core user table
CREATE TABLE users (
    user_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR2(255) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    phone_number VARCHAR2(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status VARCHAR2(20) DEFAULT 'active' NOT NULL, 
    CONSTRAINT chk_status CHECK (status IN ('active', 'inactive', 'suspended')),
    CONSTRAINT chk_email CHECK (email LIKE '%_@__%.__%')
);

CREATE INDEX idx_users_email ON users(email);

-- core buyer / customer table
CREATE TABLE buyer_profiles (
    customer_id NUMBER PRIMARY KEY,
    birthday DATE,
    gender VARCHAR2(20),
    loyalty_points NUMBER DEFAULT 0,
    CONSTRAINT fk_buyer_user FOREIGN KEY (customer_id) REFERENCES users(user_id)
);

CREATE TABLE addresses (
    address_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id NUMBER NOT NULL,
    address_type VARCHAR2(20) DEFAULT 'SHIPPING' CHECK (address_type IN ('SHIPPING', 'BILLING', 'BOTH')),
    is_default NUMBER(1) DEFAULT 0 CHECK (is_default IN (0, 1)),
    recipient_name VARCHAR2(255) NOT NULL,
    street_address VARCHAR2(255) NOT NULL,
    city VARCHAR2(100) NOT NULL,
    state VARCHAR2(100) NOT NULL,
    postal_code VARCHAR2(20) NOT NULL,
    country VARCHAR2(100) NOT NULL,
    phone_number VARCHAR2(20),
    CONSTRAINT fk_address_user FOREIGN KEY (user_id) REFERENCES users(user_id),
);

CREATE INDEX idx_addresses_user_id ON addresses(user_id);

-- core seller / merchant tables
CREATE TABLE seller_profiles (
    seller_id NUMBER PRIMARY KEY,
    store_name VARCHAR2(255) NOT NULL,
    store_description TEXT,
    store_logo_url VARCHAR2(255),
    commission_rate NUMBER(5, 2) DEFAULT 10.00 CHECK (commission_rate >= 0 AND commission_rate <= 100),
    is_verified NUMBER(1) DEFAULT 0 CHECK (is_verified IN (0, 1)),
    tax_id VARCHAR2(50),
    rating NUMBER(3, 2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    rating_count NUMBER DEFAULT 0,
    CONSTRAINT fk_seller_user FOREIGN KEY (seller_id) REFERENCES users(user_id)
);

CREATE TABLE seller_payment_info (
    payment_info_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id NUMBER NOT NULL,
    bank_name VARCHAR2(255) NOT NULL,
    account_number VARCHAR2(50) NOT NULL,
    routing_number VARCHAR2(50),
    account_holder_name VARCHAR2(255) NOT NULL,
    payment_method VARCHAR2(50) CHECK (payment_method IN ('BANK_TRANSFER', 'PAYPAL', 'CREDIT_CARD', 'DEBIT_CARD')),
    is_default NUMBER(1) DEFAULT 1 CHECK (is_default IN (0, 1)),
    CONSTRAINT fk_payment_seller FOREIGN KEY (seller_id) REFERENCES seller_profiles(seller_id)
);

-- core product tables
CREATE TABLE categories (
    category_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR2(255) NOT NULL,
    parent_category_id NUMBER,
    description VARCHAR2(512),
    display_order NUMBER DEFAULT 0 NOT NULL,
    is_active NUMBER(1) DEFAULT 1 CHECK (is_active IN (0, 1)),
    CONSTRAINT fk_parent_category FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE INDEX idx_categories_parent ON categories(parent_category_id);

CREATE TABLE products (
    product_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    product_name VARCHAR2(255) NOT NULL,
    product_description TEXT,
    price NUMBER(10, 2) NOT NULL CHECK (price >= 0),
    tax_rate NUMBER(5, 2) DEFAULT 0 CHECK (tax_rate >= 0 AND tax_rate <= 100),
    stock_quantity NUMBER DEFAULT 0 CHECK (stock_quantity >= 0),
    sku VARCHAR2(50) UNIQUE,
    is_active NUMBER(1) DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    CONSTRAINT fk_product_seller FOREIGN KEY (seller_id) REFERENCES seller_profiles(seller_id),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE INDEX idx_products_seller ON products(seller_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_name ON products(product_name);

CREATE TABLE product_variants (
    variant_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id NUMBER NOT NULL,
    variant_name VARCHAR2(255) NOT NULL,
    variant_description TEXT,
    price NUMBER(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity NUMBER DEFAULT 0 CHECK (stock_quantity >= 0),
    sku VARCHAR2(50) UNIQUE,
    is_active NUMBER(1) DEFAULT 1 CHECK (is_active IN (0, 1)),
    CONSTRAINT fk_variant_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_variants_product ON product_variants(product_id);

CREATE TABLE product_images (
    image_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id NUMBER NOT NULL,
    image_url VARCHAR2(512) NOT NULL,
    carousel_order NUMBER DEFAULT 0,
    is_primary NUMBER(1) DEFAULT 0 CHECK (is_primary IN (0, 1)),
    CONSTRAINT fk_image_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_images_product ON product_images(product_id);

-- core order tables
CREATE TABLE carts (
    cart_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id NUMBER NOT NULL,
    session_id VARCHAR2(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    status VARCHAR2(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'ABANDONED')),
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE INDEX idx_carts_user ON carts(user_id);
CREATE INDEX idx_carts_session ON carts(session_id);

CREATE TABLE cart_items (
    cart_item_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cart_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER DEFAULT 1 CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    price_when_added NUMBER(10, 2) NOT NULL CHECK (price_when_added >= 0),
    CONSTRAINT fk_cart_item_cart FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
    CONSTRAINT fk_cart_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX idx_cart_items_product ON cart_items(product_id);

CREATE TABLE orders (
    order_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id NUMBER NOT NULL,
    status VARCHAR2(20) DEFAULT 'PENDING' CHECK (order_status IN ('PENDING', 'COMPLETED', 'CANCELLED', 'REFUNDED')),
    total_amount NUMBER(10, 2) NOT NULL CHECK (total_amount >= 0),
    tax_amount NUMBER(10, 2) DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_address_id NUMBER,
    billing_address_id NUMBER,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payment_status VARCHAR2(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED')),
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_order_shipping_address FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id),
    CONSTRAINT fk_order_billing_address FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id)
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);

CREATE TABLE order_items (
    order_item_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    seller_id NUMBER NOT NULL,
    quantity NUMBER DEFAULT 1 CHECK (quantity > 0),
    price NUMBER(10, 2) NOT NULL CHECK (price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_seller ON order_items(seller_id);

-- core payment tables
CREATE TABLE payments (
    payment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id NUMBER NOT NULL,
    payment_method VARCHAR2(50) CHECK (payment_method IN ('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'BANK_TRANSFER')),
    amount NUMBER(10, 2) NOT NULL CHECK (amount >= 0),
    payment_status VARCHAR2(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'COMPLETED', 'FAILED')),
    transaction_id VARCHAR2(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(payment_status);

CREATE TABLE seller_payouts (
    payout_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id NUMBER NOT NULL,
    payout_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount NUMBER(10, 2) NOT NULL CHECK (amount >= 0),
    status VARCHAR2(20) DEFAULT 'PENDING' CHECK (payout_status IN ('PENDING', 'COMPLETED', 'FAILED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payout_seller FOREIGN KEY (seller_id) REFERENCES seller_profiles(seller_id)
)

CREATE INDEX idx_payouts_seller ON seller_payouts(seller_id);
CREATE INDEX idx_payouts_date ON seller_payouts(payout_date);
CREATE INDEX idx_payouts_status ON seller_payouts(status);

-- core review tables
CREATE TABLE product_reviews (
    review_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id NUMBER NOT NULL,
    user_id NUMBER NOT NULL,
    rating NUMBER(2, 1) CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE INDEX idx_reviews_product ON product_reviews(product_id);
CREATE INDEX idx_reviews_user ON product_reviews(user_id);
CREATE INDEX idx_reviews_rating ON product_reviews(rating);

-- wishlist tables
CREATE TABLE wishlists (
    wishlist_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE INDEX idx_wishlists_user ON wishlists(user_id);

CREATE TABLE wishlist_items (
    wishlist_item_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wishlist_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wishlist_item_wishlist FOREIGN KEY (wishlist_id) REFERENCES wishlists(wishlist_id),
    CONSTRAINT fk_wishlist_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_wishlist_items_wishlist ON wishlist_items(wishlist_id);
CREATE INDEX idx_wishlist_items_product ON wishlist_items(product_id);

-- promos / discounts tables
CREATE TABLE promotions (
    discount_code_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR2(50) NOT NULL UNIQUE,
    discount_type VARCHAR2(20) CHECK (discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')),
    discount_value NUMBER(10, 2) NOT NULL CHECK (discount_value >= 0),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    usage_limit NUMBER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date); 
CREATE INDEX idx_promotions_active ON promotions(code);

