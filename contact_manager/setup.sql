-- Homework 10: Contact Manager Database Setup
-- Nguyen Duc Hiep (23070719)

SET NAMES utf8mb4;
DROP DATABASE IF EXISTS contact_manager_db;
CREATE DATABASE contact_manager_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE contact_manager_db;

CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    group_name ENUM('Family', 'Friends', 'Work', 'Other') NOT NULL DEFAULT 'Other',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO contacts (name, email, phone, group_name, notes) VALUES
('Nguyen Duc Hiep', 'hiephh0307@gmail.com', '0912345678', 'Work', 'Student ID 23070719 - Class INS306404'),
('Nguyen Van An', 'an.nguyen@gmail.com', '0987654321', 'Family', 'Older brother in Cau Giay, Hanoi'),
('Tran Thi Binh', 'binh.tran@gmail.com', '0978123456', 'Family', 'Cousin living in Dong Da district'),
('Le Minh Hoang', 'hoang.le@gmail.com', '0934567890', 'Friends', 'Study group partner for web development'),
('Pham Thi Mai', 'mai.pham@gmail.com', '0945678901', 'Friends', 'Badminton club friend'),
('Vu Quang Huy', 'huy.vu@company.vn', '0961234567', 'Work', 'Part-time internship colleague'),
('Do Thu Ha', 'ha.do@company.vn', '0923456789', 'Work', 'Project team member'),
('Bui Tuan Anh', 'tuananh.bui@gmail.com', '0904112233', 'Other', 'Apartment landlord contact');
