--Creat a star-schema.
--Firstly, create dimension tables
DROP TABLE Fact_Sales;
DROP TABLE Dimension_Product;
DROP TABLE Dimension_Store;
DROP TABLE Dimension_Customer;
DROP TABLE Dimension_Supplier;

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
    Price   NUMBER(5,2) default 0.0,
    
    CONSTRAINT Sales_Customer_fk FOREIGN KEY (CUSTOMER_ID) REFERENCES Dimension_Customer (CUSTOMER_ID),
    CONSTRAINT Sales_Store_fk FOREIGN KEY (STORE_ID) REFERENCES Dimension_Store (STORE_ID),
    CONSTRAINT Sales_Supplier_fk FOREIGN KEY (SUPPLIER_ID) REFERENCES Dimension_Supplier (SUPPLIER_ID),
    CONSTRAINT Sales_Product_fk FOREIGN KEY (PRODUCT_ID) REFERENCES Dimension_Product (PRODUCT_ID)
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
  CLOSE CUR_50TRANSACTION;
  DBMS_OUTPUT.PUT_LINE('Closing cursor...');

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
  CLOSE CUR_50TRANSACTION;
  DBMS_OUTPUT.PUT_LINE('Closing cursor...');
  
END;

--3. The transaction tuple with new attributes is to be loaded into DW. Before loading the tuple
--into DW you will check whether the dimension tables already contain this information. If
--yes, then only update the fact table otherwise update the required dimension tables and
--the fact table

--- OPEN FILE Week8_insertAndUpdate.sql 



--CREATE OR REPLACE PROCEDURE SP_READ_CURSORTUPLE
--IS
--  CURSOR CUR_50TRANSACTION
--  IS
--    SELECT TR.TRANSACTION_ID,
--      TR.PRODUCT_ID,
--      TR.CUSTOMER_ID,
--      TR.CUSTOMER_NAME,
--      TR.STORE_ID,
--      TR.STORE_NAME,
--      TR.T_DATE,
--      TR.QUANTITY
--    FROM TRANSACTIONS TR
--    ORDER BY TR.TRANSACTION_ID
--  FETCH FIRST 50 ROWS ONLY;
--  
--  CURSOR CUR_50RetrieveFromMaster (par_ProductID VARCHAR2)
--  IS
--    SELECT  MS.PRODUCT_NAME,
--      MS.SUPPLIER_ID,
--      MS.SUPPLIER_NAME,
--      MS.PRICE
--    FROM MASTERDATA MS
--    WHERE MS.PRODUCT_ID = par_ProductID
--    ORDER BY MS.PRODUCT_ID;
--    
--  ROWS_TRANSACTION CUR_50TRANSACTION%ROWTYPE; --variable rowtype
--  ROWS_MASTERDATA CUR_50RetrieveFromMaster%ROWTYPE;
--  var_total_sale NUMBER (10,2);
--  type dimensionTableArray IS VARRAY(4) OF VARCHAR2(30);
--  v_dimensionTableArray dimensionTableArray;
--  
--  type schemaTableArray IS VARRAY(4) OF VARCHAR2(30);
--  v_schemaTableArray  schemaTableArray;
--  
--  type valueTransactionArrayID IS VARRAY(4) OF VARCHAR2(30);
--  v_valueTransactionArrayID valueTransactionArrayID;
--  
--  type valueTransactionArrayNAME IS VARRAY(4) OF VARCHAR2(30);
--  v_valueTransactionArrayNAME valueTransactionArrayNAME;
--  
--  COUNT_INSERTROWS NUMBER; --count total of rows to commit (Insert into tables)
--  v_checkExists NUMBER(1);
--  v_strColumnName VARCHAR2(20);
--  
--BEGIN
--  IF CUR_50TRANSACTION%ISOPEN THEN
--    DBMS_OUTPUT.PUT_LINE('Cursor opened');
--  ELSE
--    DBMS_OUTPUT.PUT_LINE('Cursor not open');
--  END IF;
--  
--  DBMS_OUTPUT.PUT_LINE('Opening cursor...');
--  
--  OPEN CUR_50TRANSACTION;
--  COUNT_INSERTROWS:=0;
--  v_dimensionTableArray:= dimensionTableArray('Dimension_Product', 'Dimension_Store', 'Dimension_Customer','Dimension_Supplier');
--  v_schemaTableArray:= schemaTableArray('PRODUCT_ID', 'STORE_ID', 'CUSTOMER_ID','SUPPLIER_ID');
--  
--  LOOP
--    --Get rows data from Cursor
--    --Each Fetch jumps on a line
--    FETCH CUR_50TRANSACTION
--    INTO ROWS_TRANSACTION;
--    EXIT WHEN CUR_50TRANSACTION%NOTFOUND;
--    DBMS_OUTPUT.PUT_LINE('TRANSACTIONS CURSOR- Transaction ID: ' || ROWS_TRANSACTION.TRANSACTION_ID 
--                                  || ' - PRODUCT_ID: ' || ROWS_TRANSACTION.PRODUCT_ID);
--    var_total_sale := 0;
--    OPEN CUR_50RetrieveFromMaster(ROWS_TRANSACTION.PRODUCT_ID);
--    LOOP
--		FETCH CUR_50RetrieveFromMaster INTO ROWS_MASTERDATA;
--		EXIT WHEN CUR_50RetrieveFromMaster%NOTFOUND;
--		var_total_sale := ROWS_MASTERDATA.PRICE * ROWS_TRANSACTION.QUANTITY;
--		DBMS_OUTPUT.PUT_LINE ( 'Transaction tuple  - PRODUCT_ID: ' || ROWS_TRANSACTION.PRODUCT_ID 
--											|| ' - CUSTOMER_ID: ' || ROWS_TRANSACTION.CUSTOMER_ID
--											|| ' - CUSTOMER_NAME: ' || ROWS_TRANSACTION.CUSTOMER_NAME
--											|| ' - STORE_ID: ' || ROWS_TRANSACTION.STORE_ID
--											|| ' - STORE_NAME: ' || ROWS_TRANSACTION.STORE_NAME
--											|| ' - T_DATE: ' || ROWS_TRANSACTION.T_DATE 
--											|| ' - QUANTITY: ' || ROWS_TRANSACTION.QUANTITY
--											|| ' - PRODUCT_NAME: ' || ROWS_MASTERDATA.PRODUCT_NAME
--											|| ' - SUPPLIER_ID: ' || ROWS_MASTERDATA.SUPPLIER_ID
--											|| ' - SUPPLIER_NAME: ' || ROWS_MASTERDATA.SUPPLIER_NAME
--											|| ' - PRICE: ' || ROWS_MASTERDATA.PRICE
--											|| ' TOTAL_SALE: ' || var_total_sale);
--		
--		v_valueTransactionArrayID:= valueTransactionArrayID( ROWS_TRANSACTION.PRODUCT_ID , ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.CUSTOMER_ID,ROWS_MASTERDATA.SUPPLIER_ID);
--		v_valueTransactionArrayNAME:= valueTransactionArrayNAME( ROWS_MASTERDATA.PRODUCT_NAME , ROWS_TRANSACTION.STORE_NAME, ROWS_TRANSACTION.CUSTOMER_NAME,ROWS_MASTERDATA.SUPPLIER_NAME);
--		
--		FOR i in 1 .. v_dimensionTableArray.count LOOP
--			select 
--				case 
--					when exists(select count(*) from v_dimensionTableArray(i) where  v_schemaTableArray(i) = v_valueTransactionArray(i))
--					then 1  -- yes
--					else 0  -- no
--				end into v_checkExists
--			from DUAL;
--			DBMS_OUTPUT.PUT_LINE ('---------------' || v_checkExists );
--			
--			if v_checkExists = 1 then
--				update Fact_Sales set TOTAL_SALE = var_total_sale, 
--									  T_DATE = ROWS_TRANSACTION.T_DATE, 
--									  Price = ROWS_MASTERDATA.Price
--								  where CUSTOMER_ID = ROWS_TRANSACTION.CUSTOMER_ID AND
--									    STORE_ID  = ROWS_TRANSACTION.STORE_ID AND
--									    SUPPLIER_ID = ROWS_MASTERDATA.SUPPLIER_ID AND
--									    PRODUCT_ID = ROWS_TRANSACTION.PRODUCT_ID;
--
--				DBMS_OUTPUT.PUT_LINE ('/////////////' || ' 
--									update Fact_Sales set TOTAL_SALE =' || var_total_sale || ', 
--										T_DATE = ' || ROWS_TRANSACTION.T_DATE || ', 
--										Price = ' || ROWS_MASTERDATA.Price || '
--									where CUSTOMER_ID =' || ROWS_TRANSACTION.CUSTOMER_ID || 'AND
--									    STORE_ID  = ' || ROWS_TRANSACTION.STORE_ID || ' AND
--									    SUPPLIER_ID =' || ROWS_MASTERDATA.SUPPLIER_ID || ' AND
--									    PRODUCT_ID =' || ROWS_TRANSACTION.PRODUCT_ID  );						
--			else
--				SELECT LISTAGG (COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY COLUMN_ID) 
--				into v_strColumnName
--				FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = v_dimensionTableArray(i);
--				--FROM ALL_TAB_COLUMNS WHERE LOWER(TABLE_NAME) = LOWER(v_dimensionTableArray[i]);
--				
--				insert into v_dimensionTableArray(i) (v_strColumnName)
--				values (v_valueTransactionArrayID(i), v_valueTransactionArrayNAME(i));
--				
--				
--				DBMS_OUTPUT.PUT_LINE ('++++++++++' || ' 
--									insert into ' || v_dimensionTableArray(i)  || ' ( ' || v_strColumnName || ' ) values ( ' || v_valueTransactionArrayID(i) 
--                  || ', ' || v_valueTransactionArrayNAME(i) || ')');		
--										
--			
--				insert into Fact_Sales (PRODUCT_ID , STORE_ID, CUSTOMER_ID,SUPPLIER_ID,TOTAL_SALE,T_DATE,Price)
--				values ( ROWS_TRANSACTION.PRODUCT_ID , ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.CUSTOMER_ID,ROWS_MASTERDATA.SUPPLIER_ID,
--						 var_total_sale,ROWS_TRANSACTION.T_DATE,ROWS_MASTERDATA.PRICE );
--			end if;
--			   
--					
--		IF COUNT_INSERTROWS = 10 THEN
--			COUNT_INSERTROWS := 0;
--			COMMIT;
--		END IF;        
--		 
--		COUNT_INSERTROWS:= COUNT_INSERTROWS+1;
--		END LOOP;
--	  	
--						
--											
--    END LOOP;
--	CLOSE CUR_50RetrieveFromMaster;
--  END LOOP;
--  CLOSE CUR_50TRANSACTION;
--  DBMS_OUTPUT.PUT_LINE('Closing cursor...');
-- 
-- 
--END;
