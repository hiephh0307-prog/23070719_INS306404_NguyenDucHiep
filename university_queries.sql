-- Homework 05: University Database SQL Queries
-- Student: Nguyen Duc Hiep - 23070719

USE university_db;

-- Query 1: List all students with their department name
SELECT 
    s.student_id,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name,
    s.email,
    s.gpa,
    d.department_name
FROM students s
INNER JOIN departments d ON s.department_id = d.department_id
ORDER BY s.student_id;

-- Query 2: List all courses with their professor's full name and department
SELECT 
    c.course_id,
    c.course_code,
    c.course_name,
    c.credits,
    CONCAT(p.last_name, ' ', p.first_name) AS professor_name,
    d.department_name
FROM courses c
INNER JOIN professors p ON c.professor_id = p.professor_id
INNER JOIN departments d ON c.department_id = d.department_id
ORDER BY c.course_code;

-- Query 3: Find the number of students enrolled in each course, showing only courses with more than 2 students
SELECT 
    c.course_id,
    c.course_code,
    c.course_name,
    COUNT(e.student_id) AS total_students
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_name
HAVING COUNT(e.student_id) > 2
ORDER BY total_students DESC;

-- Query 4: Find all students who have NOT enrolled in any course
SELECT 
    s.student_id,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name,
    s.email,
    s.enrollment_date
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL;

-- Query 5: Find the department with the highest budget, showing department name, budget, and head professor's name
SELECT 
    d.department_name,
    d.budget,
    CONCAT(p.last_name, ' ', p.first_name) AS head_professor_name
FROM departments d
LEFT JOIN professors p ON d.head_professor_id = p.professor_id
WHERE d.budget = (SELECT MAX(budget) FROM departments);

-- Query 6: Calculate the average grade for each student across all their enrolled courses
SELECT 
    s.student_id,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name,
    COUNT(e.course_id) AS courses_taken,
    ROUND(AVG(e.grade), 2) AS average_grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY average_grade DESC;

-- Query 7: Find all professors who teach more than 1 course
SELECT 
    p.professor_id,
    CONCAT(p.last_name, ' ', p.first_name) AS professor_name,
    p.email,
    COUNT(c.course_id) AS total_courses
FROM professors p
INNER JOIN courses c ON p.professor_id = c.professor_id
GROUP BY p.professor_id, p.first_name, p.last_name, p.email
HAVING COUNT(c.course_id) > 1
ORDER BY total_courses DESC;

-- Query 8: List all courses that have no students enrolled
SELECT 
    c.course_id,
    c.course_code,
    c.course_name,
    c.credits
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;

-- Query 9: Find the top 3 students by GPA overall
SELECT 
    s.student_id,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name,
    d.department_name,
    s.gpa
FROM students s
INNER JOIN departments d ON s.department_id = d.department_id
ORDER BY s.gpa DESC
LIMIT 3;

-- Query 10: Summary report showing department name, total professors, total students, total courses, and average student GPA
SELECT 
    d.department_name,
    COUNT(DISTINCT p.professor_id) AS total_professors,
    COUNT(DISTINCT s.student_id) AS total_students,
    COUNT(DISTINCT c.course_id) AS total_courses,
    ROUND(AVG(s.gpa), 2) AS avg_student_gpa
FROM departments d
LEFT JOIN professors p ON d.department_id = p.department_id
LEFT JOIN students s ON d.department_id = s.department_id
LEFT JOIN courses c ON d.department_id = c.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_id;
