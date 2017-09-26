--Creat a star-schema.
--Firstly, create dimension tables
DROP TABLE Product_Dimension;
DROP TABLE Store_Dimension;
DROP TABLE Customer_Dimension;
DROP TABLE Supplier_Dimension;
DROP TABLE Sales_Fact;


CREATE TABLE Dimension_Product
  (
    PRODUCT_ID      VARCHAR2(6),
    PRODUCT_NAME    VARCHAR2(30) NOT NULL,
    CONSTRAINT product_pk PRIMARY KEY (PRODUCT_ID)
  );
  
CREATE TABLE Dimension_Store
  (
    STORE_ID      VARCHAR2(4),
    STORE_NAME    VARCHAR2(20) NOT NULL,
    CONSTRAINT store_pk PRIMARY KEY (STORE_ID)
  );
  
CREATE TABLE Dimension_Customer
  (
    CUSTOMER_ID      VARCHAR2(4),
    CUSTOMER_NAME    VARCHAR2(30) NOT NULL,
    CONSTRAINT customer_pk PRIMARY KEY (CUSTOMER_ID)
  );

CREATE TABLE Dimension_Supplier
  (
    SUPPLIER_ID      VARCHAR2(5),
    SUPPLIER_NAME    VARCHAR2(30) NOT NULL,
    CONSTRAINT supplier_pk PRIMARY KEY (SUPPLIER_ID)
  );
  
CREATE TABLE Fact_Sales
  (
    CUSTOMER_ID   VARCHAR2(4),
    STORE_ID      VARCHAR2(4),
    SUPPLIER_ID   VARCHAR2(5), 
    PRODUCT_ID    VARCHAR2(6),
	TOTAL_SALE	  NUMBER(5,2),
	T_DATE		  DATE,
    Price   NUMBER(5,2),
    
    CONSTRAINT Sales_Customer_fk FOREIGN KEY (CUSTOMER_ID) REFERENCES Customer_Dimension (CUSTOMER_ID),
    CONSTRAINT Sales_Store_fk FOREIGN KEY (STORE_ID) REFERENCES Store_Dimension (STORE_ID),
    CONSTRAINT Sales_Supplier_fk FOREIGN KEY (SUPPLIER_ID) REFERENCES Supplier_Dimension (SUPPLIER_ID),
    CONSTRAINT Sales_Product_fk FOREIGN KEY (PRODUCT_ID) REFERENCES Product_Dimension (PRODUCT_ID)
  );
-----------Implementation of INLJ
--Read 50 tuples from TRANSACTIONS table as input data into a cursor. The cursor is a user
--defined data type in PLSQL which works as a list and is used to store multiple records in
--memory for processing.

  
DECLARE
  CURSOR CUR_50TRANSACTION
  IS 
    SELECT TR.TRANSACTION_ID,
           TR.PRODUCT_ID,
           TR.CUSTOMER_ID,
           TR.CUSTOMER_NAME,
           TR.STORE_ID,
           TR.STORE_NAME,
           TR.T_DATE,
           TR.QUANTITY
    FROM TRANSACTIONS TR 
    ORDER BY TR.TRANSACTION_ID
    FETCH FIRST 50 ROWS ONLY;
  ROWS_TRANSACTION CUR_50TRANSACTION%ROWTYPE;
BEGIN 
  IF  CUR_50TRANSACTION%ISOPEN THEN
      DBMS_OUTPUT.PUT_LINE('Cursor opened');
  ELSE
      DBMS_OUTPUT.PUT_LINE('Cursor not open');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Opening cursor...');  
  OPEN CUR_50TRANSACTION;
  LOOP
    --Get rows data from Cursor
    --Each Fetch jumps on a line
    FETCH CUR_50TRANSACTION INTO ROWS_TRANSACTION;
    EXIT WHEN  CUR_50TRANSACTION%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(' - Transaction ID: ' || ROWS_TRANSACTION.TRANSACTION_ID || ' - Product ID: ' || ROWS_TRANSACTION. PRODUCT_ID);
  END LOOP;
   DBMS_OUTPUT.PUT_LINE('Closing cursor...');

   CLOSE CUR_50TRANSACTION;
END;
/  



CREATE OR REPLACE PROCEDURE SP_READ50TRANSACTION 
IS
  CURSOR CUR_50TRANSACTION
  IS 
    SELECT TR.TRANSACTION_ID,
           TR.PRODUCT_ID,
           TR.CUSTOMER_ID,
           TR.CUSTOMER_NAME,
           TR.STORE_ID,
           TR.STORE_NAME,
           TR.T_DATE,
           TR.QUANTITY
    FROM TRANSACTIONS TR 
    ORDER BY TR.TRANSACTION_ID
    FETCH FIRST 50 ROWS ONLY;
  ROWS_TRANSACTION CUR_50TRANSACTION%ROWTYPE;
BEGIN
  IF  CUR_50TRANSACTION%ISOPEN THEN
      DBMS_OUTPUT.PUT_LINE('Cursor opened');
  ELSE
      DBMS_OUTPUT.PUT_LINE('Cursor not open');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Opening cursor...');  
  OPEN CUR_50TRANSACTION;
  LOOP
    --Get rows data from Cursor
    --Each Fetch jumps on a line
	--(Up to down).
    FETCH CUR_50TRANSACTION INTO ROWS_TRANSACTION;
    EXIT WHEN  CUR_50TRANSACTION%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(' - Transaction ID: ' || ROWS_TRANSACTION.TRANSACTION_ID 
                      || ' - Product ID: ' || ROWS_TRANSACTION.PRODUCT_ID
                      || ' - CUSTOMER_ID: ' || ROWS_TRANSACTION.CUSTOMER_ID
                      || ' - STORE_ID: ' || ROWS_TRANSACTION.STORE_ID
                      || ' - STORE_NAME: ' || ROWS_TRANSACTION.STORE_NAME
                      || ' - T_DATE: ' || ROWS_TRANSACTION.T_DATE 
                      || ' - QUANTITY: ' || ROWS_TRANSACTION.QUANTITY
                        );
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Closing cursor...');

  CLOSE CUR_50TRANSACTION;
END;

--2.Read the cursor tuple by tuple and for each tuple retrieve the relevant tuple from
--MASTERDATA table using PRODUCT_ID as an index and add the required attributes
--(mentioned in Figure 2) into the transaction tuple (in memory).

CREATE OR REPLACE PROCEDURE SP_READ_CURSORTUPLE
IS
  CURSOR CUR_50TRANSACTION
  IS
    SELECT TR.TRANSACTION_ID,
      TR.PRODUCT_ID,
      TR.CUSTOMER_ID,
      TR.CUSTOMER_NAME,
      TR.STORE_ID,
      TR.STORE_NAME,
      TR.T_DATE,
      TR.QUANTITY
    FROM TRANSACTIONS TR
    ORDER BY TR.TRANSACTION_ID
  FETCH FIRST 50 ROWS ONLY;
  
  CURSOR CUR_50RetrieveFromMaster (par_ProductID VARCHAR2)
  IS
    SELECT  MS.PRODUCT_NAME,
      MS.SUPPLIER_ID,
      MS.SUPPLIER_NAME,
      MS.PRICE
    FROM MASTERDATA MS
    WHERE MS.PRODUCT_ID = par_ProductID
    ORDER BY MS.PRODUCT_ID;
    
  ROWS_TRANSACTION CUR_50TRANSACTION%ROWTYPE; --variable
  ROWS_MASTERDATA CUR_50RetrieveFromMaster%ROWTYPE;
  var_total_sale NUMBER (10,2);
BEGIN
  IF CUR_50TRANSACTION%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('Cursor opened');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Cursor not open');
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('Opening cursor...');
  OPEN CUR_50TRANSACTION;
  LOOP
    --Get rows data from Cursor
    --Each Fetch jumps on a line
    FETCH CUR_50TRANSACTION
    INTO ROWS_TRANSACTION;
    EXIT WHEN CUR_50TRANSACTION%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('TRANSACTIONS CURSOR- Transaction ID: ' || ROWS_TRANSACTION.TRANSACTION_ID 
                                  || ' - PRODUCT_ID: ' || ROWS_TRANSACTION.PRODUCT_ID
                         );
    var_total_sale := 0;
    OPEN CUR_50RetrieveFromMaster(ROWS_TRANSACTION.PRODUCT_ID);
    LOOP
      FETCH CUR_50RetrieveFromMaster INTO ROWS_MASTERDATA;
      EXIT WHEN CUR_50RetrieveFromMaster%NOTFOUND;
      var_total_sale := ROWS_MASTERDATA.PRICE * ROWS_TRANSACTION.QUANTITY;
      DBMS_OUTPUT.PUT_LINE ( 'Transaction tuple  - PRODUCT_ID: ' || ROWS_TRANSACTION.PRODUCT_ID 
											|| ' - CUSTOMER_ID: ' || ROWS_TRANSACTION.CUSTOMER_ID
											|| ' - CUSTOMER_NAME: ' || ROWS_TRANSACTION.CUSTOMER_NAME
											|| ' - STORE_ID: ' || ROWS_TRANSACTION.STORE_ID
											|| ' - STORE_NAME: ' || ROWS_TRANSACTION.STORE_NAME
											|| ' - T_DATE: ' || ROWS_TRANSACTION.T_DATE 
											|| ' - QUANTITY: ' || ROWS_TRANSACTION.QUANTITY
											|| ' - PRODUCT_NAME: ' || ROWS_MASTERDATA.PRODUCT_NAME
											|| ' - SUPPLIER_ID: ' || ROWS_MASTERDATA.SUPPLIER_ID
											|| ' - SUPPLIER_NAME: ' || ROWS_MASTERDATA.SUPPLIER_NAME
											|| ' - PRICE: ' || ROWS_MASTERDATA.PRICE
											|| ' TOTAL_SALE: ' || var_total_sale);
    END LOOP;
    CLOSE CUR_50RetrieveFromMaster;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Closing cursor...');
  CLOSE CUR_50TRANSACTION;
 
END;


