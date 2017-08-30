SELECT e.first_name ||' '|| e.last_name "FULL NAME" ,
       j.job_title "JOB TITLE",
       e.salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.salary >= 10000;

SELECT e.first_name ||' '|| e.last_name "FULL NAME" ,
       j.job_title "JOB TITLE",
       e.salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
WHERE e.salary between 5000 and 12000;

SELECT e.first_name ||' '|| e.last_name "FULL NAME" ,
       j.job_title "JOB TITLE" ,
       e.hire_date "START WORKING DAY"
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
where e.last_name in ('Hutton','Austin')
order by e.hire_date;

select l.street_address,
       l.postal_code,
       l.city
from locations l
join countries c on l.country_id=c.country_id
where c.country_name in ('Italy','Japan');


--Create a report to show staff  full names  in addition to contact details (email, phone 
--numbers) for all employees who were hired in January 1996. 
select sysdate from dual; /* show date of system  DD-MM-YYYY*/
select  e.first_name ||' '|| e.last_name "Full Name",
        'Phone: '||e.phone_number ||'  Email: '|| e.email "Contact Details",
        e.hire_date
from employees e
where e.hire_date between TO_DATE('01-01-1996','dd-MM-yyyy') and TO_DATE('31-01-1996','dd-MM-yyyy')
order by e.last_name;

select  e.first_name ||' '|| e.last_name "Full Name",
        'Phone: '||e.phone_number ||'  Email: '|| e.email "Contact Details",
        e.hire_date
from employees e
where e.hire_date like '%96'
order by e.last_name;

/*sysdate returns the current date and time set for the operating system on which the database resides
e.g. SELECT TO_CHAR
    (SYSDATE, 'MM-DD-YYYY HH24:MI:SS') "NOW"
     FROM DUAL;
     
     NOW
-------------------
04-13-2001 09:45:51

DUAL is in the schema of the user SYS but is accessible by the name DUAL to all users
*/

select  e.first_name ||' '|| e.last_name "Full Name",
        'Phone: '||e.phone_number ||'  Email: '|| e.email "Contact Details",
        e.hire_date
from employees e
where e.hire_date > TO_DATE('01-12-1999','dd-MM-yyyy')
order by e.HIRE_DATE desc;

/*
Yes: TIME_CREATED contains a date and a time. Use TRUNC to strip the time:

SELECT EMP_NAME, DEPT
FROM EMPLOYEE
WHERE TRUNC(TIME_CREATED) = TO_DATE('26/JAN/2011','dd/mon/yyyy')
UPDATE:
As Dave Costa points out in the comment below, this will prevent Oracle from using the index of the column TIME_CREATED if it exists. An alternative approach without this problem is this:

SELECT EMP_NAME, DEPT
FROM EMPLOYEE
WHERE TIME_CREATED >= TO_DATE('26/JAN/2011','dd/mon/yyyy') 
      AND TIME_CREATED < TO_DATE('26/JAN/2011','dd/mon/yyyy') + 1

*/

--List all staff members  who're  their  first name starts with the letter (S) and  ends  with the letter (n)?
select  e.first_name ||' '|| e.last_name "Full Name",
        'Phone: '||e.phone_number ||'  Email: '|| e.email "Contact Details",
        e.hire_date
from employees e
where (e.FIRST_NAME like 'S%n');
--distinguish upper and lowercase 'S%n'


select  e.first_name ||' '|| e.last_name "Full Name",
        'Phone: '||e.phone_number ||'  Email: '|| e.email "Contact Details",
        e.hire_date
from employees e
where REGEXP_LIKE(e.FIRST_NAME, '^S.*n$');

--List the employees who hold the following job titles (AC_MGR, AD_VP, FI_MGR, HR_REP, PR_REP)?
select e.employee_id "Emp#", 
       e.first_name ||' '|| e.last_name "Full Name", 
       j.job_title "Job Title",
       e.department_id "Department ID"
from employees e
join jobs j on e.job_id = j.job_id
where j.JOB_ID in ('AC_MGR', 'AD_VP', 'FI_MGR','HR_REP', 'PR_REP');

--Modify the  previous report to list the employees who do not hold the following job titles (AC_MGR, AD_VP, FI_MGR, HR_REP, PR_REP)
select e.employee_id "Emp#", 
       e.first_name ||' '|| e.last_name "Full Name", 
       j.job_title "Job Title",
       e.department_id "Department ID"
from employees e
join jobs j on e.job_id = j.job_id
where j.JOB_ID not in ('AC_MGR', 'AD_VP', 'FI_MGR','HR_REP', 'PR_REP');

-- The HR department wants to run reports based on a  specific  manager. Create a  dynamic 
--report  that prompts the user for a manager ID and generates the employee ID, last name, 
--salary, and department for that manager’s employees.
select e.employee_id "Emp#", 
       e.first_name ||' '|| e.last_name "Full Name", 
       j.job_title "Job Title",
       e.department_id "Department ID",
       d.department_name
from employees e
join jobs j on e.job_id = j.job_id
join departments d on e.department_id = d.department_id
where e.MANAGER_ID = '&MANAGER_ID';

---------------------------------------Hotel---------------------------------
--List full details for all rooms with a price above $40 in ascending order by room type and price
select r.roomno , r.price , r.type
from room r 
where r.PRICE > '40'
order by r.TYPE,r.price;

--List the names and  full addresses of all guests  who live in AUT accommodation at “8 Mount St.”
select g.guestname "Full Name", 
       g.guestaddress "Address of Guest", 
       g.guestcity "Living Location",
       h.hotelname "Hotel Booking"
from guest g 
join booking b on b.guestno = g.guestno
join hotel h on b.hotelno = h.hotelno
where g.GUESTADDRESS like '%8 Mount St.%';