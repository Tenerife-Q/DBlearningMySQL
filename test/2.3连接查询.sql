-- ==========================================
-- 实验2：数据查询实验
-- （三）连接查询
-- ==========================================

USE StudentDB;


-- 1. 查询每个学生及其选修课程的情况
SELECT Student.*, SC.Cno, SC.Grade
FROM Student
INNER JOIN SC ON Student.Sno = SC.Sno;


-- 2. 查询每门课程及其选修情况
SELECT Course.*, SC.Sno, SC.Grade
FROM Course
INNER JOIN SC ON Course.Cno = SC.Cno;


-- 3. 查询学生的学号，姓名，性别，系别，选修课程号，课程名及成绩
-- PRINT '===== 3. 查询学生的学号，姓名，性别，系别，选修课程号，课程名及成绩 =====';
SELECT Student.Sno, Student.Sname, Student.Ssex, Student.Sdept, 
       Course.Cno, Course.Cname, SC.Grade
FROM Student
INNER JOIN SC ON Student.Sno = SC.Sno
INNER JOIN Course ON SC.Cno = Course.Cno;


-- 4. 查询选修C002号课程且成绩在90分以上的所有学生的学号、姓名和成绩
-- PRINT '===== 4. 查询选修C002号课程且成绩在90分以上的所有学生的学号、姓名和成绩 =====';
SELECT Student.Sno, Student.Sname, SC.Grade
FROM Student
INNER JOIN SC ON Student.Sno = SC.Sno
WHERE SC.Cno = 'C002' AND SC.Grade > 90;


-- 5. 查询选修了课程名为"电子商务基础"的学生的学号、课程号、课程名及成绩
-- PRINT '===== 5. 查询选修了课程名为"电子商务基础"的学生的学号、课程号、课程名及成绩 =====';
SELECT SC.Sno, Course.Cno, Course.Cname, SC.Grade
FROM SC
INNER JOIN Course ON SC.Cno = Course.Cno
WHERE Course.Cname = '电子商务基础';


-- 6. 查询同时选修了"C001"和"C002"号课程的学生的学号
-- PRINT '===== 6. 查询同时选修了"C001"和"C002"号课程的学生的学号 =====';
SELECT SC1.Sno
FROM SC SC1
INNER JOIN SC SC2 ON SC1.Sno = SC2.Sno
WHERE SC1.Cno = 'C001' AND SC2.Cno = 'C002';


-- 7. 使用左外连接查询学生的学号、姓名、系别、课程号及成绩
-- PRINT '===== 7. 使用左外连接查询学生的学号、姓名、系别、课程号及成绩 =====';
SELECT Student.Sno, Student.Sname, Student.Sdept, SC.Cno, SC.Grade
FROM Student
LEFT OUTER JOIN SC ON Student.Sno = SC.Sno;


-- 8. 使用左外连接查询课程号、课程名、学生的学号及成绩
-- PRINT '===== 8. 使用左外连接查询课程号、课程名、学生的学号及成绩 =====';
SELECT Course.Cno, Course.Cname, SC.Sno, SC.Grade
FROM Course
LEFT OUTER JOIN SC ON Course.Cno = SC.Cno;


-- 9. 使用右外连接查询学生的学号、姓名、系别、课程号及成绩
-- PRINT '===== 9. 使用右外连接查询学生的学号、姓名、系别、课程号及成绩 =====';
SELECT Student.Sno, Student.Sname, Student.Sdept, SC.Cno, SC.Grade
FROM SC
RIGHT OUTER JOIN Student ON SC.Sno = Student.Sno;


-- 10. 使用右外连接查询课程号、课程名、学生的学号及成绩
-- PRINT '===== 10. 使用右外连接查询课程号、课程名、学生的学号及成绩 =====';
SELECT Course.Cno, Course.Cname, SC.Sno, SC.Grade
FROM SC
RIGHT OUTER JOIN Course ON SC.Cno = Course.Cno;


-- 11. 查询女生的学号，姓名及成绩
-- PRINT '===== 11. 查询女生的学号，姓名及成绩 =====';
SELECT Student.Sno, Student.Sname, SC.Grade
FROM Student
INNER JOIN SC ON Student.Sno = SC.Sno
WHERE Student.Ssex = '女';


-- 12. 筛选出每门课程总分大于100的课程号、课程名称、总分及平均分
-- PRINT '===== 12. 筛选出每门课程总分大于100的课程号、课程名称、总分及平均分 =====';
SELECT Course.Cno, Course.Cname, SUM(SC.Grade) AS 总分, AVG(SC.Grade) AS 平均分
FROM Course
INNER JOIN SC ON Course.Cno = SC.Cno
GROUP BY Course.Cno, Course.Cname
HAVING SUM(SC.Grade) > 100;


