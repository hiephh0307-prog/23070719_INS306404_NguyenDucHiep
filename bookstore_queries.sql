-- Homework 07: Online Bookstore Advanced SQL Queries
-- Student: Nguyen Duc Hiep - 23070719

USE bookstore_db;

-- Query 1 (Multi-Table JOIN #1): List all books with their authors and category
SELECT 
    b.book_id,
    b.isbn,
    b.title,
    a.author_name,
    c.category_name,
    b.price
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
INNER JOIN categories c ON b.category_id = c.category_id
ORDER BY b.book_id, a.author_name;

-- Query 2 (Multi-Table JOIN #2): Detailed order invoice report with customer and book info
SELECT 
    o.order_id,
    c.full_name AS customer_name,
    DATE_FORMAT(o.order_date, '%Y-%m-%d') AS order_date,
    o.status,
    b.title AS book_title,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS subtotal
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN books b ON oi.book_id = b.book_id
WHERE o.status <> 'cancelled'
ORDER BY o.order_date, o.order_id;

-- Query 3 (Multi-Table JOIN #3): List all customer reviews with book title, category, and customer name
SELECT 
    r.review_id,
    b.title AS book_title,
    c.category_name,
    cu.full_name AS customer_name,
    r.rating,
    r.review_text,
    r.review_date
FROM reviews r
INNER JOIN books b ON r.book_id = b.book_id
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN customers cu ON r.customer_id = cu.customer_id
ORDER BY r.review_date DESC;

-- Query 4 (GROUP BY Aggregation #1): Total quantity sold and total revenue per book
SELECT 
    b.book_id,
    b.title,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM books b
INNER JOIN order_items oi ON b.book_id = oi.book_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY b.book_id, b.title
ORDER BY total_revenue DESC;

-- Query 5 (GROUP BY Aggregation #2): Customer spending summary (including customers with 0 orders)
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status <> 'cancelled'
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.full_name, c.email
ORDER BY total_spent DESC;

-- Query 6 (Subquery #1): Find books priced higher than the average book price
SELECT 
    book_id,
    isbn,
    title,
    price,
    (SELECT ROUND(AVG(price), 2) FROM books) AS avg_catalog_price
FROM books
WHERE price > (SELECT AVG(price) FROM books)
ORDER BY price DESC;

-- Query 7 (Subquery #2): Find the best-selling author(s) by total quantity of books sold
SELECT 
    a.author_id,
    a.author_name,
    SUM(oi.quantity) AS total_books_sold,
    SUM(oi.quantity * oi.unit_price) AS author_revenue
FROM authors a
INNER JOIN book_authors ba ON a.author_id = ba.author_id
INNER JOIN order_items oi ON ba.book_id = oi.book_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY a.author_id, a.author_name
HAVING SUM(oi.quantity) = (
    SELECT MAX(author_totals.sold_qty)
    FROM (
        SELECT SUM(oi2.quantity) AS sold_qty
        FROM book_authors ba2
        INNER JOIN order_items oi2 ON ba2.book_id = oi2.book_id
        INNER JOIN orders o2 ON oi2.order_id = o2.order_id
        WHERE o2.status <> 'cancelled'
        GROUP BY ba2.author_id
    ) AS author_totals
);

-- Query 8 (GROUP BY + HAVING): Customers who placed more than 2 orders
SELECT 
    c.customer_id,
    c.full_name,
    c.phone,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY c.customer_id, c.full_name, c.phone
HAVING COUNT(DISTINCT o.order_id) > 2
ORDER BY total_spending DESC;

-- Query 9 (CREATE VIEW + SELECT): View for book sales and rating summary
CREATE OR REPLACE VIEW v_book_sales_summary AS
SELECT 
    b.book_id,
    b.isbn,
    b.title,
    c.category_name,
    b.price,
    b.stock_qty,
    COALESCE(s.units_sold, 0) AS total_sold,
    COALESCE(s.revenue, 0.00) AS total_revenue,
    COALESCE(rv.review_count, 0) AS total_reviews,
    ROUND(COALESCE(rv.avg_rating, 0.00), 2) AS avg_rating
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
LEFT JOIN (
    SELECT 
        oi.book_id,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY oi.book_id
) s ON b.book_id = s.book_id
LEFT JOIN (
    SELECT 
        book_id,
        COUNT(review_id) AS review_count,
        AVG(rating) AS avg_rating
    FROM reviews
    GROUP BY book_id
) rv ON b.book_id = rv.book_id;

SELECT * FROM v_book_sales_summary ORDER BY total_revenue DESC;

-- Query 10 (Combined Business Report): Monthly revenue report by category and month
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS books_sold,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month ASC;
