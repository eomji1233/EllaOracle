-- 오라클 인덱스 실습
-- 1. 100만 개의 데이터를 넣을 테이블 생성
-- 2. 100만개 데이터 삽입(PL/SQL 반복문)
-- 3. 인덱스 설정 전 테스트
-- 4. 인덱스 설정
-- 5. 인덱스 설정 후 테스트

-- #1
-- 아이디, 비번, 이름, 전번, 주소, 등록일, 수정일
-- KH_CUSTOMER_TBL
CREATE TABLE KH_CUSTOMER_TBL
(
    USER_ID VARCHAR2(20),
    USER_PW VARCHAR2(30),
    USER_NAME VARCHAR2(30),
    USER_PHONE VARCHAR2(30),
    USER_ADDR VARCHAR2(500),
    REG_DATE TIMESTAMP DEFAULT SYSTIMESTAMP,
    FIX_DATE TIMESTAMP DEFAULT SYSTIMESTAMP
);
-- Table KH_CUSTOMER_TBL이(가) 생성되었습니다.
CREATE SEQUENCE SEQ_CUSTOMER_USERID
MINVALUE 1
MAXVALUE 999999999
START WITH 1
INCREMENT BY 1
NOCYCLE
NOCACHE;
-- Sequence SEQ_CUSTOMER_USERID이(가) 생성되었습니다.

-- #2
DECLARE
    V_USERID VARCHAR2(200);
BEGIN
    FOR N IN 10..1000000
    LOOP
        V_USERID := '1'||LPAD(SEQ_CUSTOMER_USERID.NEXTVAL, 9, 0);
        INSERT INTO KH_CUSTOMER_TBL
        VALUES(V_USERID, '0000', N ||'용자', '010-0000-0000', '서울시 중구 남대문로' || N, DEFAULT, DEFAULT);
    END LOOP;
END;
/
SELECT * FROM KH_CUSTOMER_TBL ORDER BY 1 ASC;

-- #3 
-- 인덱스 걸기 전 실행시간 체크
EXPLAIN PLAN FOR
SELECT * FROM KH_CUSTOMER_TBL
WHERE USER_NAME LIKE '22%용자';
-- 설명되었습니다.

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- 4049, 00:00:49, TABLE ACCESS FULL

-- #4
-- 인덱스 생성하기
CREATE INDEX IDX_CUSTOMER_USERNAME ON KH_CUSTOMER_TBL(USER_NAME);
-- Index IDX_CUSTOMER_USERNAME이(가) 생성되었습니다.

-- #5
-- 인덱스 건 후 실행시간 체크
EXPLAIN PLAN FOR
SELECT * FROM KH_CUSTOMER_TBL
WHERE USER_NAME LIKE '22%용자';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- 1852, 00:00:23, 00:00:01 , TABLE ACCESS BY INDEX ROWID, INDEX RANGE SCAN
