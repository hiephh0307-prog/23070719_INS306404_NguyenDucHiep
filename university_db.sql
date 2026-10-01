-- Homework 04: University Database Design
-- Student: Nguyen Duc Hiep - 23070719

DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE university_db;

-- 1. Table: departments
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building VARCHAR(50) NOT NULL,
    budget DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    head_professor_id INT DEFAULT NULL
) ENGINE=InnoDB;

-- 2. Table: professors
CREATE TABLE professors (
    professor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department_id INT NOT NULL,
    CONSTRAINT fk_prof_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Add foreign key for head_professor_id after professors table is created
ALTER TABLE departments
    ADD CONSTRAINT fk_dept_head FOREIGN KEY (head_professor_id)
        REFERENCES professors(professor_id)
        ON DELETE SET NULL ON UPDATE CASCADE;

-- 3. Table: courses
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(120) NOT NULL,
    credits INT NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id INT NOT NULL,
    professor_id INT NOT NULL,
    CONSTRAINT fk_course_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_course_prof FOREIGN KEY (professor_id)
        REFERENCES professors(professor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. Table: students
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    enrollment_date DATE NOT NULL,
    gpa DECIMAL(3, 2) DEFAULT 0.00 CHECK (gpa >= 0.00 AND gpa <= 4.00),
    department_id INT NOT NULL,
    CONSTRAINT fk_student_dept FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Table: enrollments
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    grade DECIMAL(3, 2) DEFAULT NULL CHECK (grade IS NULL OR (grade >= 0.00 AND grade <= 4.00)),
    UNIQUE KEY uq_enrollment (student_id, course_id, semester),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enroll_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Sample Data: departments (4 departments)
INSERT INTO departments (department_name, building, budget) VALUES
('Information Systems', 'Building C - Trinh Van Bo', 500000.00),
('Computer Science', 'Building A - Xuan Thuy', 650000.00),
('Business Administration', 'Building B - Trinh Van Bo', 450000.00),
('Data Science & AI', 'Building D - Hoa Lac', 700000.00);

-- Sample Data: professors (6 professors)
INSERT INTO professors (first_name, last_name, email, hire_date, salary, department_id) VALUES
('Minh', 'Nguyen Quang', 'minhnq@vnu.edu.vn', '2018-09-01', 2800.00, 1),
('Hung', 'Tran Van', 'hungtv@vnu.edu.vn', '2019-03-15', 2600.00, 1),
('Lan', 'Pham Thi', 'lanpt@vnu.edu.vn', '2017-08-20', 3100.00, 2),
('Tuan', 'Le Anh', 'tuanla@vnu.edu.vn', '2020-01-10', 2500.00, 2),
('Huong', 'Vu Thi', 'huongvt@vnu.edu.vn', '2016-11-05', 2900.00, 3),
('Khoa', 'Dang Minh', 'khoadm@vnu.edu.vn', '2021-06-01', 3000.00, 4);

-- Assign head professors for each department
UPDATE departments SET head_professor_id = 1 WHERE department_id = 1;
UPDATE departments SET head_professor_id = 3 WHERE department_id = 2;
UPDATE departments SET head_professor_id = 5 WHERE department_id = 3;
UPDATE departments SET head_professor_id = 6 WHERE department_id = 4;

-- Sample Data: courses (9 courses)
INSERT INTO courses (course_code, course_name, credits, department_id, professor_id) VALUES
('INS3064', 'Multimedia Design and Web Development', 3, 1, 1),
('INS2031', 'Database Management Systems', 3, 1, 1),
('INS3012', 'System Analysis and Design', 3, 1, 2),
('CSC2001', 'Data Structures and Algorithms', 4, 2, 3),
('CSC2005', 'Object-Oriented Programming', 3, 2, 3),
('CSC3010', 'Computer Networks', 3, 2, 4),
('BUS1001', 'Principles of Management', 3, 3, 5),
('DSA3001', 'Machine Learning Fundamentals', 4, 4, 6),
('DSA3008', 'Deep Learning Applications', 3, 4, 6);

-- Sample Data: students (11 students)
INSERT INTO students (first_name, last_name, email, enrollment_date, gpa, department_id) VALUES
('Hiep', 'Nguyen Duc', '23070719@vnu.edu.vn', '2023-09-05', 3.65, 1),
('An', 'Nguyen Van', 'annv@vnu.edu.vn', '2023-09-05', 3.80, 1),
('Binh', 'Tran Thi', 'binhtt@vnu.edu.vn', '2023-09-05', 3.45, 1),
('Cuong', 'Le Quoc', 'cuonglq@vnu.edu.vn', '2022-09-05', 3.20, 2),
('Dung', 'Pham Minh', 'dungpm@vnu.edu.vn', '2022-09-05', 3.90, 2),
('Giang', 'Hoang Thu', 'gianght@vnu.edu.vn', '2023-09-05', 3.10, 2),
('Ha', 'Ngo Thanh', 'hant@vnu.edu.vn', '2023-09-05', 3.55, 3),
('Khanh', 'Do Duy', 'khanhdd@vnu.edu.vn', '2024-09-05', 2.95, 3),
('Linh', 'Bui Phuong', 'linhbp@vnu.edu.vn', '2023-09-05', 3.75, 4),
('Nam', 'Vu Hoang', 'namvh@vnu.edu.vn', '2024-09-05', 3.40, 4),
('Phuc', 'Trinh Gia', 'phuctg@vnu.edu.vn', '2024-09-05', 3.00, 3);

-- Sample Data: enrollments (22 enrollments)
INSERT INTO enrollments (student_id, course_id, semester, grade) VALUES
(1, 1, 'Fall 2025', 3.80),
(1, 2, 'Fall 2025', 3.60),
(1, 3, 'Spring 2026', 3.50),
(2, 1, 'Fall 2025', 3.90),
(2, 2, 'Fall 2025', 3.70),
(2, 4, 'Spring 2026', 3.80),
(3, 1, 'Fall 2025', 3.40),
(3, 2, 'Fall 2025', 3.50),
(3, 3, 'Spring 2026', 3.45),
(4, 4, 'Fall 2025', 3.20),
(4, 5, 'Fall 2025', 3.10),
(4, 6, 'Spring 2026', 3.30),
(5, 1, 'Fall 2025', 4.00),
(5, 4, 'Fall 2025', 3.90),
(5, 5, 'Spring 2026', 3.85),
(6, 4, 'Fall 2025', 3.00),
(6, 6, 'Spring 2026', 3.20),
(7, 7, 'Fall 2025', 3.60),
(7, 1, 'Spring 2026', 3.50),
(8, 7, 'Fall 2025', 2.95),
(9, 8, 'Fall 2025', 3.80),
(10, 8, 'Fall 2025', 3.40);
