CREATE OR REPLACE 
PROCEDURE sp_InsertTable
(
    p_tableName  IN VARCHAR2,
    p_attributes IN VARCHAR2,
    p_field      IN VARCHAR2
)
IS
sql_query varchar2(200);
BEGIN
    sql_query := 'INSERT INTO ' ||  p_tableName || '(' ||p_attributes || ')' ||
                 ' VALUES ('  || p_field || ')';
    Dbms_Output.Put_Line('sql_query=' || sql_query);
    EXECUTE IMMEDIATE sql_query ;
    COMMIT;
EXCEPTION
  when others then
  raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

EXECUTE sp_InsertTable('course','course_no,course_name,course_address',  q'! 5 , 'Math1' , 'eee'  !');



EXECUTE Greeting;
SELECT  TRANSLATE('SQL*Plus User''s Guide', ' */''', '___') from dual;
select REPLACE( '''x''' ,Chr(39),'') from dual;
SELECT  translate('INSERT INTO X (A,B,"TABLE",SQL) VALUES 
(1, [X], [Y], [ FROM Y WHERE ID=[[XX]] ])', '[]', '''''' ) from dual; 
--cac d?u không cách nhau
--' becomes ''
--39 is a single quote, 34 a double quote
insert into course(course_no,course_name,course_address) values ('1','Math1','eee');

---------------------------------------
FOR vc2 IN (...) LOOP
   v_sql := 
       'BEGIN
            V_UPD NUMBER := 0;

            SELECT (SELECT ID_TIPO_TERR  
              FROM ZREPORTYTD_TMP 
             WHERE AUDITORIA = :p1
               AND TERRITORIO = :p2
               AND PRODUTO = :p3) 
              INTO V_UPD FROM DUAL;

            UPDATE ZReportYTD_TMP
               SET TARGET = :p4
             WHERE AUDITORIA = :p5
               AND TERRITORIO = :p6
               AND PRODUTO = :p7;
        END';
   EXECUTE IMMEDIATE v_sql USING VC2.AUDITORIA, VC2.NOME, VC2.PRODUTO, 
                                 VC2.OBJETIVO, VC2.AUDITORIA, VC2.NOME, 
                                 VC2.PRODUTO;
END LOOP;
------------------------


ALTER SESSION SET PLSQL_DEBUG=TRUE
CALL DBMS_DEBUG_JDWP.CONNECT_TCP('10.1.1.13','4000')
CALL DBMS_DEBUG_JDWP.DISCONNECT()