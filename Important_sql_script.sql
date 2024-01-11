USE employees;

SELECT emp_no, dept_no, from_date, to_date
from dept_emp

UNION

SELECT emp_no, dept_no, from_date, to_date
from dept_manager;


SELECT employees.first_name, employees.last_name, employees.gender, employees.hire_date, salaries.salary
FROM employees
JOIN salaries ON employees.emp_no = salaries.emp_no
ORDER BY employees.hire_date DESC;

-- There is no decode function in mysql. According to chatgpt, Orcale and other databases have that function
-- If there is a need to use that function then you can use the case statements
select emp_no, gender,
case  gender
WHEN 'M' THEN 'He is male'
WHEN 'F' THEN 'She is female'
end as idenification_of_male_or_female
from employees;


-- MySQL does not have a MINUS function like some other database systems (e.g., Oracle). 
-- However, you can achieve similar functionality using the LEFT JOIN and IS NULL approach or the NOT IN subquery.
SELECT DISTINCT
    salaries.emp_no, salaries.salary, 
    employees.emp_no, employees.first_name, employees.last_name 
FROM salaries
LEFT JOIN employees ON employees.emp_no = salaries.emp_no
WHERE salaries.salary IS NULL;


-- this is for the cross tab function.
-- There is no cross tab function for mysql. 
-- The cross tab function only exists for Oracle and Microsoft sql server databases
SELECT
    salary,
    CASE WHEN salary = '50000' THEN 'Employee with Salary 50000' 
    ELSE 'Other Employees' END AS Salary_Category
FROM
    salaries
WHERE
	salary = '45000' 
    OR
    salary = '55000'
    OR
    salary <= '60000';


select count(1) from salaries;

select count(distinct(from_date)) from salaries
order by from_date;

select min(from_date), max(from_date) from salaries
order by from_date;


select * from employees;
select count(emp_no) from employees;

select * from salaries;
TRUNCATE TABLE salaries;


select * from titles;
TRUNCATE TABLE titles;


select * from dept_emp;

select * from dept_manager;











-- List total # of employees hired by year
SELECT 
	YEAR(hire_date) AS hire_year, 
	COUNT(*) AS total_employees_hired_that_year

FROM employees
GROUP by hire_year
ORDER BY hire_year;

-- List total # of male and female employees hired by the year 
select 
	year(hire_date) as Hired_by_the_year,
	sum(case when gender = 'M' then 1 else 0 end) as male_hires,
    sum(case when gender = 'F' then 1 else 0 end) as female_hires
from Employees
GROUP BY Hired_by_the_year
order by Hired_by_the_year;


-- to check the select statement above
SELECT
    SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male_hires,
    SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female_hires
FROM employees
WHERE YEAR(hire_date) = 1985;


-- List maximum salary by year
SELECT 
	YEAR(from_date) AS by_year, 
	max(salary) AS total_salary_by_year
FROM salaries
GROUP by by_year
ORDER BY by_year;

-- query to check if the valyes are correct
SELECT MAX(salary) AS max_salary
FROM salaries
WHERE YEAR(from_date) = 1985;


-- Name which employees received the maximum salary for each year
-- Create a Common Table Expression (CTE) named MaxSalaries to calculate the maximum salary for each year.
WITH MaxSalaries AS (
    -- Select the year from from_date and calculate the maximum salary for each year.
    SELECT
        YEAR(s.from_date) AS year,
        MAX(s.salary) AS max_salary
    FROM salaries s
    GROUP BY YEAR(s.from_date)
)
-- Select employee information for those who received the maximum salary for each year.
SELECT 
    -- Select employee details, including employee number, first name, last name, and salary.
    -- Include the year from the salary period.
    ms.year,
    e.first_name,
    e.last_name,
    s.salary
FROM employees e
-- Join the employees table with the salaries table based on employee number.
INNER JOIN salaries s ON e.emp_no = s.emp_no
-- Join the result with the MaxSalaries CTE based on the year and maximum salary.
INNER JOIN MaxSalaries ms ON YEAR(s.from_date) = ms.year AND s.salary = ms.max_salary
order by ms.year
LIMIT 5;


-- List total employees in the folllowing age group 20-25, 26-30, 31-35, 36-40,41-45,46-50,51-55,56-60,65-70,76-80,81-86
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 20 AND 25 THEN '20-25'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 26 AND 30 THEN '26-30'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 31 AND 35 THEN '31-35'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 36 AND 40 THEN '36-40'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 41 AND 45 THEN '41-45'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 46 AND 50 THEN '46-50'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 51 AND 55 THEN '51-55'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 56 AND 60 THEN '56-60'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 61 AND 65 THEN '61-65'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 66 AND 70 THEN '66-70'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 71 AND 75 THEN '71-75'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 76 AND 80 THEN '76-80'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 81 AND 86 THEN '81-86'
        ELSE '86+'
    END AS age_group,
    COUNT(*) AS total_employees
FROM employees
GROUP BY age_group
ORDER BY age_group;





