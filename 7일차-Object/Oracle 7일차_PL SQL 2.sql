-- 7일차 PL/SQL
-- Oracle's Procedural Language Extension to SQL의 약자
-- 1. 개요
-- - 오라클 자체에 내장되어 있는 절차적 언어로서, SQL의 단점을 보완하여 SQL문장
-- 내에서 변수의 정의, 조건처리, 반복처리 등을 지원함

-- 2. 구조(익명블록) -        블록문법
-- 2.1 선언부(선택)         : DECLARE
-- 2.2 실행부(필수)         : BEGIN
-- 2.3 예외처리부(선택)     : EXCEPTION
-- 2.4 END;(필수)           : END;
-- 2.5 /(필수)               : /

BEGIN
    DBMS_OUTPUT.PUT_LINE('Hello PL/SQL');
END;
/

SET SERVEROUTPUT ON;

-- PL/SQL에서 변수쓰는 방법
DECLARE
    VID NUMBER;
BEGIN
    -- VID := 1023;
    SELECT SALARY
    INTO VID
    FROM EMPLOYEE
    WHERE EMP_NAME = '선동D';
    DBMS_OUTPUT.PUT_LINE('SALARY : ' || VID);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No DATA~');
END;
/
-- 2. PL/SQL 변수
DESC EMPLOYEE;
DECLARE
    VEMPNO EMPLOYEE.EMP_NO%TYPE;
    VENAME EMPLOYEE.EMP_NAME%TYPE;
    VSAL EMPLOYEE.SALARY%TYPE;
    VHDATE EMPLOYEE.HIRE_DATE%TYPE;
BEGIN
    SELECT EMP_NO, EMP_NAME, SALARY, HIRE_DATE
    INTO VEMPNO, VENAME, VSAL, VHDATE
    FROM EMPLOYEE
    WHERE EMP_ID = '200';
    DBMS_OUTPUT.PUT_LINE(VEMPNO || ' : ' || VENAME || ' : ' || VSAL  || ' : ' || VHDATE);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No DATA~');
END;
/
-- @실습문제1
-- 사번, 사원명, 직급명을 담을 수 있는 참조변수(%TYPE)를 통해서
-- 송종기 사원의 사번, 사원명, 직급명을 익명블럭을 통해 출력하세요.
DECLARE
    VEMPNO EMPLOYEE.EMP_ID%TYPE;
    VENAME EMPLOYEE.EMP_NAME%TYPE;
    VJNAME JOB.JOB_NAME%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, JOB_NAME
    INTO VEMPNO, VENAME, VJNAME
    FROM EMPLOYEE
    LEFT OUTER JOIN JOB USING(JOB_CODE)
    WHERE EMP_NAME = '송종기';
    DBMS_OUTPUT.PUT_LINE(VEMPNO || ' : ' || VENAME || ' : ' || VJNAME);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No DATA~');
END;
/
SET SERVEROUTPUT ON;

-- PL/SQL 입력 받기
DECLARE
    VEMP EMPLOYEE%ROWTYPE;
BEGIN
    SELECT *
    INTO VEMP
    FROM EMPLOYEE
    WHERE EMP_ID = '&EMP_ID';
    DBMS_OUTPUT.PUT_LINE('사번 : ' || VEMP.EMP_ID || ', 이름 : ' || VEMP.EMP_NAME);
END;
/

-- @실습문제2
-- 사원번호를 입력받아서 해당 사원의 사원번호, 이름, 부서코드, 부서명을 출력하세요.
DECLARE
    -- 변수 작성
    VEMP EMPLOYEE.EMP_ID%TYPE;
    VNAME EMPLOYEE.EMP_NAME%TYPE;
    VDCODE EMPLOYEE.DEPT_CODE%TYPE;
    VDNAME DEPARTMENT.DEPT_TITLE%TYPE;
BEGIN
    -- 쿼리문 작성
    SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
    -- 변수에 쿼리문 결과값 매핑
    INTO VEMP, VNAME, VDCODE, VDNAME
    FROM EMPLOYEE
    JOIN DEPARTMENT ON DEPT_ID = DEPT_CODE
    WHERE EMP_ID = '&EMP_ID';
    -- 결과 출력
    DBMS_OUTPUT.PUT_LINE('사번 : ' || VEMP || ', 이름 : ' || VNAME || ', 부서코드 : ' || VDCODE || ', 부서명 : ' || VDNAME);
END;
/

-- @실습문제3
-- EMPLOYEE 테이블에서 사번의 마지막 번호를 구한뒤 +1한 사번에 사용자로부터
-- 입력받은 이름, 주민번호, 전화번호, 직급코드, 급여등급을 등록하는 PL/SQL을 작성하시오.
-- 1. 마지막 번호를 구하는 쿼리문?
SELECT MAX(EMP_ID) FROM EMPLOYEE;
-- 2. 마지막 번호는 변수에 저장해서 레코드 등록 시 사용
SELECT MAX(EMP_ID)
INTO LAST_NUM
FROM EMPLOYEE;
-- 3. 정보들 입력받아서 EMPLOYEE 테이블에 INSERT
INSERT INTO EMPLOYEE(EMP_ID, EMP_NAME, EMP_NO, PHONE, JOB_CODE, SAL_LEVEL)
VALUES(LAST_NUM+1, '&NAME', '&EMPNO', '&PHONE', '&JOB_CODE', '&SAL_LEVEL');


DECLARE
    LAST_NUM EMPLOYEE.EMP_ID%TYPE;
BEGIN
    -- 마지막 번호를 가져올 수 있는 쿼리문
    SELECT MAX(EMP_ID)
    INTO LAST_NUM
    FROM EMPLOYEE;
    -- 마지막 번호에 +1을 해서 EMPLOYEE 테이블에 등록하는 쿼리문
    INSERT INTO EMPLOYEE(EMP_ID, EMP_NAME, EMP_NO, PHONE, JOB_CODE, SAL_LEVEL)
    VALUES(LAST_NUM+1, '&NAME', '&EMPNO', '&PHONE', '&JOB_CODE', '&SAL_LEVEL');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('완료되었습니다.');
END;
/

SELECT * FROM EMPLOYEE ORDER BY EMP_ID DESC;

-- == PL/SQL의 조건문 == --
-- 1. IF (조건식) THEN (실행문) END IF;
-- @실습문제1
-- 사원번호를 입력받아서 사원의 사번, 이름, 급여, 보너스율을 출력하시오
-- 단, 직급코드가 J1인 경우 '저희 회사 대표님입니다.'를 출력하시오.
-- 사번 : 222
-- 이름 : 이태림
-- 급여 : 2460000
-- 보너스율 : 0.35
-- 저희 회사 대표님입니다.
DECLARE
    EMP_INFO EMPLOYEE%ROWTYPE; -- 모든 정보를 받아오겠다, 변수 선언할 필요 없으니까 사용
BEGIN
    SELECT *
    INTO EMP_INFO -- EMPLOYEE의 모든 정보를 담는 코드
    FROM EMPLOYEE
    WHERE EMP_ID = '&EMP_ID'; -- EMP_ID를 입력받는 코드
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EMP_INFO.EMP_ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || EMP_INFO.EMP_NAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || EMP_INFO.SALARY);
    DBMS_OUTPUT.PUT_LINE('보너스율 : ' || EMP_INFO.BONUS*100 || '%');
    
    IF(EMP_INFO.JOB_CODE = 'J1')
    THEN DBMS_OUTPUT.PUT_LINE('저희 회사 대표님입니다.');
    END IF;
END;
/
-- 2. IF (조건식) THEN (실행문) ELSE (실행문) END IF;
-- @실습문제2
-- 사원번호를 입력받아서 사원의 사번, 이름, 부서명, 직급명을 출력하시오.
-- 단, 직급코드가 J1인 경우 '대표', 그 외에는 '일반직원'으로 출력하시오.
-- 사번 : 201
-- 이름 : 송종기
-- 부서명 : 총무부
-- 직급명 : 부사장
-- 소속 : 일반직원
DECLARE
    VEMP EMPLOYEE.EMP_ID%TYPE;
    VNAME EMPLOYEE.EMP_NAME%TYPE;
    VDNAME DEPARTMENT.DEPT_TITLE%TYPE;
    VJOB JOB.JOB_NAME%TYPE;
    VJCODE JOB.JOB_CODE%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, JOB_CODE
    INTO VEMP, VNAME, VDNAME, VJOB, VJCODE
    FROM EMPLOYEE
    JOIN DEPARTMENT ON DEPT_CODE = DEPT_ID
    JOIN JOB USING (JOB_CODE)
    WHERE EMP_ID = '&EMP_ID';
    DBMS_OUTPUT.PUT_LINE('사번 : ' || VEMP);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || VNAME);
    DBMS_OUTPUT.PUT_LINE('부서명 : ' || VDNAME);
    DBMS_OUTPUT.PUT_LINE('직급명 : ' || VJOB);
    
    IF(VJCODE = 'J1')
    THEN DBMS_OUTPUT.PUT_LINE('소속 : 대표');
    ELSE DBMS_OUTPUT.PUT_LINE('소속 : 일반직원');
    END IF;
END;
/

-- 3. IF (조건식) THEN (실행문) ELSIF (조건식) THEN (실행문)
--     ELSIF (조건식) THEN (실행문) ELSE (실행문) END IF;
-- @실습문제3
-- 사번을 입력 받은 후 급여에 따라 등급을 나누어 출력하도록 하시오.
-- 그때 출력 값은 사번, 이름, 급여, 급여등급을 출력하시오.
-- 500만원 이상(그외) : A
-- 400만원 ~ 499만원 : B
-- 300만원 ~ 399만원 : C
-- 200만원 ~ 299만원 : D
-- 100만원 ~ 199만원 : E
-- 0만원 ~ 99만원 : F
DECLARE
    EMP_INFO EMPLOYEE%ROWTYPE;
BEGIN
    SELECT *
    INTO EMP_INFO
    FROM EMPLOYEE
    WHERE EMP_ID = '&EMP_ID';
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EMP_INFO.EMP_ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || EMP_INFO.EMP_NAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || EMP_INFO.SALARY);
    
    IF(EMP_INFO.SALARY > 5000000)
    THEN DBMS_OUTPUT.PUT_LINE('A');
    ELSIF(EMP_INFO.SALARY <= 5000000 AND EMP_INFO.SALARY >= 4000000)
    THEN DBMS_OUTPUT.PUT_LINE('B');
    ELSIF(EMP_INFO.SALARY <= 4000000 AND EMP_INFO.SALARY >= 3000000)
    THEN DBMS_OUTPUT.PUT_LINE('C');
    ELSIF(EMP_INFO.SALARY <= 3000000 AND EMP_INFO.SALARY >= 2000000)
    THEN DBMS_OUTPUT.PUT_LINE('D');
    ELSIF(EMP_INFO.SALARY <= 2000000 AND EMP_INFO.SALARY >= 1000000)
    THEN DBMS_OUTPUT.PUT_LINE('E');
    ELSE DBMS_OUTPUT.PUT_LINE('F');
    END IF;
END;
/

DECLARE
    EMPID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    SLV VARCHAR(2);
BEGIN  
    SELECT EMP_ID, EMP_NAME, SALARY
    INTO EMPID, ENAME, SAL
    FROM EMPLOYEE
    WHERE EMP_ID = '&EMP_ID';
    SAL := SAL / 10000;
    IF(SAL BETWEEN 0 AND 99)
    THEN SLV := 'F';
    ELSIF (SAL BETWEEN 100 AND 99)
    THEN SLV := 'E';
    ELSIF (SAL BETWEEN 200 AND 299)
    THEN SLV := 'D';
    ELSIF (SAL BETWEEN 300 AND 399)
    THEN SLV := 'C';
    ELSIF (SAL BETWEEN 400 AND 499)
    THEN SLV := 'B';
    ELSE SLV := 'A';
    END IF;
-- 연봉이 적은 사람이 더 많기 때문에 똑같은 결과라도 작동시간이 짧아짐!
    IF (SAL >= 500)
    THEN SLV := 'A';
    ELSIF (SAL BETWEEN 400 AND 499)
    THEN SLV := 'B';
    ELSIF (SAL BETWEEN 300 AND 399)
    THEN SLV := 'C';
    ELSIF (SAL BETWEEN 200 AND 299)
    THEN SLV := 'D';
    ELSIF (SAL BETWEEN 100 AND 99)
    THEN SLV := 'E';
    ELSE SLV := 'F';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EMPID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || SAL);
    DBMS_OUTPUT.PUT_LINE('등급 : ' || SLV);
END;
/

SELECT * FROM EMPLOYEE;
-- ELSEIF와 대응하는 CASE문
-- CASE 변수
--  WHEN 값1 TEHN 실행문1;
--  WHEN 값2 TEHN 실행문2;
--  WHEN 값3 TEHN 실행문3;
--  WHEN 값4 TEHN 실행문4;
--  ELSE 실행문;
-- END CASE;
SAL := FLOOR(SAL / 1000000);
CASE SAL
    WHEN 0 THEN SLV := 'F';
    WHEN 1 THEN SLV := 'E';
    WHEN 2 THEN SLV := 'D';
    WHEN 3 THEN SLV := 'C';
    WHEN 4 THEN SLV := 'B';
    ELSE SLV := 'A';
END CASE;

-- == PL/SQL의 반복문 == --
















