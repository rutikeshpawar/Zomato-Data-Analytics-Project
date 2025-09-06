-- EMP_DEPT CASE STUDY

CREATE DATABASE Emp_Analysis;
USE Emp_Analysis;

-- 2. Create the Dept Table as below
CREATE TABLE dept (
    deptno INT PRIMARY KEY,
    dname  VARCHAR(20) NOT NULL,
    loc    VARCHAR(20) NOT NULL
);

INSERT INTO dept (deptno, dname, loc) VALUES
 (10, "OPERATIONS", "BOSTON"),
 (20, "RESEARCH", "DALLAS"),
 (30, "SALES", "CHICAGO"),
 (40, "ACCOUNTING", "NEW YORK");
 
 SELECT * FROM DEPT;





-- 1. Create the Employee Table as per the Below Data Provided
-- Ensure the Salary cannot be Less then Negative or Zero
--	Deptno Should be foreign key. Referring to the Dept dept Table created in Step 2
--  Empno cannot be null or Duplicate. 
--  Default Job should be Clerk

CREATE TABLE emp (
    empno     INT PRIMARY KEY,
    ename     VARCHAR(20) NOT NULL,
    job       VARCHAR(20) DEFAULT 'CLERK',
    mgr       INT,
    hiredate  DATE NOT NULL,
    sal       DECIMAL(7,2) NOT NULL CHECK (sal > 0),
    comm      DECIMAL(7,2),
    deptno    INT NOT NULL,
    CONSTRAINT fk_emp_dept FOREIGN KEY (deptno) REFERENCES dept(deptno)
);

INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno) VALUES
(7369, 'SMITH', 'CLERK',    7902, '1980-12-17',  800.00, NULL, 20),
(7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600.00, 300.00, 30),
(7521, 'WARD',  'SALESMAN', 7698, '1981-02-22', 1250.00, 500.00, 30),
(7566, 'JONES', 'MANAGER',  7839, '1981-04-02', 2975.00, NULL, 20),
(7654, 'MARTIN','SALESMAN', 7698, '1981-09-28', 1250.00, 1400.00, 30),
(7698, 'BLAKE', 'MANAGER',  7839, '1981-05-01', 2850.00, NULL, 30),
(7782, 'CLARK', 'MANAGER',  7839, '1981-06-09', 2450.00, NULL, 10),
(7788, 'SCOTT', 'ANALYST',  7566, '1987-04-19', 3000.00, NULL, 20),
(7839, 'KING',  'PRESIDENT',NULL, '1981-11-17', 5000.00, NULL, 10),
(7844, 'TURNER','SALESMAN', 7698, '1981-09-08', 1500.00,    0.00, 30),
(7876, 'ADAMS', 'CLERK',    7788, '1987-05-23', 1100.00, NULL, 20),
(7900, 'JAMES', 'CLERK',    7698, '1981-12-03',  950.00, NULL, 30),
(7902, 'FORD',  'ANALYST',  7566, '1981-12-03', 3000.00, NULL, 20),
(7934, 'MILLER','CLERK',    7782, '1982-01-23', 1300.00, NULL, 10);

SELECT * FROM EMP;





-- 3.	List the Names and salary of the employee whose salary is greater than 1000
SELECT ename, sal
FROM emp
WHERE sal > 1000;




-- 4.	List the details of the employees who have joined before end of September 81.
SELECT * FROM emp
WHERE hiredate < "1981-10-01";





-- 5.	List Employee Names having I as second character.
SELECT ename FROM emp 
WHERE ename LIKE "_I%";




-- 6.	List Employee Name, Salary, Allowances (40% of Sal), P.F. (10 % of Sal) and Net Salary. Also assign the alias name for the columns
SELECT ename AS Name, sal AS Salary, 
ROUND(sal*0.40, 2) As Allowances, 
ROUND(sal*0.10, 2) AS "P.F." , 
ROUND(sal + (sal*0.40) - (sal*0.10), 2) AS "Net Salary"
FROM emp;




-- 7. List Employee Names with designations who does not report to anybody
SELECT ename AS Name, job
FROM emp 
WHERE mgr IS NULL;




-- 8.	List Empno, Ename and Salary in the ascending order of salary.
SELECT empno AS Empno, ename AS Name, sal AS Salary
FROM emp
ORDER BY sal ASC;




-- 9. How many jobs are available in the Organization ?
SELECT COUNT(DISTINCT job) AS distinct_jobs
FROM emp;

SELECT COUNT(job) AS total_jobs
FROM emp;

SELECT DISTINCT JOB
FROM EMP;




-- 10.	Determine total payable salary of salesman category
SELECT job, SUM(sal) AS "Total Payable Salary"
FROM emp 
WHERE job = "SALESMAN";


SELECT SUM(sal + IFNULL(comm, 0)) AS total_payable_salesman
FROM emp
WHERE job = 'SALESMAN';





-- 11.	List average monthly salary for each job within each department   
SELECT deptno, job, ROUND(AVG(sal), 2) AS avg_salary
FROM emp
GROUP BY deptno, job
ORDER BY deptno, job;




-- 12.	Use the Same EMP and DEPT table used in the Case study to 
-- Display EMPNAME, SALARY and DEPTNAME in which the employee is working.
SELECT e.ename AS EMPNAME, e.sal AS SALARY, d.dname AS DEPTNAME
FROM emp e
JOIN dept d ON e.deptno = d.deptno
ORDER BY DEPTNAME;




-- 13. Create the Job Grades Table as below
CREATE TABLE job_grades(
	grade 		VARCHAR(2) 	NOT NULL,
    lowest_sal 	INT 		NOT NULL,
    highest_sal INT 		NOT NULL
);

INSERT INTO job_grades (grade, lowest_sal, highest_sal) VALUES
('A', 0, 999),
('B', 1000, 1999),
('C', 2000, 2999),
('D', 3000, 3999),
('E', 4000, 5000);

SELECT * FROM job_grades;





-- 14. Display the last name, salary and Corresponding Grade.
SELECT e.ename AS EMPNAME, e.sal AS SALARY, j.grade AS GRADE
FROM emp e
JOIN job_grades j ON e.sal BETWEEN j.lowest_sal AND j.highest_sal
ORDER BY SALARY;




-- 15.	Display the Emp name and the Manager name under 
-- whom the Employee works in the below format .
-- Emp Report to Mgr.
SELECT CONCAT(e.ename,' reports to ', IFNULL(m.ename, 'nobody')) AS "Employee reports to MAnager"
FROM emp e
LEFT JOIN emp m ON e.mgr = m.empno;




-- 16.	Display Empname and Total sal where Total Sal (sal + Comm)
SELECT ename AS EmpName, (sal+ IFNULL(comm, 0)) as "Total Salary"
FROM emp;





-- 17.	Display Empname and Sal whose empno is a odd number
SELECT empno AS ENO, ename AS Empname, sal AS Salary
FROM emp
WHERE empno % 2 = 1;




-- 18.	Display Empname , Rank of sal in Organisation , Rank of Sal in their department
SELECT ename AS EMPNAME, sal AS SALARY, deptno AS DEPT_NO,
	RANK() OVER (ORDER BY sal DESC) AS ORGANISATION_RANK,
    RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) AS DEPT_RANK
FROM emp
ORDER BY ORGANISATION_RANK, deptno;




-- 19.	Display Top 3 Empnames based on their Salary
SELECT ename AS EMPNAME, sal AS SALARY
FROM emp
ORDER BY sal DESC
LIMIT 3;




-- 20. Display Empname who has highest Salary in Each Department.
SELECT e.ename, e.deptno, e.job , e.sal
FROM emp e
WHERE e.sal = (
    SELECT MAX(sal)
    FROM emp
    WHERE deptno = e.deptno
)
ORDER BY sal DESC;










