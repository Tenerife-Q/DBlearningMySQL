-- ==========================================
-- 实验2：数据查询实验
-- （二）数据统计

注意存在 AS 因为这里是做统计
-- ==========================================

USE StudentDB;


-- 1. 查询课程表中的数据并按课程名升序排序
PRINT '===== 1. 查询课程表中的数据并按课程名升序排序 =====';


select *
from Cource
order by Cname;

-- 2. 统计课程表中的课程数目
PRINT '===== 2. 统计课程表中的课程数目 =====';

select count(*) as 课程数目
from Cource;

-- 3. 查询输出最高的成绩
PRINT '===== 3. 查询输出最高的成绩 =====';


select max(Grade) as 最高成绩
from SC;


-- 4. 查询所有课程编号及相应选课人数
PRINT '===== 4. 查询所有课程编号及相应选课人数 =====';


select Cno as 课程编号,count(*) as 选课人数
from SC
group by Cno;


-- 5. 查询每位同学的平均成绩
PRINT '===== 5. 查询每位同学的平均成绩 =====';


select Sno as 学号 ,avg(Grade) as 平均成绩
from SC
group by Sno;

-- 6. 查询选修了2门课程及以上的学生的学号
PRINT '===== 6. 查询选修了2门课程及以上的学生的学号 =====';


select Sno as 学号
from SC
group by Sno 
having count(*) >= 2;

-- 7. 查询不同学分对应的课程门数
PRINT '===== 7. 查询不同学分对应的课程门数 =====';

select Ccredit as 学分,count(*) as 课程门数
from Cource
group by Ccredit;




-- ==========================================
-- 实验2：数据查询实验
-- （二）数据统计
-- ==========================================

USE StudentDB;


-- 1. 查询课程表中的数据并按课程名升序排序
-- PRINT '===== 1. 查询课程表中的数据并按课程名升序排序 =====';
SELECT *
FROM Course
ORDER BY Cname ASC;


-- 2. 统计课程表中的课程数目
-- PRINT '===== 2. 统计课程表中的课程数目 =====';
SELECT COUNT(*) AS 课程数目     -- AS 是给字段或表达式起别名（Alias）的关键字。
FROM Course;


-- 3. 查询输出最高的成绩
-- PRINT '===== 3. 查询输出最高的成绩 =====';
SELECT MAX(Grade) AS 最高成绩
FROM SC;


-- 4. 查询所有课程编号及相应选课人数
-- PRINT '===== 4. 查询所有课程编号及相应选课人数 =====';
SELECT Cno AS 课程编号, COUNT(*) AS 选课人数     
FROM SC
GROUP BY Cno;   
-- 数据库会把SC表中所有Cno相同的记录归为一组（即同一门课程的所有选课记录）
-- 对每一组执行 COUNT(*)，计算该课程有多少人选修


-- 5. 查询每位同学的平均成绩
-- PRINT '===== 5. 查询每位同学的平均成绩 =====';
SELECT Sno AS 学号, AVG(Grade) AS 平均成绩
FROM SC
GROUP BY Sno;


-- 6. 查询选修了2门课程及以上的学生的学号
-- PRINT '===== 6. 查询选修了2门课程及以上的学生的学号 =====';
SELECT Sno AS 学号
FROM SC
GROUP BY Sno
HAVING COUNT(*) >= 2;


-- 7. 查询不同学分对应的课程门数
-- PRINT '===== 7. 查询不同学分对应的课程门数 =====';
SELECT Ccredit AS 学分, COUNT(*) AS 课程门数
FROM Course
GROUP BY Ccredit;


