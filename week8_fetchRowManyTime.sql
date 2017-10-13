--4. Repeat steps 1 to 3 until you load all the data from TRANSACTIONS table to DW.

CREATE OR REPLACE PROCEDURE SP_READ_CURSORTUPLE
IS
	CURSOR CUR_50TRANSACTION(min_row_cur number,max_row_cur number)
	IS
	SELECT * FROM (
		SELECT TR.*, ROWNUM rnum 
		FROM ( select * from TRANSACTIONS TR ORDER BY TR.TRANSACTION_ID ) TR WHERE ROWNUM <= max_row_cur
	) WHERE rnum >= min_row_cur;	
 
  
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
  type dimensionTableArray IS VARRAY(4) OF VARCHAR2(100);
  v_dimensionTableArray dimensionTableArray;
  
  type columnTableArray IS VARRAY(4) OF VARCHAR2(100);
  v_columnTableArray  columnTableArray;
  
  type valueTempIDArray IS VARRAY(4) OF VARCHAR2(100);
  v_valueTempIDArray valueTempIDArray;
  

  COUNT_INSERTROWS NUMBER; --count total of rows to commit (Insert into tables)
  COUNT_INSERTFACTTABLE  NUMBER; -- count to know inserting FACT_SALES avoid violated - parent key not found
  v_checkExists NUMBER;
  v_checkFactTableExists NUMBER;
  --v_strGetColumnName VARCHAR2(20); 
   min_row number := 1;
   max_row number := 50;
BEGIN
  IF CUR_50TRANSACTION%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('Cursor opened');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Cursor not open');
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('Opening cursor...'); -- using a lot of DBMS_OUTPUT.PUT_LINE causes   buffer overflow
  v_dimensionTableArray:= dimensionTableArray('Dimension_Product', 'Dimension_Store', 'Dimension_Customer','Dimension_Supplier');
  v_columnTableArray:= columnTableArray('PRODUCT_ID', 'STORE_ID', 'CUSTOMER_ID','SUPPLIER_ID');
  dbms_output.enable(NULL); -- Disables the limit of DBMS
  
   <<loopstart>> 
  DBMS_OUTPUT.PUT_LINE('+++++loop' || max_row );
  OPEN CUR_50TRANSACTION(min_row,max_row);
  COUNT_INSERTROWS:=0;
  COUNT_INSERTFACTTABLE:=0;
 
  
  LOOP
      --Get rows data from Cursor
      --Each Fetch jumps on a line
      FETCH CUR_50TRANSACTION INTO ROWS_TRANSACTION;
      EXIT WHEN CUR_50TRANSACTION%NOTFOUND;
     
	  VAR_TOTAL_SALE := 0;
      OPEN CUR_50RetrieveFromMaster(ROWS_TRANSACTION.PRODUCT_ID);
      LOOP
          FETCH CUR_50RetrieveFromMaster INTO ROWS_MASTERDATA;
          EXIT WHEN CUR_50RetrieveFromMaster%NOTFOUND;
          VAR_TOTAL_SALE := ROWS_MASTERDATA.PRICE * ROWS_TRANSACTION.QUANTITY;
     
		  v_valueTempIDArray:= valueTempIDArray( ROWS_TRANSACTION.PRODUCT_ID , ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.CUSTOMER_ID,ROWS_MASTERDATA.SUPPLIER_ID);
         
		 --  DBMS_OUTPUT.put_line('-----------' || v_dimensionTableArray.count );
  
          FOR i in 1 .. v_dimensionTableArray.count LOOP
              execute immediate 'select count(*) from ' ||  v_dimensionTableArray(i) || ' where ' || v_columnTableArray(i) || ' = ''' || v_valueTempIDArray(i) ||''' and rownum = 1'  into  v_checkExists ;
              --rownum =1  -- Stop counting if 1 found
                        COUNT_INSERTFACTTABLE := COUNT_INSERTFACTTABLE+1;
              IF v_checkExists = 1 then 
                  DBMS_OUTPUT.PUT_LINE('------ Table has value exists: ' || v_dimensionTableArray(i) );
                  update Fact_Sales 	set TOTAL_SALE = VAR_TOTAL_SALE, 
                                          T_DATE = ROWS_TRANSACTION.T_DATE, 
                                          PRICE = ROWS_MASTERDATA.PRICE
                                      where 	CUSTOMER_ID = ROWS_TRANSACTION.CUSTOMER_ID AND
                                              STORE_ID  = ROWS_TRANSACTION.STORE_ID AND
                                              SUPPLIER_ID = ROWS_MASTERDATA.SUPPLIER_ID AND
                                              PRODUCT_ID = ROWS_TRANSACTION.PRODUCT_ID;
    
              ELSE
                  DBMS_OUTPUT.PUT_LINE(' ------------ TABLE has no value EXISTS: ' ||v_dimensionTableArray(i));
                                  
                  --DBMS_OUTPUT.PUT_LINE( 'SELECT LISTAGG (COLUMN_NAME, '', '') WITHIN GROUP (ORDER BY COLUMN_ID) into' ||  v_strColumnName || 
                  --' FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = ''' || v_dimensionTableArray(i) ||'''' );
                  --FROM ALL_TAB_COLUMNS WHERE LOWER(TABLE_NAME) = LOWER(v_dimensionTableArray[i]);
                  --DBMS_OUTPUT.PUT_LINE(' AAAAAAAAAAAA ' ||v_dimensionTableArray(i));
            
          
                  IF LOWER(v_dimensionTableArray(i)) = LOWER('DIMENSION_PRODUCT') THEN
                   
                      insert into DIMENSION_PRODUCT
                      values (ROWS_TRANSACTION.PRODUCT_ID, ROWS_MASTERDATA.PRODUCT_NAME);
                    
                  ELSIF LOWER(v_dimensionTableArray(i)) = LOWER('DIMENSION_SUPPLIER') THEN
                   
                      insert into DIMENSION_SUPPLIER 
                      values (ROWS_MASTERDATA.SUPPLIER_ID, ROWS_MASTERDATA.SUPPLIER_NAME);
                  
                  ELSIF LOWER(v_dimensionTableArray(i)) = LOWER('DIMENSION_STORE') THEN
                    
                      insert into DIMENSION_STORE 
                      values (ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.STORE_NAME);
                        
                  ELSE 
                    
                      insert into DIMENSION_CUSTOMER
                      values (ROWS_TRANSACTION.CUSTOMER_ID, ROWS_TRANSACTION.CUSTOMER_NAME);
                  END IF;
                  		
              END IF; -- CLOSE IF 
             
              --  DBMS_OUTPUT.PUT_LINE(' COUNT_INSERTFACTTABLE ' ||COUNT_INSERTFACTTABLE);  --important comment
              execute immediate 'select count(*) from FACT_SALES where PRODUCT_ID = ''' || ROWS_TRANSACTION.PRODUCT_ID || 
                                                                ''' AND STORE_ID = '''    || ROWS_TRANSACTION.STORE_ID ||
                                                                ''' AND SUPPLIER_ID = ''' || ROWS_MASTERDATA.SUPPLIER_ID ||
                                                                ''' AND CUSTOMER_ID = ''' || ROWS_TRANSACTION.CUSTOMER_ID ||
                                                                ''' AND rownum = 1 '  into  v_checkFactTableExists ;
                                                                 
              --DBMS_OUTPUT.PUT_LINE(' ------------ v_checkFactTableExists: ' ||v_checkFactTableExists);
              IF v_checkFactTableExists = 0 AND COUNT_INSERTFACTTABLE = 4 then 
--                  DBMS_OUTPUT.PUT_LINE(' ROWS_TRANSACTION.PRODUCT_ID: ' ||ROWS_TRANSACTION.PRODUCT_ID ||
--                                       '  --ROWS_TRANSACTION.CUSTOMER_ID: ' ||ROWS_TRANSACTION.CUSTOMER_ID || 
--                                       ' -- ROWS_MASTERDATA.SUPPLIER_ID: ' ||ROWS_MASTERDATA.SUPPLIER_ID ||
--                                        '  -- ROWS_TRANSACTION.STORE_ID: ' ||ROWS_TRANSACTION.STORE_ID );
                    
                  insert into Fact_Sales (PRODUCT_ID, STORE_ID, CUSTOMER_ID, SUPPLIER_ID, TOTAL_SALE, T_DATE, PRICE)
                  values ( ROWS_TRANSACTION.PRODUCT_ID, ROWS_TRANSACTION.STORE_ID, ROWS_TRANSACTION.CUSTOMER_ID, ROWS_MASTERDATA.SUPPLIER_ID,
                       VAR_TOTAL_SALE, ROWS_TRANSACTION.T_DATE, ROWS_MASTERDATA.PRICE );
                  COUNT_INSERTFACTTABLE := 0;
               END IF;
             
             
              --DBMS_OUTPUT.PUT_LINE('-------- COUNT_INSERTROWS: ' || COUNT_INSERTROWS);				
              IF COUNT_INSERTROWS = 10 THEN
                COUNT_INSERTROWS := 0;
                COMMIT;
              END IF;        
             
              COUNT_INSERTROWS:= COUNT_INSERTROWS+1;
          END LOOP; -- CLOSE FOR
											
      END LOOP; -- CLOSE FETCH CUR_50RetrieveFromMaster
	  CLOSE CUR_50RetrieveFromMaster;
   END LOOP; -- CLOSE FETCH CUR_50TRANSACTION
  
   CLOSE CUR_50TRANSACTION;
  

   
   DBMS_OUTPUT.PUT_LINE(' ------------ past loop : ' || max_row );
   
   
   
   min_row := min_row + 50;  
   max_row := max_row + 50;   
  IF max_row != 10000 THEN 
   
       DBMS_OUTPUT.PUT_LINE(' ------------ max_row count : ' || max_row );
       
       GOTO loopstart; 
    END IF; 
   DBMS_OUTPUT.PUT_LINE(' ------------ max_row count : ' || max_row );
  
  
  
 
  
  
  
  
  DBMS_OUTPUT.PUT_LINE('Closing cursor...');
 
END;