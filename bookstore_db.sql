-- Homework 06: Online Bookstore Database Schema
-- Student: Nguyen Duc Hiep - 23070719

DROP DATABASE IF EXISTS bookstore_db;
CREATE DATABASE bookstore_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookstore_db;

-- 1. Table: categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB;

-- 2. Table: authors
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    country VARCHAR(60) DEFAULT 'Vietnam'
) ENGINE=InnoDB;

-- 3. Table: books
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(180) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    published_date DATE DEFAULT NULL,
    category_id INT NOT NULL,
    CONSTRAINT fk_book_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. Table: book_authors (M:N between books and authors)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Table: customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(255) NOT NULL,
    created_at DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

-- 6. Table: orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'paid', 'shipped', 'completed', 'cancelled') NOT NULL DEFAULT 'completed',
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. Table: order_items
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0),
    UNIQUE KEY uq_order_book (order_id, book_id),
    CONSTRAINT fk_item_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_item_book FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8. Table: reviews
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT DEFAULT NULL,
    review_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    UNIQUE KEY uq_review (book_id, customer_id),
    CONSTRAINT fk_review_book FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Indexes for query optimization
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_book ON order_items(book_id);

-- Sample Data: categories (5 categories)
INSERT INTO categories (category_name, description) VALUES
('Vietnamese Literature', 'Classic and modern Vietnamese novels and short stories'),
('World Fiction', 'Bestselling international novels and fiction'),
('Information Technology', 'Programming, software engineering, and web development'),
('Business & Economics', 'Management, finance, and entrepreneurship books'),
('Self-Help & Skills', 'Personal development and communication skills');

-- Sample Data: authors (8 authors)
INSERT INTO authors (author_name, email, country) VALUES
('Nguyen Nhat Anh', 'nhatanh@nxbtre.com.vn', 'Vietnam'),
('To Hoai', 'tohoai@nxbkimdong.com.vn', 'Vietnam'),
('Nam Cao', 'namcao@nxbvanhoc.com.vn', 'Vietnam'),
('Vu Trong Phung', 'vutrongphung@nxbvanhoc.com.vn', 'Vietnam'),
('Paulo Coelho', 'paulo@harpercollins.com', 'Brazil'),
('Robert C. Martin', 'unclebob@cleancoder.com', 'USA'),
('Dale Carnegie', 'info@dalecarnegie.com', 'USA'),
('Tran Minh Tuan', 'tuantm@vnu.edu.vn', 'Vietnam');

-- Sample Data: books (15 books)
INSERT INTO books (title, isbn, price, stock_qty, published_date, category_id) VALUES
('Mat Biec', '978-604-1-00001-1', 110.00, 45, '2019-07-10', 1),
('Toi Thay Hoa Vang Tren Co Xanh', '978-604-1-00002-8', 125.00, 40, '2018-05-20', 1),
('Cho Toi Xin Mot Ve Di Tuoi Tho', '978-604-1-00003-5', 95.00, 50, '2017-11-15', 1),
('De Men Phieu Luu Ky', '978-604-2-00004-2', 85.00, 60, '2016-06-01', 1),
('Chi Pheo', '978-604-2-00005-9', 78.00, 35, '2015-03-12', 1),
('So Do', '978-604-2-00006-6', 92.00, 30, '2016-09-25', 1),
('Nha Gia Kim', '978-604-3-00007-3', 105.00, 80, '2020-01-15', 2),
('Hoang Tu Be', '978-604-3-00008-0', 75.00, 55, '2019-04-10', 2),
('Clean Code', '978-013-2-35088-4', 320.00, 25, '2021-08-01', 3),
('Clean Architecture', '978-013-4-49416-6', 340.00, 20, '2022-02-14', 3),
('Web Development with PHP & MySQL', '978-604-4-00011-0', 210.00, 35, '2023-09-01', 3),
('Database System Concepts', '978-604-4-00012-7', 260.00, 18, '2022-10-20', 3),
('Khoi Nghiep Tinh Gon', '978-604-5-00013-4', 155.00, 40, '2021-05-05', 4),
('Dac Nhan Tam', '978-604-6-00014-1', 98.00, 90, '2018-12-01', 5),
('Quang Ganh Lo Di Va Vui Song', '978-604-6-00015-8', 102.00, 65, '2019-07-19', 5);

-- Sample Data: book_authors
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 3),
(6, 4),
(7, 5),
(8, 5),
(9, 6),
(10, 6),
(11, 8),
(12, 8),
(11, 6),
(13, 7),
(14, 7),
(15, 7);

-- Sample Data: customers (8 customers)
INSERT INTO customers (full_name, email, phone, address, created_at) VALUES
('Nguyen Duc Hiep', '23070719@vnu.edu.vn', '0912345601', 'Cau Giay, Ha Noi', '2025-09-10'),
('Nguyen Van An', 'annv@gmail.com', '0912345602', 'Nam Tu Liem, Ha Noi', '2025-10-05'),
('Tran Thi Binh', 'binhtt@gmail.com', '0912345603', 'Dong Da, Ha Noi', '2025-11-12'),
('Le Minh Hoang', 'hoanglm@gmail.com', '0912345604', 'Thanh Xuan, Ha Noi', '2025-12-01'),
('Pham Thi Mai', 'maipt@gmail.com', '0912345605', 'Ba Dinh, Ha Noi', '2026-01-15'),
('Hoang Quoc Viet', 'viethq@gmail.com', '0912345606', 'Hai Ba Trung, Ha Noi', '2026-01-20'),
('Vu Thu Trang', 'trangvt@gmail.com', '0912345607', 'Tay Ho, Ha Noi', '2026-02-02'),
('Dang Minh Quan', 'quandm@gmail.com', '0912345608', 'Hoan Kiem, Ha Noi', '2026-02-18');

-- Sample Data: orders (10 orders)
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2026-01-12 09:30:00', 'completed'),
(2, '2026-01-25 14:15:00', 'completed'),
(1, '2026-02-08 10:20:00', 'completed'),
(3, '2026-02-19 16:45:00', 'completed'),
(4, '2026-02-27 11:00:00', 'completed'),
(1, '2026-03-05 15:10:00', 'completed'),
(2, '2026-03-14 08:50:00', 'completed'),
(5, '2026-03-22 19:30:00', 'completed'),
(6, '2026-04-02 13:40:00', 'shipped'),
(2, '2026-04-10 17:05:00', 'completed');

-- Sample Data: order_items (25 items across the 10 orders)
INSERT INTO order_items (order_id, book_id, quantity, unit_price) VALUES
(1, 1, 2, 110.00),
(1, 9, 1, 320.00),
(1, 11, 1, 210.00),
(2, 2, 1, 125.00),
(2, 7, 2, 105.00),
(2, 14, 1, 98.00),
(3, 4, 2, 85.00),
(3, 10, 1, 340.00),
(4, 1, 1, 110.00),
(4, 3, 2, 95.00),
(4, 5, 1, 78.00),
(5, 9, 1, 320.00),
(5, 12, 1, 260.00),
(5, 13, 2, 155.00),
(6, 7, 1, 105.00),
(6, 14, 2, 98.00),
(6, 15, 1, 102.00),
(7, 6, 1, 92.00),
(7, 11, 2, 210.00),
(8, 1, 2, 110.00),
(8, 2, 1, 125.00),
(9, 4, 1, 85.00),
(9, 7, 2, 105.00),
(10, 9, 1, 320.00),
(10, 14, 2, 98.00);

-- Sample Data: reviews (12 reviews)
INSERT INTO reviews (book_id, customer_id, rating, review_text, review_date) VALUES
(1, 1, 5, 'Truyen rat hay va cam dong.', '2026-01-20'),
(1, 3, 5, 'Mot trong nhung tac pham dep nhat cua Nguyen Nhat Anh.', '2026-02-22'),
(2, 2, 4, 'Noi dung nhe nhang, gan gui voi tuoi tho.', '2026-01-30'),
(4, 1, 5, 'Sach kinh dien danh cho thieu nhi Viet Nam.', '2026-02-12'),
(5, 3, 4, 'Tac pham van hoc hien thuc xuat sac.', '2026-02-25'),
(7, 2, 5, 'Cuon sach truyen cam hung rat tot.', '2026-02-01'),
(7, 6, 4, 'Cau chuyen y nghia, de doc.', '2026-04-05'),
(9, 1, 5, 'Sach rat huu ich cho sinh vien CNTT.', '2026-01-22'),
(9, 4, 5, 'Giup viet code sach va de bao tri hon.', '2026-03-02'),
(10, 1, 4, 'Kien thuc thiet ke he thong rat thuc te.', '2026-02-15'),
(11, 2, 5, 'Phu hop voi mon hoc phat trien web PHP va MySQL.', '2026-03-18'),
(14, 5, 5, 'Sach hay ve giao tiep va ung xu.', '2026-03-26');
