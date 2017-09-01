--Task 1: 1.Create a table name student with the following attributes
CREATE TABLE student
  (
    student_no      NUMBER(4) PRIMARY KEY,
    student_name    VARCHAR2(20) NOT NULL,
    student_address VARCHAR2(50)
    --CONSTRAINT student_StudentNo_pk PRIMARY KEY (student_no)
  );

DESCRIBE STUDENT;
DROP TABLE STUDENT;

--Query constraint table to view all constraints
SELECT constraint_name
FROM SYS.USER_CONSTRAINTS
WHERE lower(table_name) = 'grade';

---Drop constraint
ALTER TABLE student
DROP CONSTRAINT student_StudentNo_pk;

--Add constraint
ALTER TABLE student 
ADD CONSTRAINT student_StudentNo_pk PRIMARY KEY (student_no);

--Modify constraint
ALTER TABLE student 
MODIFY( 
student_name VARCHAR2(20) NOT NULL
--student_address VARCHAR2(50) NULL
);



--2.Create a table name course with the following attributes
CREATE TABLE course
  (
    course_no      NUMBER(2),
    course_name    VARCHAR2(20) NOT NULL,
    course_address VARCHAR2(50),
    CONSTRAINT course_CourseNo_pk PRIMARY KEY (course_no)
  );

DESCRIBE course;

SELECT constraint_name
FROM SYS.USER_CONSTRAINTS
WHERE lower(table_name) = 'course';


--3. Note that "grade" table contain a composite primary key of (student_no, course_no). However, each
--of these attributes “individually” is a foreign key
CREATE TABLE grade
  (
    student_no NUMBER(4),
    course_no  NUMBER(2),
    grade      NUMBER(3) NOT NULL,
    CONSTRAINT grade_StudentNo_CourseNO_PK PRIMARY KEY (student_no,course_no),
    CONSTRAINT grade_studentno_fk FOREIGN KEY (student_no) REFERENCES student (student_no),
    CONSTRAINT grade_courseno_fk FOREIGN KEY (course_no) REFERENCES course (course_no)
  );
DESCRIBE grade;


--4-Identify the relationship type (1:1, 1:M, M:N) among the three tables above and create the
--necessary constraints to join them.
-- One-One Relationship (1-1 Relationship)
-- One-Many Relationship (1-M Relationship)
-- Many-Many Relationship (M-M Relationship)
--1:1 Student with grade
-- A student can receive a grade for a course
--1:1 Course with grade
-- A course can have a grade for a student
--M:N Student with Course
--A student can have several courses
--A Course  can have many students
--1:M Course with student
--A course can have many students
--1:M Student with Course
--A student can study many course.



--Task 2
--Map the given conceptual model into internal model using CREATE and ALTER commands.
--Apply all foreign keys using ALTER command.
CREATE TABLE store_information
  (
    store_id         VARCHAR2(3),
    store_name       VARCHAR2(20) NOT NULL,
    street_name      VARCHAR2(20),
    city             VARCHAR2(20),
    zip_code         VARCHAR2(20),
    phone_nbr        VARCHAR2(20),
    manager_name     VARCHAR2(20),
    open_sunday_flag CHAR(1) NOT NULL,
    CONSTRAINT store_information_PK PRIMARY KEY (store_id)
  );

describe store_information;

SELECT constraint_name
FROM SYS.USER_CONSTRAINTS
WHERE lower(table_name) = 'item_scan';


CREATE TABLE category
  (
    category_id      VARCHAR2(2) ,
    category_name    VARCHAR2(20) ,
    category_details VARCHAR2(100) ,
    CONSTRAINT category_id PRIMARY KEY (category_id)
  );
CREATE TABLE store_visit
  (
    visit_id           VARCHAR2(6) ,
    store_id           VARCHAR2(3) NOT NULL,
    membership_id      VARCHAR2(6) NOT NULL,
    transaction_date   DATE,
    tot_unique_itm_cnt NUMBER(2),
    tot_visit_amt      NUMBER(5,3),
    CONSTRAINT store_visit_PK PRIMARY KEY (visit_id)
  );
CREATE TABLE item_scan
  (
    visit_id        VARCHAR2(6) ,
    item_id         VARCHAR2(6),
    quantity        NUMBER(2) ,
    unit_cost       NUMBER(5,3),
    unit_total_cost NUMBER(5,3),
    CONSTRAINT item_scan_PK PRIMARY KEY (visit_id,item_id)
  );
CREATE TABLE item_desc
  (
    item_id         VARCHAR2(6) ,
    category_id     VARCHAR2(2) NOT NULL,
    primary_desc    VARCHAR2(50) ,
    secondary_desc  VARCHAR2(50),
    color_desc      VARCHAR2(10),
    size_desc       VARCHAR2(10),
    status_code     CHAR(1) NOT NULL,
    production_date DATE,
    expiry_date     DATE,
    brand_name      VARCHAR2(20),
    CONSTRAINT item_desc_PK PRIMARY KEY (item_id)
  );
CREATE TABLE members_index
  (
    membership_id VARCHAR2(6),
    customer_name VARCHAR(20),
    address       VARCHAR2(50),
    member_type   VARCHAR2(10) NOT NULL,
    join_date     DATE NOT NULL,
    member_status CHAR(1),
    member_points NUMBER(3),
    CONSTRAINT members_index_PK PRIMARY KEY (membership_id)
  );

ALTER TABLE store_visit 
ADD ( 
  CONSTRAINT table_9_store_information_fk FOREIGN KEY (store_id) REFERENCES store_information (store_id),
  CONSTRAINT table_9_members_index_FK FOREIGN KEY (membership_id) REFERENCES members_index (membership_id)
);

SELECT constraint_name
FROM SYS.USER_CONSTRAINTS
WHERE lower(table_name) = 'store_visit';

ALTER TABLE item_scan 
ADD ( 
  CONSTRAINT item_scan_item_desc_FK FOREIGN KEY (item_id) REFERENCES item_desc (item_id),
  CONSTRAINT item_scan_store_visit_FK FOREIGN KEY (visit_id) REFERENCES store_visit (visit_id)
);

ALTER TABLE item_desc 
ADD ( 
  CONSTRAINT item_desc_category_FK FOREIGN KEY (category_id) REFERENCES category (category_id)
);

