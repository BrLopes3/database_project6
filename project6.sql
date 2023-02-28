SPOOL c:\BD2\project6.txt
SELECT to_char(sysdate,'DD Month Year HH:MI:SS Am')
FROM dual;

connect sys/sys as sysdba;
grant connect, resource to des03;
connect des03/des03;
SET SERVEROUTPUT ON

--Q1-------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE p6q1 AS
  -- step 1
  CURSOR fac_curr IS
    SELECT f_id,f_last,f_first,f_rank
    FROM  faculty;
    v_fid faculty.f_id%TYPE;
    v_f_last faculty.f_last%TYPE;
    v_f_first faculty.f_first%TYPE;
    v_rank faculty.f_rank%TYPE;
    
    CURSOR stud_curr (pc_faculty faculty.f_id%TYPE) IS
       SELECT s_id, s_last, s_first, s_dob, s_class 
       FROM   student
       WHERE  f_id = pc_faculty;
    v_sid student.s_id%TYPE;
    v_last student.s_last%TYPE;
    v_first student.s_first%TYPE;
    v_dob student.s_dob%TYPE;
    v_class student.s_class%TYPE;

BEGIN
  -- step 2
   OPEN fac_curr;
  -- step 3
   FETCH fac_curr INTO v_fid, v_f_last, v_f_first,v_rank;
     WHILE fac_curr%FOUND LOOP
     DBMS_OUTPUT.PUT_LINE('---------------------------------');
       DBMS_OUTPUT.PUT_LINE('Faculty ID: '|| v_fid ||
       ' is ' || v_f_first ||' '||v_f_last ||', Rank: '||
         v_rank || '.' );
            -- inner cursor
            OPEN stud_curr(v_fid);
            FETCH stud_curr INTO v_sid, v_last, v_first , v_dob, v_class;
            WHILE stud_curr%FOUND LOOP
              DBMS_OUTPUT.PUT_LINE('Student ID: '|| v_sid ||
              ' is ' || v_first ||' '||v_last||',  birthdate: '|| v_dob || ', class: ' || v_class ||'.' );
              FETCH stud_curr INTO v_sid, v_last, v_first , v_dob, v_class;
            END LOOP;
            CLOSE stud_curr; 
      FETCH fac_curr INTO v_fid, v_f_last, v_f_first,v_rank;
     END LOOP;
  -- step 4
   CLOSE fac_curr;
END;
/
exec p6q1;
-----------------------------------------------------------------------------
--Q2-------------------------------------------------------------------------
connect sys/sys as sysdba;
grant connect, resource to des04;
connect des04/des04;
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE p6q2 AS
  -- step 1
  CURSOR con_curr IS
    SELECT c_id,c_last,c_first
    FROM  consultant;
    v_cid consultant.c_id%TYPE;
    v_c_last consultant.c_last%TYPE;
    v_c_first consultant.c_first%TYPE;
    
    CURSOR skill_curr (pc_skill consultant.c_id%TYPE) IS
       SELECT skill_description, certification 
       FROM   consultant_skill, skill
       WHERE  c_id = pc_skill AND skill.skill_id = consultant_skill.skill_id;
    v_desc skill.skill_description%TYPE;
    v_cert consultant_skill.certification%TYPE;
    
BEGIN
  -- step 2
   OPEN con_curr;
  -- step 3
   FETCH con_curr INTO v_cid, v_c_last, v_c_first;
     WHILE con_curr%FOUND LOOP
     DBMS_OUTPUT.PUT_LINE('---------------------------------');
       DBMS_OUTPUT.PUT_LINE('Consultant ID: '|| v_cid ||
       ' is ' || v_c_first ||' '||v_c_last ||'.' );
            -- inner cursor
            OPEN skill_curr(v_cid);
            FETCH skill_curr INTO v_desc, v_cert;
            WHILE skill_curr%FOUND LOOP
              DBMS_OUTPUT.PUT_LINE('Skill description: '|| v_desc ||
              ', Certification: ' || v_cert ||'.');
              FETCH skill_curr INTO v_desc, v_cert;
            END LOOP;
            CLOSE skill_curr; 
      FETCH con_curr INTO v_cid, v_c_last, v_c_first;
     END LOOP;
  -- step 4
   CLOSE con_curr;
END;
/
exec p6q2;
-----------------------------------------------------------------------------
--Q3-------------------------------------------------------------------------
connect sys/sys as sysdba;
grant connect, resource to des02;
connect des02/des02;
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE p6q3 AS
CURSOR item_curr IS
SELECT item_id, item_desc, cat_id
FROM item;
v_item_id item.item_id%TYPE;
v_item_desc item.item_desc%TYPE;
v_cat_id item.cat_id%TYPE;

CURSOR inv_curr (pc_inv item.item_id%TYPE) IS
SELECT inv_id, inv_size, inv_price, inv_qoh
FROM inventory
WHERE item_id = pc_inv;
v_inv_id inventory.inv_id%TYPE;
v_inv_size inventory.inv_size%TYPE;
v_inv_price inventory.inv_price%TYPE;
v_inv_qoh inventory.inv_qoh%TYPE;

BEGIN
OPEN item_curr;
FETCH item_curr INTO v_item_id, v_item_desc, v_cat_id;
WHILE item_curr%FOUND LOOP
DBMS_OUTPUT.PUT_LINE('---------------------------------');
DBMS_OUTPUT.PUT_LINE('Item ID:'||v_item_id||' '||v_item_desc||' '||v_cat_id||'.');

OPEN inv_curr (v_item_id);
FETCH inv_curr INTO v_inv_id, v_inv_size, v_inv_price, v_inv_qoh;
WHILE inv_curr%FOUND LOOP
DBMS_OUTPUT.PUT_LINE('Inventory ID:'||v_inv_id||', Size: '||v_inv_size||', Price: '||v_inv_price||', Quantity: '||v_inv_qoh||'.');
FETCH inv_curr INTO v_inv_id, v_inv_size, v_inv_price, v_inv_qoh;
END LOOP;
CLOSE inv_curr;
FETCH item_curr INTO v_item_id, v_item_desc, v_cat_id;
END LOOP;
CLOSE item_curr;
END;
/

EXEC p6q3;
------------------------------------------------------------------------------
--Q4 --------------------------------------------------------------------------
connect sys/sys as sysdba;
grant connect, resource to des02;
connect des02/des02;
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE p6q4 AS
CURSOR item_curr IS
SELECT item.item_id, item_desc, cat_id, sum(inv_price*inv_qoh)AS value
FROM item, inventory
WHERE item.item_id= inventory.item_id
GROUP BY item.item_id, item_desc, cat_id
ORDER BY item.item_id;

v_item_id item.item_id%TYPE;
v_item_desc item.item_desc%TYPE;
v_cat_id item.cat_id%TYPE;
v_value NUMBER;
------------curr 2, inv 
CURSOR inv_curr (pc_item_id item.item_id%TYPE) IS
SELECT inv_id, inv_price, inv_qoh
FROM inventory
WHERE item_id= pc_item_id;

v_inv_id inventory.inv_id%TYPE;
v_inv_price inventory.inv_price%TYPE;
v_inv_qoh inventory.inv_qoh%TYPE;

BEGIN
OPEN item_curr;
FETCH item_curr INTO v_item_id, v_item_desc, v_cat_id, v_value;
WHILE item_curr%FOUND LOOP
DBMS_OUTPUT.PUT_LINE('---------------------------------------');
DBMS_OUTPUT.PUT_LINE('Item id: '|| v_item_id ||', ' ||v_item_desc ||', total value $' || v_value || '. Category id: '||v_cat_id);
OPEN inv_curr (v_item_id);
FETCH inv_curr INTO v_inv_id, v_inv_price, v_inv_qoh;
WHILE inv_curr%FOUND LOOP
DBMS_OUTPUT.PUT_LINE('Inventory id: '|| v_inv_id ||', price $'||v_inv_price||', quantity: '|| v_inv_qoh||'.');
FETCH inv_curr INTO v_inv_id, v_inv_price, v_inv_qoh;
END LOOP;
CLOSE inv_curr;
FETCH item_curr INTO v_item_id, v_item_desc, v_cat_id, v_value;
END LOOP;
CLOSE item_curr;
END;
/
EXEC P6Q4;
------------------------------------------------------------------------------
--Q5--------------------------------------------------------------------------
connect sys/sys as sysdba;
grant connect, resource to des04;
connect des04/des04;
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE p6q5(p_c_id IN consultant.c_id%TYPE, p_cert IN consultant_skill.certification%TYPE) AS

CURSOR cons_curr IS
SELECT c_id, c_last, c_first, c_city
FROM consultant
WHERE c_id = p_c_id;
v_c_id consultant.c_id%TYPE;
v_c_last consultant.c_last%TYPE;
v_c_first consultant.c_first%TYPE;
v_c_city consultant.c_city%TYPE;

CURSOR skill_curr (pc_id consultant.c_id%TYPE) IS 
SELECT skill_id, certification
FROM consultant_skill
WHERE c_id = pc_id;
v_skill_id consultant_skill.skill_id%TYPE;
v_cert consultant_skill.certification%TYPE;
v_new_cert consultant_skill.certification%TYPE;
BEGIN
IF upper(p_cert)='Y' OR upper(p_cert)='N' THEN
OPEN cons_curr;
FETCH cons_curr INTO v_c_id, v_c_last, v_c_first, v_c_city;
WHILE cons_curr%FOUND LOOP
DBMS_OUTPUT.PUT_LINE('Consultant id: '||v_c_id ||', Name: ' ||v_c_first||' '||v_c_last||', City: ' ||v_c_city|| '.');
DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------------');
OPEN skill_curr(v_c_id);
FETCH skill_curr INTO v_skill_id, v_cert;
WHILE skill_curr%FOUND LOOP
v_new_cert := p_cert;
UPDATE consultant_skill SET certification = v_new_cert;
DBMS_OUTPUT.PUT_LINE('Certification ID: '||v_skill_id||', Before: '||v_cert||', After: '||v_new_cert||'.');
FETCH skill_curr INTO v_skill_id, v_cert;
END LOOP;
CLOSE skill_curr;
FETCH cons_curr INTO v_c_id, v_c_last, v_c_first, v_c_city;
END LOOP;
CLOSE cons_curr;
ELSE
DBMS_OUTPUT.PUT_LINE('Enter with a valid option, Y or N');
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('Consultant ID '||v_c_id|| ' does not exist!');
END;
/
exec p6q5(101,'Y');
exec p6q5(100,'N');
exec p6q5(102,'A');

SPOOL OFF;
