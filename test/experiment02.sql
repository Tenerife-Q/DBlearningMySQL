-- ==========================================
-- 实验2：数据查询实验 
-- ==========================================
-- 注意：在Navicat中，选中单条SQL语句后按Ctrl+Enter执行，即可看到下方结果窗口的输出

-- ==========================================
-- 第一步：创建数据库和表结构
-- ==========================================

DROP DATABASE IF EXISTS StudentDB;
CREATE DATABASE StudentDB; 
USE StudentDB;

-- 创建Student表（学生表）
CREATE TABLE Student (
    Sno VARCHAR(20) PRIMARY KEY,          
    Sname VARCHAR(50) NOT NULL,           
    Ssex VARCHAR(10) CHECK (Ssex IN ('男', '女')),  
    Sage INT CHECK (Sage >= 0 AND Sage <= 150),     
    Sdept VARCHAR(50)                     
);

-- 创建Course表（课程表）
CREATE TABLE Course (
    Cno VARCHAR(20) PRIMARY KEY,          
    Cname VARCHAR(100) NOT NULL,          
    Cpno VARCHAR(20),                     
    Ccredit INT CHECK (Ccredit > 0),      
    Semester INT                          
);

-- 创建SC表（选课表）
CREATE TABLE SC (
    Sno VARCHAR(20),                      
    Cno VARCHAR(20),                      
    Grade DECIMAL(5,2) CHECK (Grade >= 0 AND Grade <= 100),  
    PRIMARY KEY (Sno, Cno),
    FOREIGN KEY (Sno) REFERENCES Student(Sno),
    FOREIGN KEY (Cno) REFERENCES Course(Cno)
);

-- ==========================================
-- 第二步：插入数据
-- ==========================================

-- 插入Student表数据
INSERT INTO Student (Sno, Sname, Ssex, Sage, Sdept) VALUES
('S001', '张伟', '男', 20, 'CS'),
('S002', '李晨', '女', 19, 'CS'),
('S003', '王晨阳', '男', 21, 'MA'),
('S004', '刘芳', '女', 20, 'IS'),
('S005', '陈晨', '女', 22, 'CS'),
('S006', '杨明', '男', 19, 'MA'),
('S007', '李明', '男', 23, 'IS'),
('S008', '赵晨曦', '女', 20, 'CS'),
('S009', '邱杰', '男', 21, 'CS'),
('S010', '周丽', '女', 19, 'MA'),
('S011', '吴刚', '男', 22, 'IS'),
('S012', '孙晨光', '男', 20, 'MA'),
('S013', '朱小红', '女', 21, 'CS'),
('S014', '李娜', '女', 19, 'IS'),
('S015', '钱伟', '男', 24, 'CS'),
('S016', '黄晨宇', '男', 20, 'MA'),
('S017', '林芳', '女', 21, 'IS'),
('S018', '张晨', '女', 19, 'CS'),
('S019', '李强', '男', 22, 'MA'),
('S020', '王红', '女', 20, 'IS');

-- 插入Course表数据
INSERT INTO Course (Cno, Cname, Cpno, Ccredit, Semester) VALUES
('1', '高等数学', NULL, 4, 1),
('2', '线性代数', '1', 3, 2),
('3', '概率论', '1', 3, 3),
('4', '离散数学', NULL, 3, 1),
('5', '程序设计基础', NULL, 4, 1),
('6', '数据结构', '5', 4, 2),
('7', '数据库原理', '6', 4, 3),
('8', '操作系统', '6', 3, 3),
('C001', '计算机文化基础', NULL, 2, 1),
('C002', '电子商务基础', 'C001', 3, 2),
('C003', '数据挖掘', '6', 3, 4),
('C004', '数据分析', '1', 2, 3),
('C005', '计算机网络', '5', 3, 2),
('C006', '软件工程', '5', 3, 3),
('C007', '人工智能', '6', 4, 4);

-- 插入SC表数据（选课成绩表）
INSERT INTO SC (Sno, Cno, Grade) VALUES
('S001', '1', 85.5),
('S001', '2', 90.0),
('S001', 'C001', 88.0),
('S001', 'C002', 92. 0),
('S001', '5', 87.0),
('S002', '1', 78.0),
('S002', '2', 91.5),
('S002', 'C001', 95.0),
('S002', 'C002', 89.0),
('S002', '4', 83.0),
('S003', '1', 92.0),
('S003', '2', 88.0),
('S003', '3', 85.0),
('S003', 'C001', 87.0),
('S004', '1', 88.0),
('S004', 'C001', 90.0),
('S004', 'C002', 94.0),
('S004', '5', 91.0),
('S004', '6', 86.0),
('S005', '2', 93.0),
('S005', 'C001', 88.5),
('S005', 'C002', 90.5),
('S005', '6', 89.0),
('S005', '7', 92.0),
('S006', '1', 76.0),
('S006', '2', 80.0),
('S006', '3', 82.0),
('S007', 'C001', 91.0),
('S007', 'C002', 88.0),
('S007', '5', 85.0),
('S007', '6', 87.0),
('S008', '1', 89.0),
('S008', '2', 92.0),
('S008', 'C001', 96.0),
('S008', 'C002', 93.5),
('S008', '5', 90.0),
('S009', '1', 87.0),
('S009', '2', 89.5),
('S009', 'C001', 92.0),
('S009', '5', 88.0),
('S009', '6', 91.0),
('S010', '1', 84.0),
('S010', '2', 86.0),
('S010', 'C001', 83.0),
('S011', 'C001', 87.0),
('S011', 'C002', 85.0),
('S011', '4', 88.0),
('S011', '5', 86.0),
('S012', '1', 90.0),
('S012', '2', 88.5),
('S012', '3', 86.0),
('S012', 'C001', 89.0),
('S013', '2', 94.0),
('S013', 'C001', 91.0),
('S013', 'C002', 95.5),
('S013', '6', 90.0),
('S013', '7', 88.0),
('S014', '1', 82.0),
('S014', 'C001', 85.0),
('S014', 'C002', 87.0),
('S014', '5', 84.0),
('S015', '2', 91.0),
('S015', '5', 89.0),
('S015', '6', 92.0),
('S015', '7', 90.0),
('S015', '8', 88.0),
('S016', '1', 79.0),
('S016', '2', 81.0),
('S016', 'C001', 80.0),
('S017', 'C001', 93.0),
('S017', 'C002', 91.0),
('S017', '5', 87.0),
('S017', '6', 89.0),
('S018', '1', 86.0),
('S018', '2', 88.0),
('S018', 'C001', 92.0),
('S018', 'C002', 90. 0),
('S018', '5', 85.0),
('S019', '1', 83.0),
('S019', '2', 85.0),
('S019', '3', 84.0),
('S019', 'C001', 86. 0),
('S020', 'C001', 89.0),
('S020', 'C002', 92.0),
('S020', '4', 87.0),
('S020', '5', 90.0);

-- ==========================================
-- 验证数据导入成功
-- ==========================================

-- 验证1：查看Student表数据 (应返回20行)
SELECT COUNT(*) AS '学生总数' FROM Student;

-- 验证2：查看Course表数据 (应返回15行)
SELECT COUNT(*) AS '课程总数' FROM Course;

-- 验证3：查看SC表数据 (应返回98行)
SELECT COUNT(*) AS '选课记录总数' FROM SC;


-- ==========================================
-- （一）简单查询 - 共12题
-- ==========================================

-- 【题目1】查询所有学生的基本信息
SELECT * FROM Student;

-- 【题目2】查询学生学号、姓名和年龄
SELECT Sno, Sname, Sage FROM Student;

-- 【题目3】查询课程号为1的课程信息
SELECT Cname, Cpno FROM Course WHERE Cno = '1';

-- 【题目4】查询先行课为6的课程
SELECT Cno, Cname, Ccredit FROM Course WHERE Cpno = '6';

-- 【题目5】查询先行课为空的课程
SELECT Cno, Cname FROM Course WHERE Cpno IS NULL;

-- 【题目6】查询课程2成绩在88-95之间的学生
SELECT Sno, Grade FROM SC 
WHERE Cno = '2' AND Grade BETWEEN 88 AND 95
ORDER BY Grade DESC;

-- 【题目7】查询课程名以"数据"开始的课程
SELECT Cno, Cname, Ccredit FROM Course 
WHERE Cname LIKE '数据%'
ORDER BY Cno;

-- 【题目8】查询名字第二个字为"晨"的学生
SELECT Sno, Sname, Ssex FROM Student 
WHERE Sname LIKE '_晨%'
ORDER BY Sno;

-- 【题目9】查询女生或姓李的学生
SELECT Sno, Sname, Ssex FROM Student 
WHERE Ssex = '女' OR Sname LIKE '李%'
ORDER BY Sno;

-- 【题目10】查询CS系学生信息和出生年份
SELECT Sno, Sname, Ssex, YEAR(CURDATE())-Sage AS '出生年份' 
FROM Student WHERE Sdept = 'CS'
ORDER BY Sno;

-- 【题目11】查询三个系的学生
SELECT Sno, Sname, Sdept FROM Student 
WHERE Sdept IN ('MA', 'IS', 'CS')
ORDER BY Sdept, Sno;

-- 【题目12】查询课程表前6条数据
SELECT * FROM Course LIMIT 6;


-- ==========================================
-- （二）数据统计查询 - 共10题
-- ==========================================

-- 【题目1】课程表按课程名排序
SELECT * FROM Course ORDER BY Cname ASC;

-- 【题目2】统计课程总数
SELECT COUNT(*) AS '课程总数' FROM Course;

-- 【题目3】查询最高成绩
SELECT MAX(Grade) AS '最高成绩' FROM SC;

-- 【题目4】查询最低成绩
SELECT MIN(Grade) AS '最低成绩' FROM SC;

-- 【题目5】查询平均成绩
SELECT AVG(Grade) AS '平均成绩' FROM SC;

-- 【题目6】查询每门课程选课人数
SELECT Cno, COUNT(*) AS '选课人数' 
FROM SC GROUP BY Cno
ORDER BY Cno;

-- 【题目7】查询每位学生平均成绩
SELECT Sno, AVG(Grade) AS '平均成绩' 
FROM SC GROUP BY Sno
ORDER BY '平均成绩' DESC;

-- 【题目8】查询选修2门及以上课程的学生
SELECT Sno, COUNT(*) AS '课程数' FROM SC 
GROUP BY Sno HAVING COUNT(*) >= 2
ORDER BY '课程数' DESC;

-- 【题目9】查询不同学分的课程门数
SELECT Ccredit AS '学分', COUNT(*) AS '课程门数' 
FROM Course GROUP BY Ccredit
ORDER BY Ccredit;

-- 【题目10】查询各系学生数量
SELECT Sdept AS '系别', COUNT(*) AS '学生数' FROM Student 
GROUP BY Sdept
ORDER BY '学生数' DESC;


-- ==========================================
-- （三）连接查询 - 共12题
-- ==========================================

-- 【题目1】学生及其选课情况（左连接）
SELECT s.Sno, s. Sname, sc.Cno, sc.Grade 
FROM Student s 
LEFT JOIN SC sc ON s. Sno = sc.Sno
ORDER BY s.Sno, sc.Cno;

-- 【题目2】课程及其选课情况（左连接）
SELECT c. Cno, c.Cname, sc. Sno, sc.Grade 
FROM Course c 
LEFT JOIN SC sc ON c.Cno = sc.Cno
ORDER BY c.Cno, sc. Sno;

-- 【题目3】学生选课详细信息
SELECT s.Sno, s.Sname, s. Ssex, s.Sdept, sc.Cno, c.Cname, sc.Grade
FROM Student s 
JOIN SC sc ON s.Sno = sc.Sno 
JOIN Course c ON sc. Cno = c.Cno
ORDER BY s.Sno, sc.Cno;

-- 【题目4】选修C002且成绩>90的学生
SELECT s. Sno, s.Sname, sc.Grade
FROM Student s 
JOIN SC sc ON s.Sno = sc.Sno 
WHERE sc.Cno = 'C002' AND sc.Grade > 90
ORDER BY sc.Grade DESC;

-- 【题目5】选修"电子商务基础"的学生信息
SELECT s.Sno, s.Sname, s.Sdept, c.Cname, sc.Grade
FROM Student s 
JOIN SC sc ON s.Sno = sc.Sno 
JOIN Course c ON sc. Cno = c.Cno 
WHERE c.Cname = '电子商务基础'
ORDER BY sc.Grade DESC;

-- 【题目6】同时选修C001和C002的学生
SELECT a.Sno FROM SC a
INNER JOIN SC b ON a.Sno = b.Sno 
WHERE a.Cno = 'C001' AND b.Cno = 'C002'
ORDER BY a.Sno;

-- 【题目7】学生及选课情况（左外连接）
SELECT s. Sno, s.Sname, s.Sdept, sc.Cno, sc.Grade
FROM Student s 
LEFT JOIN SC sc ON s.Sno = sc.Sno
ORDER BY s.Sno, sc.Cno;

-- 【题目8】课程及学生选课（左外连接）
SELECT c. Cno, c.Cname, sc.Sno, sc.Grade
FROM Course c 
LEFT JOIN SC sc ON c. Cno = sc.Cno
ORDER BY c.Cno, sc.Sno;

-- 【题目9】学生及选课情况（右外连接）
SELECT s. Sno, s.Sname, s.Sdept, sc.Cno, sc.Grade
FROM Student s 
RIGHT JOIN SC sc ON s.Sno = sc.Sno
ORDER BY s.Sno, sc.Cno;

-- 【题目10】课程及学生选课（右外连接）
SELECT c. Cno, c.Cname, sc.Sno, sc.Grade
FROM Course c 
RIGHT JOIN SC sc ON c. Cno = sc.Cno
ORDER BY c.Cno, sc.Sno;

-- 【题目11】女生成绩信息
SELECT s.Sno, s.Sname, sc. Cno, c.Cname, sc.Grade
FROM Student s 
JOIN SC sc ON s.Sno = sc.Sno 
JOIN Course c ON sc.Cno = c.Cno
WHERE s.Ssex = '女'
ORDER BY s.Sno, sc.Grade DESC;

-- 【题目12】每门课程总分和平均分（总分>100）
SELECT c.Cno, c.Cname, COUNT(*) AS '选课人数', 
       SUM(sc.Grade) AS '总分', AVG(sc.Grade) AS '平均分'
FROM Course c 
JOIN SC sc ON c.Cno = sc.Cno 
GROUP BY c.Cno, c.Cname 
HAVING SUM(sc.Grade) > 100
ORDER BY '总分' DESC;


-- ==========================================
-- （四）嵌套查询 - 共12题
-- ==========================================

-- 【题目1】与"邱杰"同学院的学生
SELECT Sno, Sname, Ssex, Sdept FROM Student 
WHERE Sdept = (SELECT Sdept FROM Student WHERE Sname = '邱杰')
ORDER BY Sno;

-- 【题目2】与"计算机文化基础"同学期的课程
SELECT Cno, Cname, Semester, Ccredit FROM Course 
WHERE Semester = (SELECT Semester FROM Course WHERE Cname = '计算机文化基础')
ORDER BY Cno;

-- 【题目3】女生的选课成绩
SELECT Sno, Cno, Grade FROM SC 
WHERE Sno IN (SELECT Sno FROM Student WHERE Ssex = '女')
ORDER BY Sno, Cno;

-- 【题目4】选修C001课程的学生
SELECT Sno, Sname, Sdept FROM Student 
WHERE Sno IN (SELECT Sno FROM SC WHERE Cno = 'C001')
ORDER BY Sno;

-- 【题目5】选修"电子商务基础"的学生
SELECT Sno, Sname, Sdept FROM Student 
WHERE Sno IN (SELECT Sno FROM SC WHERE Cno = 
    (SELECT Cno FROM Course WHERE Cname = '电子商务基础'))
ORDER BY Sno;

-- 【题目6】选修第二学期课程的学生
SELECT DISTINCT s.Sno, s. Sname, s.Ssex, s.Sdept FROM Student s
WHERE s.Sno IN (SELECT Sno FROM SC WHERE Cno IN 
    (SELECT Cno FROM Course WHERE Semester = 2))
ORDER BY s.Sno;

-- 【题目7】超过个人平均成绩的选课记录
SELECT sc1.Sno, sc1. Cno, sc1.Grade
FROM SC sc1
WHERE sc1.Grade > (
    SELECT AVG(sc2. Grade) 
    FROM SC sc2 
    WHERE sc2.Sno = sc1.Sno
)
ORDER BY sc1. Sno, sc1.Grade DESC;

-- 【题目8】其他学院比计算机学院所有学生年龄都大的学生
SELECT * FROM Student 
WHERE Sdept != 'CS' AND Sage > ALL(
    SELECT Sage FROM Student WHERE Sdept = 'CS'
)
ORDER BY Sage DESC;

-- 【题目9】其他学院比计算机学院某个学生年龄小的学生
SELECT * FROM Student 
WHERE Sdept != 'CS' AND Sage < ANY(
    SELECT Sage FROM Student WHERE Sdept = 'CS'
)
ORDER BY Sage;

-- 【题目10】使用EXISTS查询选修C001的学生
SELECT Sno, Sname, Sdept FROM Student s
WHERE EXISTS (
    SELECT 1 FROM SC WHERE Sno = s.Sno AND Cno = 'C001'
)
ORDER BY Sno;

-- 【题目11】使用NOT EXISTS查询未选修C001的学生
SELECT Sno, Sname, Sdept FROM Student s
WHERE NOT EXISTS (
    SELECT 1 FROM SC WHERE Sno = s.Sno AND Cno = 'C001'
)
ORDER BY Sno;

-- 【题目12】查询选修课程最多的学生
SELECT Sno, COUNT(*) AS '课程数' FROM SC
GROUP BY Sno
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*) FROM SC GROUP BY Sno
)
ORDER BY Sno;