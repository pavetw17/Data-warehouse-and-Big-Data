describe locations

describe employees
select e.employee_id "Emp#", 
       e.first_name ||' '|| e.last_name "Full Name", 
       j.job_title "Job Title",
       e.department_id "Department ID"
from employees e
join jobs j on e.job_id = j.job_id
order by e.first_name

select distinct j.job_title
from employees e
join jobs j on e.job_id = j.job_id

select  e.first_name ||' '|| e.last_name "Full Name",
        'Phone: '||e.phone_number ||'  Email: '|| e.email "Contact Details"
from employees e

---------------------------------------Hotel---------------------------------
select h.hotelname, h.city
from hotel h

select g.guestname "Full Name", 
       g.guestaddress "Address of Guest", 
       g.guestcity "Living Location",
       h.hotelname "Hotel Booking"
from guest g 
join booking b on b.guestno = g.guestno
join hotel h on b.hotelno = h.hotelno

select r.roomno , r.price , r.type
from room r 
where r.type ='S'

select g.guestname "Full Name", g.guestaddress "Address of Guest"
from guest g
where g.guestcity = 'London'

select h.hotelname "Hotel"
from booking b
join hotel h on h.hotelno = b.hotelno
where b.dateto is null


