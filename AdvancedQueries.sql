-- ### (Advanced SQL Operations)

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
SELECT CURRENT_DATE;

SELECT 
    m.member_id,
    m.member_name,
    b.book_title,
    i.issued_date,
    CURRENT_DATE - i.issued_date AS days_overdue
FROM issued_status i
JOIN members m ON m.member_id = i.issued_member_id
JOIN books b ON b.isbn = i.issued_book_isbn
LEFT JOIN return_status r ON r.issued_id = i.issued_id
WHERE r.return_date IS NULL
  AND CURRENT_DATE - i.issued_date > 30;
 
 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
UPDATE books
SET status = 'Yes'
WHERE isbn IN (
    SELECT issued_book_isbn
    FROM issued_status
    WHERE issued_id IN (
        SELECT issued_id FROM return_status
    )
);


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
CREATE TABLE branch_reports AS
SELECT 
    b.branch_code,
    b.supervisor_id,
    COUNT(DISTINCT i.issued_id) AS number_book_issued,
    COUNT(DISTINCT r.return_id) AS number_of_book_return,
    SUM(DISTINCT bk.rental_price) AS total_revenue
FROM issued_status i
JOIN employees e ON e.emp_id = i.issued_emp_id
JOIN branch b ON e.branch_code = b.branch_code
LEFT JOIN return_status r ON r.issued_id = i.issued_id
JOIN books bk ON i.issued_book_isbn = bk.isbn
GROUP BY b.branch_code, b.supervisor_id;

SELECT * FROM branch_reports;


/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;


/*
 Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/
SELECT 
    e.emp_name,
	b.*,
    COUNT(i.issued_id) AS no_book_issued
FROM issued_status AS i
JOIN employees AS e ON e.emp_id = i.issued_emp_id
JOIN branch AS b ON e.branch_code = b.branch_code
GROUP BY e.emp_name, 2
ORDER BY no_book_issued DESC
LIMIT 3;


/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "Damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.
*/
ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117','IS116', 'IS118');
SELECT * FROM return_status;
-----------------

SELECT 
    m.member_name,
    b.book_title AS book_title,
    COUNT(*) AS times_issued_damaged
FROM 
    issued_status i
JOIN 
    return_status r ON i.issued_id = r.issued_id
JOIN 
    books b ON i.issued_book_isbn = b.isbn
JOIN 
    members m ON i.issued_member_id = m.member_id
WHERE 
    r.book_quality = 'Damaged'
GROUP BY 
    m.member_name, b.book_title
HAVING 
    COUNT(*)>2;


/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

CREATE OR REPLACE PROCEDURE issue_book(
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(30),
    p_issued_book_isbn VARCHAR(30),
    p_issued_emp_id VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(10);
BEGIN
    -- Check if the book exists and get its current status
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    -- If book is available, proceed to issue
    IF v_status = 'yes' THEN
        -- Insert record into issued_status table
        INSERT INTO issued_status(
            issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id
        )
        VALUES (
            p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id
        );

        -- Update book status to 'no' in books table
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book has been issued successfully. ISBN: %', p_issued_book_isbn;

    ELSE
        -- If book is already issued, notify user
        RAISE NOTICE 'Book is currently unavailable. ISBN: %', p_issued_book_isbn;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No book found with the given ISBN: %', p_issued_book_isbn;
    WHEN OTHERS THEN
        RAISE NOTICE 'An unexpected error occurred: %', SQLERRM;
END;
$$;


 /*
Task 20: Create Table As Select (CTAS)

Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/ 
 CREATE TABLE overdue_summary AS
SELECT  
    i.issued_member_id AS member_id,
    COUNT(*) FILTER (
        WHERE r.return_date IS NULL 
           AND CURRENT_DATE - i.issued_date > 30
    ) AS overdue_books,
    
    SUM(
        CASE 
            WHEN r.return_date IS NULL AND CURRENT_DATE - i.issued_date > 30 
            THEN (CURRENT_DATE - i.issued_date - 30) * 0.50
            ELSE 0
        END
    ) AS total_fines,
    
    COUNT(*) AS total_books_issued
FROM 
    issued_status i
LEFT JOIN 
    return_status r ON i.issued_id = r.issued_id
GROUP BY 
    i.issued_member_id;

SELECT * FROM overdue_summary;
