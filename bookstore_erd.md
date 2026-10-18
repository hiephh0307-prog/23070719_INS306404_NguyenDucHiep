# Homework 06: Online Bookstore Database Design (ERD)

- **Student:** Nguyen Duc Hiep
- **Student ID:** 23070719
- **Course:** INS3064 - Multimedia Design and Web Development

## 1. Entity-Relationship Diagram (ERD)

```text
+------------------+          1 : N          +------------------+
|    categories    |------------------------<|      books       |
+------------------+                         +------------------+
| PK category_id   |                         | PK book_id       |
|    category_name |                         |    title         |
|    description   |                         |    isbn (UNIQUE) |
+------------------+                         |    price         |
                                             |    stock_qty     |
+------------------+          M : N          |    published_date|
|     authors      |>-----------------------<| FK category_id   |
+------------------+   (via book_authors)    +------------------+
| PK author_id     |                               |      |
|    author_name   |      +------------------+     |      |
|    email         |      |   book_authors   |     |      |
|    country       |      +------------------+     |      |
+------------------+      | PK,FK book_id    |-----+      |
         |                | PK,FK author_id  |            |
         +----------------|                  |            |
                          +------------------+            |
                                                          |
+------------------+          1 : N          +------------+-----+
|    customers     |------------------------<|     reviews      |
+------------------+                         +------------------+
| PK customer_id   |                         | PK review_id     |
|    full_name     |                         | FK book_id       |
|    email (UNIQUE)|                         | FK customer_id   |
|    phone         |                         |    rating (1-5)  |
|    address       |                         |    review_text   |
|    created_at    |                         |    review_date   |
+------------------+                         +------------------+
         |                                                |
         | 1 : N                                          |
         v                                                |
+------------------+          1 : N          +------------+-----+
|      orders      |------------------------<|   order_items    |
+------------------+                         +------------------+
| PK order_id      |                         | PK order_item_id |
| FK customer_id   |                         | FK order_id      |
|    order_date    |                         | FK book_id       |
|    status        |                         |    quantity      |
+------------------+                         |    unit_price    |
                                             +------------------+
```

## 2. Relationships Summary

| Parent Table | Child Table | Cardinality | Description |
| :--- | :--- | :---: | :--- |
| `categories` | `books` | `1 : N` | One category contains many books; each book belongs to one category. |
| `books` & `authors` | `book_authors` | `M : N` | A book can have multiple authors, and an author can write multiple books. |
| `customers` | `orders` | `1 : N` | One customer can place many orders. |
| `orders` | `order_items` | `1 : N` | One order contains one or more order items. |
| `books` | `order_items` | `1 : N` | One book can appear in many order items. |
| `books` | `reviews` | `1 : N` | One book can receive many reviews from customers. |
| `customers` | `reviews` | `1 : N` | One customer can write reviews for multiple books. |

## 3. Normalization (3NF)

- **First Normal Form (1NF):** Every column stores atomic values. Multi-valued attributes like book authors and order items are separated into `book_authors` and `order_items`.
- **Second Normal Form (2NF):** In `book_authors (book_id, author_id)`, non-key attributes depend on the whole composite key. Author details (`author_name`, `email`) are stored in `authors`, and book details (`title`, `price`) are stored in `books`.
- **Third Normal Form (3NF):** No transitive dependencies exist. Category names are stored in `categories` instead of `books`, customer addresses are stored in `customers` instead of `orders`, and order totals are calculated from `SUM(quantity * unit_price)` in `order_items` instead of storing a redundant total column.
