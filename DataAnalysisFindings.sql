-- ###  (Data Analysis & Findings)

-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';

    
-- Task 8: Find Total Rental Income by Category:
SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM books as b
JOIN
issued_status as i
ON i.issued_book_isbn = b.isbn
GROUP BY 1;


-- Task 9. List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
    
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C201', 'sanjai', '201 Main St', '2024-08-01'),
('C202', 'swetha', '202 Main St', '2025-03-26'),
('C203', 'rishitha', '203 Main St', '2025-02-13'),
('C204', 'priyanka', '204 Main St', '2024-11-28');


-- Task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.*,
    b.supervisor_id,
    e2.emp_name as manager 
FROM employees as e1
JOIN  
branch as b
ON b.branch_code = e1.branch_code
JOIN
employees as e2
ON b.supervisor_id = e2.emp_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
CREATE TABLE books_price_greater_than_seven
AS    
SELECT * FROM Books
WHERE rental_price > 7;

SELECT * FROM  books_price_greater_than_seven;


-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
    DISTINCT i.issued_book_name
FROM issued_status as i
LEFT JOIN
return_status as rs
ON i.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;
