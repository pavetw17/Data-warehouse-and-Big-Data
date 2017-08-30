--Taks 1  --1.
select H.HOTELNAME "HOTEL NAME", R.TYPE "TYPE",R.PRICE 
from HOTEL H, ROOM R
where H.HOTELNO = R.HOTELNO;

--2.
select G.GUESTNAME, H.HOTELNAME, TO_CHAR(B.DATEFROM,'dd/mm/yyyy') "DATEFROM", TO_CHAR(B.DATETO,'dd/mm/yyyy') "DATETO"
from HOTEL H, BOOKING B ,GUEST G
where H.HOTELNO = B.HOTELNO and B.GUESTNO=G.GUESTNO;

--Task2 --1 Generate a report to display staff full names, jobs and department names.  Rename the 
--column headings to “Full Name”, “Job Title”, and “Department Name”  as shown below. 
--Order the report alphabetically by last name.

select E.first_name ||' '|| E.last_name "Full Name", E.JOB_ID "Job Title", D.DEPARTMENT_NAME
from EMPLOYEES E, DEPARTMENTS D
where E.DEPARTMENT_ID = D.DEPARTMENT_ID
order by E.last_name;

--2. Generate a report to display staff full names, email (email  ID@MEGACORP.COM), 
--department name, and office address  (city and country). Sort the output by last name. 
--Rename the columns accordingly and format the report as following

select  E.first_name ||' '|| E.last_name "Full Name", E.EMAIL || '@MEGACORP.COM', 
        D.DEPARTMENT_NAME, L.CITY ||', '|| C.COUNTRY_NAME "LOCATION"
from EMPLOYEES E, DEPARTMENTS D, LOCATIONS L, COUNTRIES C
where E.DEPARTMENT_ID = D.DEPARTMENT_ID
and D.LOCATION_ID = L.LOCATION_ID
and L.COUNTRY_ID = C.COUNTRY_ID
order by E.last_name;

--3 Modify the previous question to generate a dynamic report that display the staff details 
--for a specific country only. The report must ask  the end user to enter a country name. Run 
--the report for Germany and New Zealand. Explain this report output and highlight possible 
--format improvement(s)
select  E.first_name ||' '|| E.last_name "Full Name", E.EMAIL || '@MEGACORP.COM', 
        D.DEPARTMENT_NAME, L.CITY ||', '|| C.COUNTRY_NAME "LOCATION"
from EMPLOYEES E, DEPARTMENTS D, LOCATIONS L, COUNTRIES C
where E.DEPARTMENT_ID = D.DEPARTMENT_ID
and D.LOCATION_ID = L.LOCATION_ID
and L.COUNTRY_ID = C.COUNTRY_ID
and C.COUNTRY_NAME = '&COUNTRY_NAME'
order by E.last_name;

--4 Generate a report to display staff full name, job title, department name, start date and 
--end date  for  each employee  position given in the  job history table.  Sort the report by 
--employee id and then by start date.  Rename the columns accordingly and  format the 
--report as following.
select E.first_name ||' '|| E.last_name "Full Name", J.JOB_TITLE "Job Title", D.DEPARTMENT_NAME,
       JH.START_DATE, JH.END_DATE
from EMPLOYEES E, DEPARTMENTS D, JOBS J, JOB_HISTORY JH
where E.DEPARTMENT_ID = D.DEPARTMENT_ID 
and E.EMPLOYEE_ID = JH.EMPLOYEE_ID
and JH.JOB_ID = J.JOB_ID --- chú ý ch? này, bc we must find JOB_ID of JOB_HISTORY table related to JOB table
order by E.EMPLOYEE_ID, JH.START_DATE;

--5. Generate a report to display staff full names, and department names. The report must 
--also include all departments that currently DO NOT have any staff assigned to it
-- (+) tuong duong voi cot co NULL
select E.first_name ||' '|| E.last_name "Full Name", D.DEPARTMENT_NAME
from EMPLOYEES E, DEPARTMENTS D
where E.DEPARTMENT_ID(+) = D.DEPARTMENT_ID;

--6 Generate a report to display the employee name and employee number along with their 
--manager’s name and manager number. Label the columns Employee, Emp#, Manager, 
--and Mgr#, respectively. Format the report according to the following.
select E.first_name ||' '|| E.last_name "Employee Name", E.EMPLOYEE_ID "EMP #", 
       M.first_name ||' '|| M.last_name "Manager Name" , E.MANAGER_ID "MANAGER #"
from EMPLOYEES E JOIN EMPLOYEES M
on E.MANAGER_ID = M.EMPLOYEE_ID;

--7. The staff member “Steven King” does not have a manager. He is the CEO. Modify 
--question 6 to include “Steven King” in the report.
select E.first_name ||' '|| E.last_name "Employee Name", E.EMPLOYEE_ID "EMP #", 
       M.first_name ||' '|| M.last_name "Manager Name" , E.MANAGER_ID "MANAGER #"
from EMPLOYEES E JOIN EMPLOYEES M
on E.MANAGER_ID = M.EMPLOYEE_ID(+);

--8.Generate a report to display staff full name, job title and salary of all employees who 
--earn more than the average salary.
select E.first_name ||' '|| E.last_name "Full Name", J.JOB_TITLE, E.SALARY
from EMPLOYEES E, JOBS J
where E.JOB_ID = J.JOB_ID
and E.SALARY > ( select AVG(SALARY) from EMPLOYEES );