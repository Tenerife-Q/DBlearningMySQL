-- ==========================================
-- 实验2：数据查询实验
-- （四）嵌套查询
-- ==========================================

USE StudentDB;


-- 1. 查询和"邱杰"在同一学院的学生的学号、姓名、性别和系别
-- PRINT '===== 1. 查询和"邱杰"在同一学院的学生的学号、姓名、性别和系别 =====';
SELECT Sno, Sname, Ssex, Sdept
FROM Student
WHERE Sdept = (
    SELECT Sdept
    FROM Student
    WHERE Sname = '邱杰'
);


-- 2. 查询和"计算机文化基础"在同一学期开设的课程的课程信息
-- PRINT '===== 2. 查询和"计算机文化基础"在同一学期开设的课程的课程信息 =====';
SELECT *
FROM Course
WHERE Semester = (
    SELECT Semester
    FROM Course
    WHERE Cname = '计算机文化基础'
);


-- 3. 查询女生的学号及成绩
-- PRINT '===== 3. 查询女生的学号及成绩 =====';
SELECT Sno, Grade
FROM SC
WHERE Sno IN (
    SELECT Sno
    FROM Student
    WHERE Ssex = '女'
);


-- 4. 查询所有选修了"C001"号课程的学生的学号、姓名
-- PRINT '===== 4. 查询所有选修了"C001"号课程的学生的学号、姓名 =====';
SELECT Sno, Sname
FROM Student
WHERE Sno IN (
    SELECT Sno
    FROM SC
    WHERE Cno = 'C001'
);


-- 5. 查询了选修了课程名为"电子商务基础"的学生的学号和姓名
-- PRINT '===== 5. 查询了选修了课程名为"电子商务基础"的学生的学号和姓名 =====';
SELECT Sno, Sname
FROM Student
WHERE Sno IN (
    SELECT Sno
    FROM SC
    WHERE Cno = (
        SELECT Cno
        FROM Course
        WHERE Cname = '电子商务基础'
    )
);


-- 6. 查询选修了第二学期开课的学生学号、姓名、性别和系别
-- PRINT '===== 6. 查询选修了第二学期开课的学生学号、姓名、性别和系别 =====';
SELECT Sno, Sname, Ssex, Sdept
FROM Student
WHERE Sno IN (
    SELECT Sno
    FROM SC
    WHERE Cno IN (
        SELECT Cno
        FROM Course
        WHERE Semester = 2
    )
);


-- 7. 查询每个学生超过他选修课程平均成绩的学号、课程号及成绩
-- PRINT '===== 7. 查询每个学生超过他选修课程平均成绩的学号、课程号及成绩 =====';
SELECT Sno, Cno, Grade
FROM SC X
WHERE Grade > (
    SELECT AVG(Grade)
    FROM SC Y
    WHERE Y.Sno = X.Sno
);


-- 8. 查询其他学院比计算机学院所有学生年龄大的学生名单
-- PRINT '===== 8. 查询其他学院比计算机学院所有学生年龄大的学生名单 =====';
SELECT *
FROM Student
WHERE Sage > ALL (
    SELECT Sage
    FROM Student
    WHERE Sdept = 'CS'
)
AND Sdept <> 'CS';


-- 9. 查询其他学院比计算机学院某一个学生年龄小的学生名单
-- PRINT '===== 9. 查询其他学院比计算机学院某一个学生年龄小的学生名单 =====';
SELECT *
FROM Student
WHERE Sage < ANY (
    SELECT Sage
    FROM Student
    WHERE Sdept = 'CS'
)
AND Sdept <> 'CS';


-- 10. 使用EXISTS的子查询查询选修了C001号课程的学生的姓名
-- PRINT '===== 10. 使用EXISTS的子查询查询选修了C001号课程的学生的姓名 =====';
SELECT Sname
FROM Student
WHERE EXISTS (
    SELECT *
    FROM SC
    WHERE SC.Sno = Student.Sno AND SC.Cno = 'C001'
);


