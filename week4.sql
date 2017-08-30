--1. Use SQL character  functions  to generate a report for staff names and full email address 
--(email_ID@megacorp.com
select  concat(E.last_name||',' , ' '||E.first_name) "Full Name", concat(E.EMAIL,'@MEGACORP.COM') "Email"
from EMPLOYEES E
order by E.last_name;

--2. Use formatting functions to generate a report that display employees last names, basic salary 
-- with local currency as a prefix (e.g. NZD), commission percentage, and commission value 
-- (Salary * Commission %). If there is no commission value, the report should display “No 
--Commission” message. The output should be alphabetically sorted with respect to the last 
--names
select  E.last_name "Last Name", concat('NZL ',to_char(E.SALARY,'99,999')) "Salary",
        NVL(to_char(E.COMMISSION_PCT,'FM99.9'),0) "Commission %",  
        NVL(to_char(E.SALARY * E.COMMISSION_PCT,'FM99999'),'No Commission') "Commission"
from EMPLOYEES E
order by E.last_name;

--3. Generate a report to display full name, length (number of characters) of full name, hire day 
--and hire date for all staff members who earn a commission and do not hold the job title 
--“SA_MAN”. Rename the columns accordingly and format the report 
select E.first_name ||' '|| E.last_name "Full Name",
       (LENGTH(E.FIRST_NAME) + 1 + LENGTH(E.LAST_NAME) || ' Char.')  "Name Length",
       to_char(E.HIRE_DATE,'fmDay')"Hire Day" ,
       to_char(E.HIRE_DATE,'fmMonth ddth YYYY') "Hire Date",
       E.COMMISSION_PCT,
       E.JOB_ID
from Employees E 
where E.COMMISSION_PCT is not null and E.JOB_ID <> 'SA_MAN';

--4.Generate a dynamic report to search for specific first name value and display the employee 
--full name, job title, and full email address (email_ID@megacorp.com). The report should 
--accept the end user input for first name value in any format (Uppercase, Lowercase, Mix-case). 
--Rename the columns accordingly and format the report
select  concat(E.first_name ||' ', E.last_name) "Full Name", 
        E.JOB_ID "Job title",
        concat(E.EMAIL,'@MEGACORP.COM') "Email"
from EMPLOYEES E
where Lower(E.FIRST_NAME) = Lower('&first_n');
--where E.FIRST_NAME like '%&f%';

--5.Generate a report to display the minimum, maximum, mean, and standard deviation for the 
--salary attribute. Rename the column names accordingly.  Also round both average and 
--standard deviation columns to two decimal places.
SELECT Round(AVG(salary),2),  Round(MAX(salary),2),
       Round(MIN(salary),2),  Round(SUM(salary),2), Round(STDDEV(SALARY),2)
FROM EMPLOYEES;

--6. Generate a report to display a unique list of job titles from the employees table with number 
--of employees for each job title. Sort the output by the number of employees in each job from 
--highest to lowest.

select job_id "Job title", count(job_id) "Number of staff"
from EMPLOYEES
group by job_id
order by count(job_id) desc;

--7. Modify the report in question 5 to display the minimum, maximum,  average, and standard 
--deviation  of  salary for all employees in department 80. Round both average and standard 
--deviation columns to two decimal places.

SELECT Round(AVG(salary),2),  Round(MAX(salary),2),
       Round(MIN(salary),2),  Round(SUM(salary),2), Round(STDDEV(SALARY),2)
FROM EMPLOYEES
where DEPARTMENT_ID=80;

--8-  Generate a report to calculate the average salary in each department (i.e. department 
--name). The average salary must be rounded to 2 digits numbers according to the following 
--format. Sort the output by the average salary values in descending order.

SELECT  D.DEPARTMENT_ID "Department No", D.DEPARTMENT_NAME "Department Name", Round(AVG(E.salary),2) "Average Salary"
FROM EMPLOYEES E, DEPARTMENTS D
where E.DEPARTMENT_ID = D.DEPARTMENT_ID
group by D.DEPARTMENT_ID, D.DEPARTMENT_NAME
order by Max(E.salary) desc;

--9-  Modify the previous report to display the average salary in each department but only for 
--departments who have average salary more than 6000.

SELECT  D.DEPARTMENT_ID "Department No", D.DEPARTMENT_NAME "Department Name", Round(AVG(E.salary),2) "Average Salary"
FROM EMPLOYEES E, DEPARTMENTS D
where E.DEPARTMENT_ID = D.DEPARTMENT_ID
group by D.DEPARTMENT_ID, D.DEPARTMENT_NAME
having AVG(E.salary) > 6000
order by Max(E.salary) desc;

--10-  Generate a report to display staff full name, job title, department name, start date, end date 
--and the number of months spent in that position. Rename the columns accordingly and  format 
--the report as following.
--Note:  some employees may used to work in a different department from their current one. 
--The query MUST display the department name and job title for that employee during the time 
--period in the job history table.

select E.first_name ||' '|| E.last_name "Full Name", J.JOB_TITLE "Job Title", D.DEPARTMENT_NAME,
       JH.START_DATE, JH.END_DATE,
       Round(MONTHS_BETWEEN(JH.END_DATE,JH.START_DATE),0) "Months in position"  --Number of months between two dates
from EMPLOYEES E, DEPARTMENTS D, JOBS J, JOB_HISTORY JH
where E.DEPARTMENT_ID = D.DEPARTMENT_ID 
and E.EMPLOYEE_ID = JH.EMPLOYEE_ID
and JH.JOB_ID = J.JOB_ID --- chú ý ch? này, bc we must find JOB_ID of JOB_HISTORY table related to JOB table
order by E.EMPLOYEE_ID, JH.START_DATE;
