-- Active: 1762504522605@@127.0.0.1@3306@empdb
-- `homework_emp_251111.sql`파일에 작성하세요.
-- select * from employee;
-- ```

-- 1. 2020년 12월 25일이 무슨 요일인지 조회하시오. # 60
SELECT DAYNAME('2020-12-25') AS 요일;

-- 2. 주민번호가 1970년대생이면서 성별이 여자이고, 성이 전씨인 직원들의 사원명, 주민번호, 부서명, 직급명을 조회하시오.
SELECT e.EMP_NAME, e.EMP_NO, d.DEPT_TITLE, j.JOB_NAME
FROM
    EMPLOYEE e
    JOIN DEPARTMENT d ON e.DEPT_CODE = d.DEPT_ID
    JOIN JOB j ON e.JOB_CODE = j.JOB_CODE
WHERE
    SUBSTR(e.EMP_NO, 1, 2) BETWEEN '70' AND '79'
    AND SUBSTR(e.EMP_NO, 8, 1) IN ('2', '4') -- 여성
    AND e.EMP_NAME LIKE '전%';

-- 3. 가장 나이가 적은 직원의 사번, 사원명, 나이, 부서명, 직급명을 조회하시오.
-- 나이 계산 datediff(현재날짜 - 생년월일) / 365 

-- 버전 1
SELECT
    emp_name,
    emp_no,
    truncate(
        datediff(
            now(), 
            concat(if(substr(emp_no, 8, 1) in ('1', '2'), '19', '20'), substr(emp_no, 1, 6))
        ) / 365
    , 0) age
FROM
    employee;

-- 버전 2
SELECT
    emp_id,
    emp_name,
    (SELECT job_name FROM job WHERE job_code = E.job_code) job_name,
    (SELECT dept_title FROM department WHERE dept_id = E.dept_code) dept_title,
    truncate(
        datediff(
            now(), 
            concat(if(substr(emp_no, 8, 1) in ('1', '2'), '19', '20'), substr(emp_no, 1, 6))
        ) / 365
    , 0) age
FROM
    employee E
ORDER BY
    age
LIMIT 
    1;

-- 버전 3
SELECT e.EMP_ID, e.EMP_NAME, TIMESTAMPDIFF(
        YEAR, STR_TO_DATE(
            SUBSTR(e.EMP_NO, 1, 6), '%y%m%d'
        ), CURDATE()
    ) AS 나이, d.DEPT_TITLE, j.JOB_NAME
FROM
    EMPLOYEE e
    JOIN DEPARTMENT d ON e.DEPT_CODE = d.DEPT_ID
    JOIN JOB j ON e.JOB_CODE = j.JOB_CODE
ORDER BY 나이 ASC
LIMIT 1;

-- 4. 이름에 '형'자가 들어가는 직원들의 사번, 사원명, 부서명을 조회하시오.
SELECT e.EMP_ID, e.EMP_NAME, d.DEPT_TITLE
FROM EMPLOYEE e
    JOIN DEPARTMENT d ON e.DEPT_CODE = d.DEPT_ID
WHERE
    e.EMP_NAME LIKE '%형%';

-- 5. 해외영업부에 근무하는 사원명, 직급명, 부서코드, 부서명을 조회하시오.
SELECT e.EMP_NAME, j.JOB_NAME, d.DEPT_ID, d.DEPT_TITLE
FROM
    EMPLOYEE e
    JOIN DEPARTMENT d ON e.DEPT_CODE = d.DEPT_ID
    JOIN JOB j ON e.JOB_CODE = j.JOB_CODE
WHERE
    d.DEPT_TITLE LIKE '해외영업%';

-- 6. 보너스포인트를 받는 직원들의 사원명, 보너스포인트, 부서명, 근무지역명을 조회하시오.
SELECT e.EMP_NAME, e.BONUS, d.DEPT_TITLE, l.LOCAL_NAME
FROM
    EMPLOYEE e
    JOIN DEPARTMENT d ON e.DEPT_CODE = d.DEPT_ID
    JOIN LOCATION l ON d.LOCATION_ID = l.LOCAL_CODE
WHERE
    e.BONUS IS NOT NULL;

-- 7. 부서코드가 D2인 직원들의 사원명, 직급명, 부서명, 근무지역명을 조회하시오.
SELECT e.EMP_NAME, j.JOB_NAME, d.DEPT_TITLE, l.LOCAL_NAME
FROM
    EMPLOYEE e
    JOIN DEPARTMENT d ON e.DEPT_CODE = d.DEPT_ID
    JOIN JOB j ON e.JOB_CODE = j.JOB_CODE
    JOIN LOCATION l ON d.LOCATION_ID = l.LOCAL_CODE
WHERE
    e.DEPT_CODE = 'D2';

-- 8. 급여등급테이블 sal_grade의 등급별 최대급여(MAX_SAL)보다 많이 받는 직원들의 사원명, 직급명, 급여, 연봉을 조회하시오.
--     (사원테이블과 급여등급테이블을 SAL_LEVEL컬럼기준으로 동등(등가) 조인할 것)
SELECT e.EMP_NAME, j.JOB_NAME, e.SALARY, (e.SALARY * 12) AS 연봉
FROM
    EMPLOYEE e
    JOIN SAL_GRADE s ON e.SAL_LEVEL = s.SAL_LEVEL
    JOIN JOB j ON e.JOB_CODE = j.JOB_CODE
WHERE
    e.SALARY > s.MAX_SAL;

-- 9. 한국(KO)과 일본(JP)에 근무하는 직원들의 사원명, 부서명, 지역명, 국가명을 조회하시오.
SELECT e.EMP_NAME, d.DEPT_TITLE, l.LOCAL_NAME, n.NATIONAL_NAME
FROM
    EMPLOYEE e
    JOIN DEPARTMENT d ON e.DEPT_CODE = d.DEPT_ID
    JOIN LOCATION l ON d.LOCATION_ID = l.LOCAL_CODE
    JOIN NATION n ON l.NATIONAL_CODE = n.NATIONAL_CODE
WHERE
    n.NATIONAL_CODE IN ('KO', 'JP');

-- 10. 같은 부서에 근무하는 직원들의 사원명, 부서명, 동료이름을 조회하시오. (group_concat함수)
SELECT a.EMP_NAME AS 사원명, d.DEPT_TITLE AS 부서명, b.EMP_NAME AS 동료이름
FROM
    EMPLOYEE a
    JOIN EMPLOYEE b ON a.DEPT_CODE = b.DEPT_CODE
    AND a.EMP_ID <> b.EMP_ID
    JOIN DEPARTMENT d ON a.DEPT_CODE = d.DEPT_ID
ORDER BY a.EMP_NAME;

-- 11. 보너스포인트가 없는 직원들 중에서 직급이 차장과 사원인 직원들의 사원명, 직급명, 급여를 조회하시오. 단, join과 in 연산자 사용할 것
SELECT e.EMP_NAME, j.JOB_NAME, e.SALARY
FROM EMPLOYEE e
    JOIN JOB j ON e.JOB_CODE = j.JOB_CODE
WHERE
    e.BONUS IS NULL
    AND j.JOB_NAME IN ('차장', '사원');

-- 12. 재직중인 직원과 퇴사한 직원의 수를 조회하시오.
-- ```

-- 버전 1
select    
    if(QUIT_yn='Y', '재직자', '퇴사자') 재직여부,
    count(*) 
from
    employee
group BY
    quit_yn;

-- 버전 2
SELECT
    if(isnull(quit_date), '재직', '퇴사') 재직여부,
    count(*) 수
FROM
    employee
GROUP BY
    if(isnull(quit_date), '재직', '퇴사');

-- 버전 3
SELECT SUM(
        CASE
            WHEN e.QUIT_YN = 'N' THEN 1
            ELSE 0
        END
    ) AS 재직중, SUM(
        CASE
            WHEN e.QUIT_YN = 'Y' THEN 1
            ELSE 0
        END
    ) AS 퇴사자
FROM EMPLOYEE e;