--1
WITH Project_CTE AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        LAG(End_Date) OVER (ORDER BY Start_Date) AS Prev_End_Date
    FROM
        Projects
),
Projects AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        SUM(CASE WHEN Prev_End_Date = DATE_SUB(Start_Date, INTERVAL 1 DAY) THEN 0 ELSE 1 END) OVER (ORDER BY Start_Date) AS Project_Number
    FROM
        Project_CTE
)
SELECT
    MIN(Start_Date) AS Project_Start_Date,
    MAX(End_Date) AS Project_End_Date
FROM
    Projects
GROUP BY
    Project_Number
ORDER BY
    DATEDIFF(MAX(End_Date), MIN(Start_Date)) ASC,
    MIN(Start_Date) ASC;
--2
SELECT S.Name
FROM Students S
JOIN Friends F ON S.ID = F.ID
JOIN Packages P1 ON S.ID = P1.ID
JOIN Packages P2 ON F.Friend_ID = P2.ID
WHERE P2.Salary > P1.Salary
ORDER BY P2.Salary;
--3
SELECT DISTINCT LEAST(X, Y) AS X, GREATEST(X, Y) AS Y
FROM Functions A
JOIN Functions B ON A.X = B.Y AND A.Y = B.X
WHERE A.X != A.Y
ORDER BY LEAST(X, Y), GREATEST(X, Y);
--4
SELECT
    C.contest_id,
    C.hacker_id,
    C.name,
    COALESCE(SUM(VS.total_views), 0) AS total_views,
    COALESCE(SUM(VS.total_unique_views), 0) AS total_unique_views,
    COALESCE(SUM(SS.total_submissions), 0) AS total_submissions,
    COALESCE(SUM(SS.total_accepted_submissions), 0) AS total_accepted_submissions
FROM
    Contests C
JOIN Colleges CL ON C.contest_id = CL.contest_id
JOIN Challenges CH ON CL.college_id = CH.college_id
LEFT JOIN View_Stats VS ON CH.challenge_id = VS.challenge_id
LEFT JOIN Submission_Stats SS ON CH.challenge_id = SS.challenge_id
GROUP BY
    C.contest_id, C.hacker_id, C.name
HAVING
    total_views + total_unique_views + total_submissions + total_accepted_submissions > 0
ORDER BY
    C.contest_id;
--5
WITH Hacker_Submissions AS (
    SELECT
        submission_date,
        hacker_id,
        COUNT(DISTINCT submission_id) AS submissions
    FROM
        Submissions
    GROUP BY
        submission_date, hacker_id
),
Daily_Max AS (
    SELECT
        submission_date,
        MAX(submissions) AS max_submissions
    FROM
        Hacker_Submissions
    GROUP BY
        submission_date
),
Unique_Hackers AS (
    SELECT
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM
        Submissions
    GROUP BY
        submission_date
)
SELECT
    UH.submission_date,
    UH.unique_hackers,
    HS.hacker_id,
    H.name
FROM
    Unique_Hackers UH
JOIN
    Daily_Max DM ON UH.submission_date = DM.submission_date
JOIN
    Hacker_Submissions HS ON DM.submission_date = HS.submission_date AND DM.max_submissions = HS.submissions
JOIN
    Hackers H ON HS.hacker_id = H.hacker_id
ORDER BY
    UH.submission_date;
--6
SELECT ROUND(ABS(MIN(LAT_N) - MAX(LAT_N)) + ABS(MIN(LONG_W) - MAX(LONG_W)), 4) AS Manhattan_Distance
FROM STATION;
--7
WITH RECURSIVE PrimeNumbers AS (
    SELECT 2 AS num
    UNION
    SELECT num + 1
    FROM PrimeNumbers
    WHERE num < 1000
),
FilteredPrimes AS (
    SELECT num
    FROM PrimeNumbers P
    WHERE NOT EXISTS (
        SELECT 1
        FROM PrimeNumbers D
        WHERE D.num < P.num AND P.num % D.num = 0
    )
)
SELECT GROUP_CONCAT(num SEPARATOR '&') AS Primes
FROM FilteredPrimes;
--8
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM (
    SELECT Name, Occupation,
           ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM OCCUPATIONS
) AS OccupationRows
GROUP BY RowNum;
--9
WITH Nodes AS (
    SELECT N, P
    FROM BST
),
LeafNodes AS (
    SELECT N
    FROM BST
    WHERE N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL)
),
InnerNodes AS (
    SELECT N
    FROM BST
    WHERE N IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL)
      AND N NOT IN (SELECT N FROM LeafNodes)
)
SELECT
    N,
    CASE
        WHEN P IS NULL THEN 'Root'
        WHEN N IN (SELECT N FROM LeafNodes) THEN 'Leaf'
        ELSE 'Inner'
    END AS NodeType
FROM Nodes
ORDER BY N;
--10
WITH Hierarchy AS (
    SELECT company_code, founder, 
           COUNT(DISTINCT lead_manager_code) AS Lead_Managers,
           COUNT(DISTINCT senior_manager_code) AS Senior_Managers,
           COUNT(DISTINCT manager_code) AS Managers,
           COUNT(DISTINCT employee_code) AS Employees
    FROM Company C
    LEFT JOIN Lead_Manager LM ON C.company_code = LM.company_code
    LEFT JOIN Senior_Manager SM ON LM.lead_manager_code = SM.lead_manager_code
    LEFT JOIN Manager M ON SM.senior_manager_code = M.senior_manager_code
    LEFT JOIN Employee E ON M.manager_code = E.manager_code
    GROUP BY company_code, founder
)
SELECT company_code, founder, Lead_Managers, Senior_Managers, Managers, Employees
FROM Hierarchy
ORDER BY company_code;
--11
SELECT S.Name
FROM Students S
JOIN Friends F ON S.ID = F.ID
JOIN Packages P1 ON S.ID = P1.ID
JOIN Packages P2 ON F.Friend_ID = P2.ID
WHERE P2.Salary > P1.Salary
ORDER BY P2.Salary;
--12
WITH total_cost AS (
    SELECT 
        job_family,
        SUM(cost) AS total_cost
    FROM 
        job_family_cost
    GROUP BY 
        job_family
),
cost_by_region AS (
    SELECT 
        job_family,
        region,
        SUM(cost) AS region_cost
    FROM 
        job_family_cost
    GROUP BY 
        job_family, 
        region
)
SELECT 
    cbr.job_family,
    cbr.region,
    (cbr.region_cost / tc.total_cost) * 100 AS cost_ratio_percentage
FROM 
    cost_by_region cbr
JOIN 
    total_cost tc ON cbr.job_family = tc.job_family;
--13
SELECT 
    month, 
    business_unit, 
    cost / revenue AS cost_revenue_ratio
FROM 
    bu_financials;
--14
WITH total_headcount AS (
    SELECT 
        SUM(headcount) AS total_headcount
    FROM 
        employee_headcounts
)
SELECT 
    sub_band,
    headcount,
    (headcount / (SELECT total_headcount FROM total_headcount)) * 100 AS headcount_percentage
FROM 
    employee_headcounts;
--15
SELECT * FROM Employees
WHERE Salary IN (SELECT DISTINCT Salary FROM Employees ORDER BY Salary DESC LIMIT 5);
--16
UPDATE table_name
SET column1 = column1 + column2,
    column2 = column1 - column2,
    column1 = column1 - column2;
--17
-- Create a new SQL Server login
CREATE LOGIN new_user WITH PASSWORD = 'password';

-- Create a new user for the database
USE database_name;
CREATE USER new_user FOR LOGIN new_user;

-- Grant db_owner role to the new user
EXEC sp_addrolemember 'db_owner', 'new_user';
--18
SELECT 
    month, 
    business_unit,
    SUM(salary * weight) / SUM(weight) AS weighted_average_salary
FROM 
    employee_salaries
GROUP BY 
    month, 
    business_unit;
--19
WITH actual_avg AS (
    SELECT AVG(salary) AS actual_avg_salary
    FROM EMPLOYEES
),
miscalculated_avg AS (
    SELECT AVG(CAST(REPLACE(CAST(salary AS VARCHAR), '0', '') AS DECIMAL)) AS miscalculated_avg_salary
    FROM EMPLOYEES
)
SELECT 
    CEILING(actual_avg.actual_avg_salary - miscalculated_avg.miscalculated_avg_salary) AS error
FROM 
    actual_avg, miscalculated_avg;
--20
INSERT INTO table2 (id, column1, column2, created_at)
SELECT t1.id, t1.column1, t1.column2, t1.created_at
FROM table1 t1
LEFT JOIN table2 t2 ON t1.id = t2.id
WHERE t2.id IS NULL;