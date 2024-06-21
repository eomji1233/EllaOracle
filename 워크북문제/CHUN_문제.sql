-- 5. 입학정원이 20 명 이상 30 명 이하인 학과들의 학과 이름과 계열을 출력하시오.
SELECT DEPARTMENT_NAME, CATEGORY FROM TB_DEPARTMENT WHERE CAPACITY BETWEEN 20 AND 30;

-- 6. 춘 기술대학교는 총장을 제외하고 모든 교수들이 소속 학과를 가지고 있다. 그럼 춘
-- 기술대학교 총장의 이름을 알아낼 수 있는 SQL 문장을 작성하시오.
SELECT PROFESSOR_NAME FROM TB_PROFESSOR WHERE DEPARTMENT_NO IS NULL;

-- 10. 02 학번 전주 거주자들의 모임을 만들려고 한다. 휴학한 사람들은 제외한 재학중인
-- 학생들의 학번, 이름, 주민번호를 출력하는 구문을 작성하시오.
SELECT STUDENT_NO, STUDENT_NAME, STUDENT_SSN FROM TB_STUDENT
WHERE ENTRANCE_DATE LIKE '02%' AND STUDENT_ADDRESS LIKE '%전주%' AND ABSENCE_YN LIKE 'N';

-- 7. TO_DATE('99/10/11','YY/MM/DD'), TO_DATE('49/10/11','YY/MM/DD') 은 각각 몇 년 몇
-- 월 몇 일을 의미할까? 또 TO_DATE('99/10/11','RR/MM/DD'),
-- TO_DATE('49/10/11','RR/MM/DD') 은 각각 몇 년 몇 월 몇 일을 의미할까?
-- 99년 10월 11일, 49년 10월 11일, 1999년 10월 11일, 2049년 10월 11일

-- 8. 춘 기술대학교의 2000 년도 이후 입학자들은 학번이 A 로 시작하게 되어있다. 2000 년도
-- 이전 학번을 받은 학생들의 학번과 이름을 보여주는 SQL 문장을 작성하시오.
SELECT STUDENT_NO, STUDENT_NAME FROM TB_STUDENT
WHERE STUDENT_NO NOT LIKE 'A%';

-- 9. 학번이 A517178 인 한아름 학생의 학점 총 평점을 구하는 SQL 문을 작성하시오. 단,
-- 이때 출력 화면의 헤더는 "평점" 이라고 찍히게 하고, 점수는 반올림하여 소수점 이하 
-- 한 자리까지만 표시한다.
SELECT (SELECT ROUND(AVG(POINT),1) FROM TB_GRADE WHERE STUDENT_NO = S.STUDENT_NO) "평점" 
FROM TB_STUDENT S
WHERE STUDENT_NO = 'A517178';

-- 14. 춘 대학교에 다니는 동명이인(同名異人) 학생들의 이름을 찾고자 한다. 어떤 SQL
-- 문장을 사용하면 가능하겠는가?
SELECT STUDENT_NAME "동일이름", COUNT(*) "동명인 수" FROM TB_STUDENT
GROUP BY STUDENT_NAME
HAVING COUNT(*) > 1;

-- 11. 학번이 A313047 인 학생이 학교에 나오고 있지 않다. 지도 교수에게 내용을 전달하기
-- 위한 학과 이름, 학생 이름과 지도 교수 이름이 필요하다. 이때 사용할 SQL 문을
-- 작성하시오. 단, 출력헤더는 ‚ 학과이름‛ , ‚ 학생이름‛ , ‚ 지도교수이름‛ 으로
-- 출력되도록 한다
SELECT DEPARTMENT_NAME "학과이름", STUDENT_NAME "학생이름", PROFESSOR_NAME "지도교수이름" FROM TB_STUDENT
LEFT OUTER JOIN TB_DEPARTMENT USING(DEPARTMENT_NO)
LEFT OUTER JOIN TB_PROFESSOR ON COACH_PROFESSOR_NO = PROFESSOR_NO
WHERE STUDENT_NO = 'A313047';

-- 12. 2007 년도에 '인간관계론' 과목을 수강한 학생을 찾아 학생이름과 수강학기를 표시하는
-- SQL 문장을 작성하시오.
SELECT STUDENT_NAME, TERM_NO FROM TB_STUDENT
LEFT OUTER JOIN TB_GRADE USING(STUDENT_NO)
LEFT OUTER JOIN TB_CLASS USING(CLASS_NO)
WHERE TERM_NO LIKE '2007%' AND CLASS_NAME = '인간관계론';

-- 13. 예체능 계열 과목 중 과목 담당교수를 한 명도 배정받지 못한 과목을 찾아
-- 그 과목 이름과 학과 이름을 출력하는 SQL 문장을 작성하시오
SELECT CLASS_NAME, DEPARTMENT_NAME FROM TB_CLASS
LEFT OUTER JOIN TB_CLASS_PROFESSOR USING(CLASS_NO)
LEFT OUTER JOIN TB_DEPARTMENT USING(DEPARTMENT_NO)
WHERE PROFESSOR_NO IS NULL AND CATEGORY = '예체능'
ORDER BY 2 ASC;

COMMENT ON COLUMN TB_PROFESSOR.DEPARTMENT_NO IS '학과 번호';

-- 14. 춘 기술대학교 서반아어학과 학생들의 지도교수를 게시하고자 한다. 학생이름과
-- 지도교수 이름을 찾고 만일 지도 교수가 없는 학생일 경우 "지도교수 미지정‛ 으로
-- 표시하도록 하는 SQL 문을 작성하시오. 단, 출력헤더는 ‚ 학생이름‛ , ‚ 지도교수‛ 로
-- 표시하며 고학번 학생이 먼저 표시되도록 한다.
SELECT STUDENT_NAME "학생이름", NVL(PROFESSOR_NAME, '지도교수 미지정') "지도교수" FROM TB_STUDENT
LEFT OUTER JOIN TB_PROFESSOR ON COACH_PROFESSOR_NO = PROFESSOR_NO
WHERE TB_STUDENT.DEPARTMENT_NO = '020'
ORDER BY STUDENT_NO ASC;

-- 15. 휴학생이 아닌 학생 중 평점이 4.0 이상인 학생을 찾아 그 학생의 학번, 이름, 학과
-- 이름, 평점을 출력하는 SQL 문을 작성하시오.
SELECT STUDENT_NO "학번", STUDENT_NAME "이름", DEPARTMENT_NAME "학과 이름"
, (SELECT AVG(POINT) FROM TB_GRADE WHERE STUDENT_NO = S.STUDENT_NO) "평점"
FROM TB_STUDENT S
LEFT OUTER JOIN TB_DEPARTMENT USING(DEPARTMENT_NO)
WHERE (SELECT AVG(POINT) FROM TB_GRADE WHERE STUDENT_NO = S.STUDENT_NO) >= 4
AND ABSENCE_YN = 'N';

-- 9.TB_DEPARTMENT 의 CATEGORY 컬럼이 TB_CATEGORY 테이블의 CATEGORY_NAME 컬럼을 부모
-- 값으로 참조하도록 FOREIGN KEY 를 지정하시오. 이 때 KEY 이름은
-- FK_테이블이름_컬럼이름으로 지정한다. (ex. FK_DEPARTMENT_CATEGORY )
ALTER TABLE TB_DEPARTMENT
ADD CONSTRAINT FK_DEPARTMENT_CATEGORY FOREIGN KEY (CATEGORY) REFERENCES TB_CATEGORY(CATEGORY_NAME);

SELECT * FROM USER_CONS_COLUMNS WHERE TABLE_NAME = 'TB_DEPARTMENT';

-- 10. 춘 기술대학교 학생들의 정보만이 포함되어 있는 학생일반정보 VIEW 를 만들고자 한다.
-- 아래 내용을 참고하여 적절한 SQL 문을 작성하시오.
CREATE VIEW VW_학생일반정보 AS SELECT STUDENT_NO, STUDENT_NAME, STUDENT_ADDRESS FROM TB_STUDENT
LEFT OUTER JOIN TB_DEPARTMENT USING (DEPARTMENT_NO);

SELECT * FROM VW_학생일반정보;

GRANT CREATE VIEW TO CHUN;

-- 11. 춘 기술대학교는 1 년에 두 번씩 학과별로 학생과 지도교수가 지도 면담을 진행한다.
-- 이를 위해 사용할 학생이름, 학과이름, 담당교수이름 으로 구성되어 있는 VIEW 를 만드시오.
-- 이때 지도 교수가 없는 학생이 있을 수 있음을 고려하시오 (단, 이 VIEW 는 단순 SELECT
-- 만을 할 경우 학과별로 정렬되어 화면에 보여지게 만드시오.)
CREATE VIEW VW_지도면담 AS SELECT STUDENT_NAME "학생이름", DEPARTMENT_NAME "학과이름", PROFESSOR_NAME "지도교수이름" FROM TB_STUDENT
LEFT OUTER JOIN TB_DEPARTMENT USING (DEPARTMENT_NO)
LEFT OUTER JOIN TB_PROFESSOR ON COACH_PROFESSOR_NO = PROFESSOR_NO;

SELECT * FROM VW_지도면담
ORDER BY 2 ASC;

DROP VIEW VW_지도면담;


-- 5. 학번 A413042 인 박건우 학생의 주소가 "서울시 종로구 숭인동 181-21 "로 변경되었다고
-- 한다. 주소지를 정정하기 위해 사용할 SQL 문을 작성하시오.
SELECT * FROM TB_STUDENT
WHERE STUDENT_NO = 'A413042';
UPDATE TB_STUDENT SET STUDENT_ADDRESS = '서울시 종로구 숭인동 181-21' WHERE STUDENT_NO = 'A413042';

-- 6. 주민등록번호 보호법에 따라 학생정보 테이블에서 주민번호 뒷자리를 저장하지 않기로
-- 결정하였다. 이 내용을 반영한 적절한 SQL 문장을 작성하시오.
-- (예. 830530-2124663 ==> 830530 )
UPDATE TB_STUDENT SET STUDENT_SSN = SUBSTR(STUDENT_SSN, 1, 6);
SELECT * FROM TB_STUDENT;






