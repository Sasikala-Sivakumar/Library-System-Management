# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `Library_System_Project_DB`

This project showcases key SQL skills and techniques used to design and manage a library management system. It includes creating a structured database, performing CRUD operations, executing complex queries, and managing relational tables to simulate real-world library functions and workflows

![img](https://github.com/user-attachments/assets/92bcb45b-0a2c-4dc6-8ccd-6d7da24fc84d)


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.


## Dataset used
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/books.csv">BooksData</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/branch.csv">BranchData</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/employees.csv">EmployeesData</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/issued_status.csv">IssuedStatusData</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/members.csv">MembersData</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/return_status.csv">ReturnStatusData</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/Create_Queries.sql">Create_Queries</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/Crud%26Ctas.sql">CRUD&CTAS_Queries</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/DataAnalysisFindings.sql">Data_Analysis_Findings</a>
- <a href="https://github.com/Sasikala-Sivakumar/Library-System-Management/blob/main/AdvancedQueries.sql">Advanced_Queries</a>


## Project Structure

### 1. Database Setup
![ERD_File](https://github.com/user-attachments/assets/cb617c64-e1ad-4a41-a37b-209f212ced15)


- **Database Creation**: Created a database named `Library_System_Project_DB`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
 DROP DATABASE IF EXISTS "Library_System_Project_DB";
CREATE DATABASE "Library_System_Project_DB";
```


### CREATE QUERIES

```sql 
-- Create table "Branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch 
(
            branch_code VARCHAR(10) PRIMARY KEY,
            supervisor_id VARCHAR(10),
            branch_location VARCHAR(30),
            branch_phone VARCHAR(15)
);

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            department VARCHAR(30),
            salary DECIMAL(10,2),
            branch_code VARCHAR(10),
            FOREIGN KEY (branch_code) REFERENCES  branch(branch_code)
);			

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
( 
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```


### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
     i.issued_emp_id,
    e.emp_name
FROM issued_status as i
JOIN
employees as e
ON e.emp_id = i.issued_emp_id
GROUP BY 1, 2
HAVING COUNT(i.issued_id) > 1;
```


### 3. CTAS (Create Table As Select)

**Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnts
AS    
SELECT 
    b.isbn, 
    b.book_title,
    COUNT(i.issued_id) as no_issued
FROM books as b
JOIN
issued_status as i
ON i.issued_book_isbn = b.isbn
GROUP BY 1, 2;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

 **Task 7: Retrieve All Books in a Specific Category**

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

**Task 8: Find Total Rental Income by Category**

```sql
SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM books as b
JOIN
issued_status as i
ON i.issued_book_isbn = b.isbn
GROUP BY 1;
```

**Task 9: List Members Who Registered in the Last 180 Days**

```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Task 10: List Employees with Their Branch Manager's Name and their branch details**

```sql
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
```

**Task 11: Create a Table of Books with Rental Price Above a Certain Threshold (7USD)**

```sql

CREATE TABLE books_price_greater_than_seven
AS    
SELECT * FROM Books
WHERE rental_price > 7;
```

**Task 12: Retrieve the List of Books Not Yet Returned**

```sql
SELECT 
    DISTINCT i.issued_book_name
FROM issued_status as i
LEFT JOIN
return_status as rs
ON i.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
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
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

```sql
UPDATE books
SET status = 'Yes'
WHERE isbn IN (
    SELECT issued_book_isbn
    FROM issued_status
    WHERE issued_id IN (
        SELECT issued_id FROM return_status
    )
);
```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
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
```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
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
```
**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
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
```


**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
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
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project serves as a comprehensive introduction to SQL for database development, covering table creation, data manipulation, and complex query execution within a library management context. The outcomes of this project demonstrate how structured data handling and querying can streamline operations, improve information access, and support effective decision-making in library systems.

## Author   
**Name**: [Sasikala Sivakumar]  
**Email**: [sasikala26032001@gmail.com]

---

⭐ **If you found this project useful, don't forget to give it a star!** ⭐
