--1. Write a query to count the number of customers with a customer balance over $500
SELECT COUNT(*) FROM CUSTOMER WHERE CUS_BALANCE > 500;


--2. Write a query to list all products (only columns Product code and Description should be displayed) for which no
--vendor code has been specified.
SELECT * FROM PRODUCT WHERE V_CODE IS NULL;


--3. Write a query to list all customers (first name, last name, and phone) whose first name starts with ‘A’. sort the
--results alphabetically by first name.
SELECT CUS_FNAME, CUS_LNAME, CUS_PHONE 
FROM CUSTOMER 
WHERE CUS_FNAME LIKE 'A%'
ORDER BY CUS_FNAME;


--4. Create a query to find the customer balance characteristics for all customers, including the total of the
--outstanding balances. The results of this query are shown below.
SELECT SUM(CUS_BALANCE) "Total Balance", 
MIN(CUS_BALANCE) "Min Balance", 
MAX(CUS_BALANCE) "Max Balance", 
AVG(CUS_BALANCE) "Min Balance" 
FROM CUSTOMER;

--5. Generate a listing of all purchases made by the customers, using the output shown in Table (5) as your guide.
--The sorting of the resulting rows should also be based on the following output.
SELECT  C.CUS_CODE , I.INV_NUMBER, I.INV_DATE, P.P_DESCRIPT ,L.LINE_UNITS, L.LINE_PRICE   
FROM CUSTOMER C, INVOICE I, PRODUCT P, LINE L
WHERE C.CUS_CODE = I.CUS_CODE
AND I.INV_NUMBER = L.INV_NUMBER
AND L.P_CODE = P.P_CODE
GROUP BY  C.CUS_CODE , I.INV_NUMBER, I.INV_DATE, P.P_DESCRIPT ,L.LINE_UNITS, L.LINE_PRICE   
ORDER BY C.CUS_CODE;


--6. Using the output shown in Table 6 as your guide, create a query to produce the total purchase per invoice, i.e,
--you should generate the listing of total invoice value for each invoice in the LINE table. The output should
--include only invoices where the total invoice value is greater than 100. The output should be formatted as
--shown in Table 6
-------L.LINE_PRICE * L.LINE_UNITS = total purchase per invoice
SELECT I.INV_NUMBER, SUM(L.LINE_PRICE * L.LINE_UNITS) 
FROM INVOICE I, LINE L
WHERE I.INV_NUMBER = L.INV_NUMBER
GROUP BY  I.INV_NUMBER
HAVING SUM(L.LINE_PRICE * L.LINE_UNITS)  > 100;


--7.Use a SET operator to list all customer codes who have not made any purchases- i.e, there are no invoices
--generated for these customers. The resulting rows are shown below.
--. Queries that use UNION, UNION ALL, INTERSECT, and MINUS operators
SELECT C.CUS_CODE 
FROM CUSTOMER C
MINUS 
SELECT I.CUS_CODE
FROM INVOICE I;

-------------------------Section C
--1. Write the SQL code that will create the table structure for a table named EMP_1. This table is a subset of the
--EMPLOYEE table. The basic EMP_1 table structure is summarized in Table C1. (Note that the JOB_CODE is
--the FK to JOB.)
DROP TABLE  EMP_1;
CREATE TABLE EMP_1 (
EMP_NUM		CHAR(3) 		PRIMARY KEY,
EMP_LNAME		VARCHAR(15) 	NOT NULL,
EMP_FNAME		VARCHAR(15) 	NOT NULL,
EMP_INITIAL		CHAR(1),
EMP_HIREDATE	DATE,
JOB_CODE		CHAR(3),
FOREIGN KEY (JOB_CODE) REFERENCES JOB);


  CREATE TABLE EMP_1
  (
    EMP_NUM   CHAR(3) NOT NULL,
    EMP_LNAME   VARCHAR2(15) NOT NULL,
    EMP_FNAME  VARCHAR2(15) NOT NULL,
    EMP_INITAL CHAR(1) NOT NULL,
    EMP_HIREDATE DATE,
    JOB_CODE   VARCHAR2(3)NOT NULL,
    CONSTRAINT JOB_CODE_FK FOREIGN KEY (JOB_CODE) REFERENCES JOB (JOB_CODE)
   );


--2. Having created the table structure in Question 1, write the SQL code to enter the first two rows for the table
--shown in Figure C2

INSERT INTO EMP_1 VALUES ('101', 'news', 'john', 'g','08/11/2000', '502');
INSERT INTO EMP_1 VALUES ('102', 'senior', 'david', 'h', '12/07/1989', '501');

SELECT * FROM NLS_SESSION_PARAMETERS WHERE PARAMETER = 'NLS_DATE_LANGUAGE';


--3. Assuming that the data shown in the EMP_1 table have been entered, write the SQL code that will list all
--attributes for a job code of 502.
SELECT * FROM EMP_1 WHERE JOB_CODE = '502';

--4. Write the SQL code that will save the changes made to the EMP_1 table.
COMMIT;

--5. Write the SQL code to change the job code to 501 for the person whose employee number is 107. After you
--have completed the task, examine the results, and then reset the job code to its original value.
--Change Job Code for 107:
UPDATE EMP_1
SET JOB_CODE = '501'
WHERE EMP_NUM = '107';
--See Changes to 107:
SELECT *
FROM EMP_1
WHERE EMP_NUM = '107';
--Reset Job Code to Original Value:
ROLLBACK;

--6. Write the SQL code to delete the row for the person named William Smithfield, who was hired on June 22,
--2004 and whose job code classification is 500. (Hint: Use logical operators to include all the information given
--in this problem.)
DELETE	FROM EMP_1
WHERE	EMP_LNAME = 'Smithfield'
AND	EMP_FNAME = 'William'
AND	EMP_HIREDATE = '22/06/2004'
AND	JOB_CODE = '500';


--7. Write the SQL code that will restore the data to its original status; that is, the table should contain the data that
--existed before you made the changes in Questions 5 and 6.
ROLLBACK;


--8. Write the SQL code to create a copy of EMP_1, naming the copy EMP_2. Then write the SQL code that will
--add the attributes EMP_PCT and PROJ_NUM to its structure. The EMP_PCT is the bonus percentage to be
--paid to each employee. The new attribute characteristics are:
--EMP_PCT NUMBER(4,2)
--PROJ_NUM CHAR(3)10

--Copy Table:
CREATE TABLE EMP_2 AS
SELECT *
FROM EMP_1;
--Add New Rows:
ALTER TABLE EMP_2
ADD (EMP_PCT NUMBER(4,2),
 PROJ_NUM CHAR(3));
