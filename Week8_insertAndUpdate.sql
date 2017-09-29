--3. The transaction tuple with new attributes is to be loaded into DW. Before loading the tuple
--into DW you will check whether the dimension tables already contain this information. If
--yes, then only update the fact table otherwise update the required dimension tables and
--the fact table

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
    
  ROWS_TRANSACTION CUR_50TRANSACTION%ROWTYPE; --variable rowtype
  ROWS_MASTERDATA CUR_50RetrieveFromMaster%ROWTYPE;
  VAR_TOTAL_SALE NUMBER (10,2);
  type dimensionTableArray IS VARRAY(4) OF VARCHAR2(50);
  v_dimensionTableArray dimensionTableArray;
  
  type columnTableArray IS VARRAY(4) OF VARCHAR2(50);
  v_columnTableArray  columnTableArray;
  
  type valueTransactionArrayID IS VARRAY(4) OF VARCHAR2(50);
  v_valueTransactionArrayID valueTransactionArrayID;
  
--  type valueTransactionArrayNAME IS VARRAY(4) OF VARCHAR2(50);
--  v_valueTransactionArrayNAME valueTransactionArrayNAME;
  
  COUNT_INSERTROWS NUMBER; --count total of rows to commit (Insert into tables)
  COUNT_INSERTFACTTABLE  NUMBER; -- count to know inserting FACT_SALES avoid violated - parent key not found
  v_checkExists NUMBER;
  v_checkFactTableExists NUMBER;
  --v_strGetColumnName VARCHAR2(20); 
  
BEGIN
  IF CUR_50TRANSACTION%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('Cursor opened');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Cursor not open');
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('Opening cursor...'); -- using a lot of DBMS_OUTPUT.PUT_LINE causes   buffer overflow
  
  OPEN CUR_50TRANSACTION;
  COUNT_INSERTROWS:=0;
  COUNT_INSERTFACTTABLE:=0;
  v_dimensionTableArray:= dimensionTableArray('Dimension_Product', 'Dimension_Store', 'Dimension_Customer','Dimension_Supplier');
  v_columnTableArray:= columnTableArray('PRODUCT_ID', 'STORE_ID', 'CUSTOMER_ID','SUPPLIER_ID');
  
  LOOP
    --Get rows data from Cursor
    --Each Fetch jumps on a line
    FETCH CUR_50TRANSACTION
    INTO ROWS_TRANSACTION;
    EXIT WHEN CUR_50TRANSACTION%NOTFOUND;
--    DBMS_OUTPUT.PUT_LINE('TRANSACTIONS CURSOR   - TRANSACTION ID: ' || ROWS_TRANSACTION.TRANSACTION_ID 
--											||' - PRODUCT_ID: '     || ROWS_TRANSACTION.PRODUCT_ID);
    VAR_TOTAL_SALE := 0;
    OPEN CUR_50RetrieveFromMaster(ROWS_TRANSACTION.PRODUCT_ID);
    LOOP
		FETCH CUR_50RetrieveFromMaster INTO ROWS_MASTERDATA;
		EXIT WHEN CUR_50RetrieveFromMaster%NOTFOUND;
		VAR_TOTAL_SALE := ROWS_MASTERDATA.PRICE * ROWS_TRANSACTION.QUANTITY;
--		DBMS_OUTPUT.PUT_LINE ('Transaction tuple - PRODUCT_ID: ' 	|| ROWS_TRANSACTION.PRODUCT_ID 
--											|| ' - CUSTOMER_ID: ' 	|| ROWS_TRANSACTION.CUSTOMER_ID
--											|| ' - CUSTOMER_NAME: ' || ROWS_TRANSACTION.CUSTOMER_NAME
--											|| ' - STORE_ID: ' 		|| ROWS_TRANSACTION.STORE_ID
--											|| ' - STORE_NAME: ' 	|| ROWS_TRANSACTION.STORE_NAME
--											|| ' - T_DATE: ' 		|| ROWS_TRANSACTION.T_DATE 
--											|| ' - QUANTITY: ' 		|| ROWS_TRANSACTION.QUANTITY
--											|| ' - PRODUCT_NAME: ' 	|| ROWS_MASTERDATA.PRODUCT_NAME
--											|| ' - SUPPLIER_ID: ' 	|| ROWS_MASTERDATA.SUPPLIER_ID
--											|| ' - SUPPLIER_NAME: ' || ROWS_MASTERDATA.SUPPLIER_NAME
--											|| ' - PRICE: ' 		|| ROWS_MASTERDATA.PRICE
--											|| ' - TOTAL_SALE: ' 	|| VAR_TOTAL_SALE);
		
		v_valueTransactionArrayID:= valueTransactionArrayID( ROWS_TRANSACTION.PRODUCT_ID , ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.CUSTOMER_ID,ROWS_MASTERDATA.SUPPLIER_ID);
	--	v_valueTransactionArrayNAME:= valueTransactionArrayNAME( ROWS_MASTERDATA.PRODUCT_NAME , ROWS_TRANSACTION.STORE_NAME, ROWS_TRANSACTION.CUSTOMER_NAME,ROWS_MASTERDATA.SUPPLIER_NAME);
		
		FOR i in 1 .. v_dimensionTableArray.count LOOP
				execute immediate 'select count(*) from ' ||  v_dimensionTableArray(i) || ' where ' || v_columnTableArray(i) || ' = ''' || v_valueTransactionArrayID(i) ||''' and rownum = 1'  into  v_checkExists ;
        --rownum =1  -- Stop counting if 1 found
			--	DBMS_OUTPUT.PUT_LINE('++++++ select count(*) from ' ||  v_dimensionTableArray(i) || ' where ' || v_columnTableArray(i) || ' = ''' ||  v_valueTransactionArrayID(i) ||'''' ) ;
			--	DBMS_OUTPUT.PUT_LINE('------ v_checkExists: ' || v_checkExists );
				COUNT_INSERTFACTTABLE := COUNT_INSERTFACTTABLE+1;
			if v_checkExists = 1 then 
				DBMS_OUTPUT.PUT_LINE('------ Table exists: ' || v_dimensionTableArray(i) );
				update Fact_Sales 	set TOTAL_SALE = VAR_TOTAL_SALE, 
										T_DATE = ROWS_TRANSACTION.T_DATE, 
										PRICE = ROWS_MASTERDATA.PRICE
									where 	CUSTOMER_ID = ROWS_TRANSACTION.CUSTOMER_ID AND
											STORE_ID  = ROWS_TRANSACTION.STORE_ID AND
											SUPPLIER_ID = ROWS_MASTERDATA.SUPPLIER_ID AND
											PRODUCT_ID = ROWS_TRANSACTION.PRODUCT_ID;

--				DBMS_OUTPUT.PUT_LINE ('++++++  update Fact_Sales set TOTAL_SALE ='  || VAR_TOTAL_SALE 		  		|| ',  T_DATE = ' 	|| ROWS_TRANSACTION.T_DATE 		|| ', 
--										PRICE = '  	|| ROWS_MASTERDATA.PRICE   		|| '
--										where  CUSTOMER_ID =' || ROWS_TRANSACTION.CUSTOMER_ID || ' AND STORE_ID  = '  || ROWS_TRANSACTION.STORE_ID 	|| ' AND
--										SUPPLIER_ID =' || ROWS_MASTERDATA.SUPPLIER_ID 	|| ' AND PRODUCT_ID ='  || ROWS_TRANSACTION.PRODUCT_ID  );						
			else
				DBMS_OUTPUT.PUT_LINE(' ------------ TABLE NOT EXISTS: ' ||v_dimensionTableArray(i));
				--execute immediate 'SELECT LISTAGG (COLUMN_NAME, '', '') WITHIN GROUP (ORDER BY COLUMN_ID) into' ||  v_strColumnName || 
				-- ' FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = ''' || v_dimensionTableArray(i) ||'''' ;
        
				--DBMS_OUTPUT.PUT_LINE( 'SELECT LISTAGG (COLUMN_NAME, '', '') WITHIN GROUP (ORDER BY COLUMN_ID) into' ||  v_strColumnName || 
				--' FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = ''' || v_dimensionTableArray(i) ||'''' );
				--FROM ALL_TAB_COLUMNS WHERE LOWER(TABLE_NAME) = LOWER(v_dimensionTableArray[i]);
				--DBMS_OUTPUT.PUT_LINE(' AAAAAAAAAAAA ' ||v_dimensionTableArray(i));
				
			
				IF LOWER(v_dimensionTableArray(i)) = LOWER('DIMENSION_PRODUCT') THEN
      --       DBMS_OUTPUT.PUT_LINE('-------- COUNT_INSERTROWS: ' || COUNT_INSERTROWS || '-----  DIMENSION_PRODUCT:' );
						insert into DIMENSION_PRODUCT
						values (ROWS_TRANSACTION.PRODUCT_ID, ROWS_MASTERDATA.PRODUCT_NAME);
					
			
				ELSIF  LOWER(v_dimensionTableArray(i)) = LOWER('DIMENSION_SUPPLIER') THEN
         --   DBMS_OUTPUT.PUT_LINE('-------- COUNT_INSERTROWS: ' || COUNT_INSERTROWS || '-----  DIMENSION_SUPPLIER');
						insert into DIMENSION_SUPPLIER 
						values (ROWS_MASTERDATA.SUPPLIER_ID, ROWS_MASTERDATA.SUPPLIER_NAME);
					--	COUNT_INSERTFACTTABLE := COUNT_INSERTFACTTABLE+1;
				
				ELSIF  LOWER(v_dimensionTableArray(i)) = LOWER('DIMENSION_STORE') THEN
        --    DBMS_OUTPUT.PUT_LINE('-------- COUNT_INSERTROWS: ' || COUNT_INSERTROWS || '-----  DIMENSION_STORE');
           	insert into DIMENSION_STORE 
            values (ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.STORE_NAME);
			--COUNT_INSERTFACTTABLE := COUNT_INSERTFACTTABLE+1;
				
        ELSE 
        --    DBMS_OUTPUT.PUT_LINE('-------- COUNT_INSERTROWS: ' || COUNT_INSERTROWS || '-----  DIMENSION_STORE');
          	insert into DIMENSION_CUSTOMER
            values (ROWS_TRANSACTION.CUSTOMER_ID, ROWS_TRANSACTION.CUSTOMER_NAME);
			--COUNT_INSERTFACTTABLE := COUNT_INSERTFACTTABLE+1;
				END IF;
        
--        	DBMS_OUTPUT.PUT_LINE('select count(*) from FACT_SALES where PRODUCT_ID = ''' || ROWS_TRANSACTION.PRODUCT_ID || 
--                                                          ''' AND STORE_ID = '''    || ROWS_TRANSACTION.STORE_ID ||
--                                                          ''' AND SUPPLIER_ID = ''' || ROWS_MASTERDATA.SUPPLIER_ID ||
--                                                          ''' AND CUSTOMER_ID = ''' || ROWS_TRANSACTION.CUSTOMER_ID ||
--                                                          ''' AND rownum = 1 '  ) ;
        	DBMS_OUTPUT.PUT_LINE(' COUNT_INSERTFACTTABLE ' ||COUNT_INSERTFACTTABLE);
        execute immediate 'select count(*) from FACT_SALES where PRODUCT_ID = ''' || ROWS_TRANSACTION.PRODUCT_ID || 
                                                          ''' AND STORE_ID = '''    || ROWS_TRANSACTION.STORE_ID ||
                                                          ''' AND SUPPLIER_ID = ''' || ROWS_MASTERDATA.SUPPLIER_ID ||
                                                          ''' AND CUSTOMER_ID = ''' || ROWS_TRANSACTION.CUSTOMER_ID ||
                                                          ''' AND rownum = 1 '  into  v_checkFactTableExists ;
                                                             
        --DBMS_OUTPUT.PUT_LINE(' ------------ v_checkFactTableExists: ' ||v_checkFactTableExists);
        if v_checkFactTableExists = 0 AND COUNT_INSERTFACTTABLE = 4 then 
          DBMS_OUTPUT.PUT_LINE(' ------------ v_checkFactTableExists: ' ||v_checkFactTableExists ||
                               ' ------------ ROWS_TRANSACTION.PRODUCT_ID: ' ||ROWS_TRANSACTION.PRODUCT_ID ||
                               ' ------------ ROWS_TRANSACTION.CUSTOMER_ID: ' ||ROWS_TRANSACTION.CUSTOMER_ID || 
                               '  ------------ ROWS_MASTERDATA.SUPPLIER_ID: ' ||ROWS_MASTERDATA.SUPPLIER_ID ||
                                '  ------------ ROWS_TRANSACTION.STORE_ID: ' ||ROWS_TRANSACTION.STORE_ID );
                
          insert into Fact_Sales (PRODUCT_ID, STORE_ID, CUSTOMER_ID, SUPPLIER_ID, TOTAL_SALE, T_DATE, PRICE)
          values ( ROWS_TRANSACTION.PRODUCT_ID, ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.CUSTOMER_ID, ROWS_MASTERDATA.SUPPLIER_ID,
               VAR_TOTAL_SALE, ROWS_TRANSACTION.T_DATE, ROWS_MASTERDATA.PRICE );
			   COUNT_INSERTFACTTABLE := 0;
        END IF;
        			
				--DBMS_OUTPUT.PUT_LINE ('++++++++++' || ' 
				--					insert into ' || v_dimensionTableArray(i)  || ' ( ' || v_strColumnName || ' ) values ( ' || v_valueTransactionArrayID(i) 
                --  || ', ' || v_valueTransactionArrayNAME(i) || ')');		
										
			end if;
			   
			--DBMS_OUTPUT.PUT_LINE('-------- COUNT_INSERTROWS: ' || COUNT_INSERTROWS);				
			IF COUNT_INSERTROWS = 10 THEN
				COUNT_INSERTROWS := 0;
				COMMIT;
			END IF;        
		 
			COUNT_INSERTROWS:= COUNT_INSERTROWS+1;
		END LOOP;
	  	
						
											
    END LOOP;
	CLOSE CUR_50RetrieveFromMaster;
  END LOOP;
  CLOSE CUR_50TRANSACTION;
  DBMS_OUTPUT.PUT_LINE('Closing cursor...');
 
 
END;
