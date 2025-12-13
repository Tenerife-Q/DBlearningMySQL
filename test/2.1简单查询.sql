-- ==========================================
-- 实验2：数据查询实验
-- （一）简单查询
-- ==========================================

USE StudentDB;


-- 1. 查询Student表、Course表、SC表的全部数据信息
PRINT '===== 1. 查询Student表、Course表、SC表的全部数据信息 =====';

select * 

-- 2. 查询全体学生的学号，姓名和年龄
PRINT '===== 2. 查询全体学生的学号，姓名和年龄 =====';

select Sno,Sname,Sage
from Student

-- 3. 查询课程号为1的课程的名字和先行课
PRINT '===== 3. 查询课程号为1的课程的名字和先行课 =====';

select Cname,Cpno
from Cource
where Cno = '1';

-- 4. 查询先行课为6的课程号和课程名及学分
PRINT '===== 4. 查询先行课为6的课程号和课程名及学分 =====';

select Cno,Cname,Ccredit
from Cource
where Pno = '6'

-- 5. 查询先行课为空的课程号，课程名
PRINT '===== 5. 查询先行课为空的课程号，课程名 =====';

select Cname,Cno
from Cource
where Pno is null;

-- 6. 查询课程号为2且成绩在88-95的学生的学号和成绩
PRINT '===== 6. 查询课程号为2且成绩在88-95的学生的学号和成绩 =====';

select Sno,grade
from SC
where Cno = '2' and grade between 88 and 95;

-- 7. 查询课程名以数据开始的课程编号，课程名和学分
PRINT '===== 7. 查询课程名以数据开始的课程编号，课程名和学分 =====';

select Cno,Cname,Ccredit
from Cource
where Cname like '数据%';

-- 8. 查询学生名字第二个为"晨"的学生的学号，姓名和性别
PRINT '===== 8. 查询学生名字第二个为"晨"的学生的学号，姓名和性别 =====';

select Sno,Sname,Ssex
from Student
where Sname like '_晨%';

-- 9. 查询性别为女或者姓"李"同学的学号，姓名和性别
PRINT '===== 9. 查询性别为女或者姓"李"同学的学号，姓名和性别 =====';

select Sno,Sname,Ssex
from Student
where sex = '女' or Sname like '李%';

-- 10. 查询"CS"系中学生的姓名，性别和出生年份
PRINT '===== 10. 查询"CS"系中学生的姓名，性别和出生年份 =====';

select Sname,Ssex,year(getdate()) - Sage as 出生年份
from Student
where Sdept = 'CS';

-- 11. 查询"MA"、"IS"、"CS"系学生的学号，姓名
PRINT '===== 11. 查询"MA"、"IS"、"CS"系学生的学号，姓名 =====';

select Sno,Sname
from Student
where Sdept in ('MA','IS','CS');

-- 12. 查询Course表中的前6个数据
PRINT '===== 12. 查询Course表中的前6个数据 =====';

select top 6*
from Cource;


-- 13. 查询SC表中成绩的前50%的数据
PRINT '===== 13. 查询SC表中成绩的前50%的数据 =====';

-- 这里一直报错
select top 50% *
from SC
order by grade desc;



-- ==========================================
-- 实验2：数据查询实验
-- （一）简单查询  下面标答
-- ==========================================

USE StudentDB;


-- 1. 查询Student表、Course表、SC表的全部数据信息
SELECT * FROM Student;
SELECT * FROM Course;
SELECT * FROM SC;


-- 2. 查询全体学生的学号，姓名和年龄
SELECT Sno, Sname, Sage
FROM Student;


-- 3. 查询课程号为1的课程的名字和先行课
SELECT Cname, Cpno
FROM Course
WHERE Cno = '1';


-- 4. 查询先行课为6的课程号和课程名及学分
SELECT Cno, Cname, Ccredit
FROM Course
WHERE Cpno = '6';


-- 5. 查询先行课为空的课程号，课程名
SELECT Cno, Cname
FROM Course
WHERE Cpno IS NULL;


-- 6. 查询课程号为2且成绩在88-95的学生的学号和成绩
SELECT Sno, Grade
FROM SC
WHERE Cno = '2' AND Grade BETWEEN 88 AND 95;


-- 7. 查询课程名以数据开始的课程编号，课程名和学分
SELECT Cno, Cname, Ccredit
FROM Course
WHERE Cname LIKE '数据%';


-- 8. 查询学生名字第二个为"晨"的学生的学号，姓名和性别
SELECT Sno, Sname, Ssex
FROM Student
WHERE Sname LIKE '_晨%';


-- 9. 查询性别为女或者姓"李"同学的学号，姓名和性别
SELECT Sno, Sname, Ssex
FROM Student
WHERE Ssex = '女' OR Sname LIKE '李%';


-- 10. 查询"CS"系中学生的姓名，性别和出生年份
SELECT Sname, Ssex, YEAR(GETDATE()) - Sage AS 出生年份
FROM Student
WHERE Sdept = 'CS';


-- 11. 查询"MA"、"IS"、"CS"系学生的学号，姓名
SELECT Sno, Sname
FROM Student
WHERE Sdept IN ('MA', 'IS', 'CS');


-- 12. 查询Course表中的前6个数据
SELECT *
FROM Course
LIMIT 6;

-- 13. 查询SC表中成绩的前50%的数据
-- SELECT TOP 50 PERCENT *    -- SQL Server 语法
-- FROM SC
-- ORDER BY Grade DESC;

SELECT FLOOR(COUNT(*) * 0.5)    -- 取整：FLOOR(COUNT(*) * 0.5) 确保结果为整数。
FROM SC
WHERE Grade IS NOT NULL
	
SELECT *
FROM SC
ORDER BY Grade DESC    -- 表示从高到低取前 50%（即成绩最好的一半）
LIMIT 2;
