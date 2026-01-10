-- Active: 1762504522605@@127.0.0.1@3306@empdb
-- Active: 1762504522605@@127.0.0.1@3306
-- 1. EMPLOYEE 테이블에서 이름 끝이 `연`으로 끝나는 사원의 이름을 출력하시오. # 51
SELECT EMP_NAME FROM EMPLOYEE WHERE EMP_NAME LIKE '%연';

-- 2. EMPLOYEE 테이블에서 전화번호 처음 3자리가 `010`이 아닌 사원의 이름, 전화번호를 출력하시오.
SELECT EMP_NAME, PHONE
FROM EMPLOYEE
WHERE
    SUBSTR(PHONE, 1, 3) <> '010';

-- 3. EMPLOYEE 테이블에서 메일주소 '_'의 앞이 4자이면서, DEPT_CODE가 `D9` 또는 `D5`이고 고용일이 `90/01/01` ~ `01/12/31`이면서, 월급이 270만원 이상인 사원의 전체 정보를 출력하시오.
SELECT *
FROM EMPLOYEE
WHERE
    LENGTH(
        SUBSTR(
            EMAIL,
            1,
            INSTR(EMAIL, '_') - 1
        )
    ) = 4
    AND DEPT_CODE IN ('D9', 'D5')
    AND HIRE_DATE BETWEEN TO_DATE ('1990-01-01', 'YYYY-MM-DD') AND TO_DATE  ('2001-12-31', 'YYYY-MM-DD')
    AND SALARY >= 2700000;

-- 4. EMPLOYEE 테이블에서 현재 근무 중인 사원을 이름 오름차순으로 정렬해서 출력하세요.
SELECT EMP_NAME
FROM EMPLOYEE
WHERE
    ENT_DATE IS NULL
ORDER BY EMP_NAME ASC;

-- 5. 사원별 입사일, 퇴사일, 근무기간(일)을 조회하세요. 퇴사자 역시 조회되어야 합니다.
SELECT
    EMP_NAME,
    HIRE_DATE,
    NVL (ENT_DATE, SYSDATE) AS ENT_DATE,
    NVL (ENT_DATE, SYSDATE) - HIRE_DATE AS WORK_DAYS
FROM EMPLOYEE;

## grouping 처리

-- 6. EMPLOYEE 테이블에서 여자사원의 급여 총 합을 계산
-- (주민등록번호를 이용해 남여사원을 구분하세요.)
SELECT SUM(SALARY) AS FEMALE_SALARY_SUM
FROM EMPLOYEE
WHERE
    SUBSTR(EMP_NO, 8, 1) IN ('2', '4');

-- 7. 부서코드가 D5인 사원들의 급여총합, 보너스 총합 조회
SELECT SUM(SALARY) AS TOTAL_SALARY, SUM(SALARY * NVL (BONUS, 0)) AS TOTAL_BONUS
FROM EMPLOYEE
WHERE
    DEPT_CODE = 'D5';

-- 8. 부서코드가 D5인 직원의 보너스 포함 연봉의 총합 을 계산
SELECT SUM(
        SALARY * 12 * (1 + NVL (BONUS, 0))
    ) AS TOTAL_ANNUAL_PAY
FROM EMPLOYEE
WHERE
    DEPT_CODE = 'D5';

-- 9. 남/여 사원 급여합계를 동시에 표현(가공된 컬럼의 합계)
SELECT
    SUM(
        CASE
            WHEN SUBSTR(EMP_NO, 8, 1) IN ('1', '3') THEN SALARY
        END
    ) AS MALE_SALARY_SUM,
    SUM(
        CASE
            WHEN SUBSTR(EMP_NO, 8, 1) IN ('2', '4') THEN SALARY
        END
    ) AS FEMALE_SALARY_SUM
FROM EMPLOYEE;

-- 10.  EMPLOYEE 테이블에서 실제 사원들이 소속되어있는 부서의 수를 조회 (유령부서 제외)
-- (NULL은 제외하고, 중복된 부서는 하나로 카운팅)
SELECT COUNT(DISTINCT DEPT_CODE) AS REAL_DEPT_COUNT
FROM EMPLOYEE
WHERE
    DEPT_CODE IS NOT NULL;

# 사원테이블 확인
select * from employee;

select * from department;

select * from job;

select * from location;

select * from nation;

select * from sal_grade;

-- 5. 사원별 입사일, 퇴사일, 근무기간(일)을 조회하세요. 퇴사자 역시 조회되어야 합니다.
SELECT emp_name, hire_date, quit_date, datediff(
        ifnull(quit_date, now()), hire_date
    )
FROM employee;
---------------------------------------------------------------

-- 9. 남/여 사원 급여합계를 동시에 표현 (가공된 컬럼의 합계)
-- 버전 1
select
    emp_name,
    emp_no,
    if(
        substr(emp_no, 8, 1) = 1
        or substr(emp_no, 8, 1) = 3,
        '남',
        '여'
    ) gender,
    if(
        substr(emp_no, 8, 1) in (1, 3),
        '남',
        '여'
    ) gender
from employee;
-------------------------------------------------------------------
-- 버전 2
select if(
        substr(emp_no, 8, 1) in (1, 3), '남', '여'
    ), format(sum(salary), 0) sum_salary
from employee
GROUP BY
    if(
        substr(emp_no, 8, 1) in (1, 3),
        '남',
        '여'
    );
-------------------------------------------------------------------
-- 버전 3
SELECT format(
        sum(
            if(
                substr(emp_no, 8, 1) in (1, 3), salary, 0
            )
        ), 0
    ) '남자사원 급여합계', format(
        sum(
            if(
                substr(emp_no, 8, 1) in (1, 3), 0, salary
            )
        ), 0
    ) '여자사원 급여합계'
FROM employee;

-- case 함수

-- case함수
SELECT
    emp_name,
    emp_no,
    case
        when substr(emp_no, 8, 1) in (1, 3) then '남'
        when substr(emp_no, 8, 1) in (2, 4) then '여'
    end as "gender", -- case type1방식 (if..elif 방식)
    case substr(emp_no, 8, 1)
        when "1" then "남"
        when "3" then "남"
        else "여"
    end as "gender" -- case type2방식 (match..case 방식)
FROM employee;