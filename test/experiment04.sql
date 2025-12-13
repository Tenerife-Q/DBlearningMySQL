-- 实验四：综合性测试实验 - 完整SQL语句文件

-- =============================================
-- 第一部分：数据库和表结构创建
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS comprehensive_test;
USE comprehensive_test;

-- 创建Student表
CREATE TABLE Student (
    Sno CHAR(5) PRIMARY KEY,
    Sname CHAR(10),
    Ssex CHAR(2),
    Sage INT,
    Sdept CHAR(2)
);

-- 创建Teacher表
CREATE TABLE Teacher (
    Tno CHAR(3) PRIMARY KEY,
    Tname CHAR(10),
    Tsex CHAR(2),
    Tdept CHAR(2)
);

-- 创建Project表
CREATE TABLE Project (
    Pno CHAR(5) PRIMARY KEY,
    Pname CHAR(20),
    Tno CHAR(5)
);

-- 创建SP表
CREATE TABLE SP (
    Sno CHAR(5),
    Pno CHAR(5),
    Grade INT,
    PRIMARY KEY (Sno, Pno)
);

-- =============================================
-- 第二部分：数据插入
-- =============================================

-- 插入Student数据
INSERT INTO Student VALUES
('23121', '韩刚', '男', 20, 'CS'),
('23122', '刘心语', '女', 19, 'CS'),
('23123', '苏倩', '女', 19, 'CS'),
('23124', '潘佳慧', '女', 19, 'CS'),
('23125', '邓辉', '男', 20, 'CS'),
('23126', '肖馨玥', '女', 19, 'CS'),
('23127', '薛志超', '男', 20, 'CS'),
('23128', '迪丽', '女', 19, 'CS');

-- 插入Teacher数据
INSERT INTO Teacher VALUES
('101', '梁任甫', '男', 'CS'),
('102', '陈鹤寿', '男', 'CS'),
('103', '王静安', '女', 'MA'),
('104', '赵宜仲', '男', 'IS');

-- 插入Project数据
INSERT INTO Project VALUES
('1', '数据库设计项目', '101'),
('2', '无人机飞行设计项目', '103'),
('3', '校园网络规划项目', '102'),
('4', '操作系统设计项目', '101'),
('5', '视觉处理项目', '102'),
('6', '大模型构建项目', '104');

-- 插入SP数据
INSERT INTO SP VALUES
('23121', '3', 88),
('23122', '1', 75),
('23122', '2', 90),
('23122', '3', 80),
('23122', '4', 80),
('23122', '5', 68),
('23122', '6', 90),
('23123', '1', 92),
('23124', '2', 85),
('23125', '5', 94),
('23126', '3', 88),
('23127', '4', 89),
('23128', '1', 88),
('23128', '4', 81),
('23201', '1', 92),
('23202', '1', 92),
('23202', '6', 77),
('23203', '2', 79),
('23204', '4', 85),
('23205', '3', 99),
('23206', '5', 58),
('23321', '1', 55),
('23321', '6', 81),
('23322', '2', 75),
('23322', '6', 89);

-- =============================================
-- 第三部分：网关任务查询
-- =============================================

-- 1. 查询参与3号项目的学生学号与该课程成绩
SELECT Sno, Grade 
FROM SP 
WHERE Pno = '3';

-- 2. 查询负责项目名为无人机飞行设计项目的教师姓名
SELECT T.Tname
FROM Teacher T
JOIN Project P ON T.Tno = P.Tno
WHERE P.Pname = '无人机飞行设计项目';

-- 3. 查询没有参与2号项目的学生姓名与专业
SELECT S.Sname, S.Sdept
FROM Student S
WHERE S.Sno NOT IN (
    SELECT Sno FROM SP WHERE Pno = '2'
);

-- 4. 查询参加了所有项目的学生姓名
SELECT S.Sname
FROM Student S
WHERE NOT EXISTS (
    SELECT Pno FROM Project P
    WHERE NOT EXISTS (
        SELECT * FROM SP 
        WHERE SP.Sno = S.Sno AND SP.Pno = P.Pno
    )
);

-- 5. 查询参加一个项目的学生的学号
SELECT Sno
FROM SP
GROUP BY Sno
HAVING COUNT(Pno) = 1;

-- 6. 查询所有项目成绩均及格的学生的学号和平均成绩，按平均成绩降序排列
-- 使用HAVING MIN(Grade)方法，性能更好
SELECT Sno, AVG(Grade) as 平均成绩
FROM SP
GROUP BY Sno
HAVING MIN(Grade) >= 60
ORDER BY 平均成绩 DESC;


-- 使用in不能保证所有成绩都及格
select Sno, avg(Grade) as AvgGrade
from sp 
where Sno not in(
    select distinct Sno from sp where Grade < 60
)
group by Sno
order by AvgGrade DESC;

-- 7. 查询参与1号项目，且成绩排名第2的学生姓名
-- 实现max的函数 但是是从怎么样的一个范围 去掉第一个的最大 就是第二大
select s.Sname 
from Student s
join SP sp on s.Sno = sp.Sno
where sp.Sno = '1' and 
sp.Grade = (select max(Grade) from sp where Pno = '1' and 
Grade < (select max(Grade) from sp where Pno = '1' ));


-- 使用DENSE_RANK()窗口函数，完全符合题目要求
SELECT Sname
FROM Student
WHERE Sno IN (
    SELECT Sno FROM (
        SELECT Sno, DENSE_RANK() OVER (ORDER BY Grade DESC) as rank_num
        FROM SP 
        WHERE Pno = '1'
    ) ranked
    WHERE rank_num = 2
);

-- 8. 把4号项目的成绩降低5%
UPDATE SP 
SET Grade = Grade * 0.95 
WHERE Pno = '4';

-- 9. 在Project表和SP表中删除项目号为5的所有数据
DELETE FROM SP WHERE Pno = '5';
DELETE FROM Project WHERE Pno = '5';

-- 10. 建立女学生的视图
CREATE VIEW FemaleStudentView AS
SELECT S.Sno, S.Sname, P.Pname, SP.Grade
FROM Student S
JOIN SP ON S.Sno = SP.Sno
JOIN Project P ON SP.Pno = P.Pno
WHERE S.Ssex = '女';


create view FamaleStudentView as 
select *
from Student s 
join SP sp on s.Sno = sp.Sno 
join Project p on sp.Sno = p.Sno
where s.Ssex = '女';

-- 11. 在女生视图中查询平均成绩大于80分的学生学号与姓名
SELECT Sno, Sname
FROM FemaleStudentView
GROUP BY Sno, Sname
HAVING AVG(Grade) > 80;

-- 12. 建立成绩视图
CREATE VIEW GradeView AS
SELECT Sno, 
       COUNT(Pno) as ProjectCount,
       AVG(Grade) as AvgGrade
FROM SP
GROUP BY Sno;

-- 13. 使用GRANT语句授权（注意：需要先创建cut用户）
-- GRANT ALL PRIVILEGES ON SP TO 'cut'@'localhost';
-- GRANT SELECT ON Student TO 'cut'@'localhost';
-- GRANT SELECT ON Project TO 'cut'@'localhost';
-- GRANT SELECT ON Teacher TO 'cut'@'localhost';

-- =============================================
-- 第四部分：选做任务
-- =============================================

-- 14. 创建级联更新触发器
-- 首先需要确保有外键约束
ALTER TABLE SP ADD CONSTRAINT fk_sp_student 
FOREIGN KEY (Sno) REFERENCES Student(Sno);

-- 创建触发器
DELIMITER //
CREATE TRIGGER UpdateStudentCascade
AFTER UPDATE ON Student
FOR EACH ROW
BEGIN
    IF OLD.Sno != NEW.Sno THEN
        UPDATE SP SET Sno = NEW.Sno WHERE Sno = OLD.Sno;
    END IF;
END//
DELIMITER ;

-- 15. 创建限制学生数量的触发器
DELIMITER //
CREATE TRIGGER LimitStudentCount
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
    DECLARE student_count INT;
    SELECT COUNT(*) INTO student_count FROM Student;
    IF student_count >= 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '学生数量不能超过18个';
    END IF;
END//
DELIMITER ;

-- 16. 创建成绩修改日志触发器
-- 首先创建日志表
CREATE TABLE SC_log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    Sno CHAR(5),
    Pno CHAR(5),
    OldGrade INT,
    NewGrade INT,
    ChangeTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建触发器
DELIMITER //
CREATE TRIGGER GradeUpdateLog
BEFORE UPDATE ON SP
FOR EACH ROW
BEGIN
    IF OLD.Grade != NEW.Grade THEN
        INSERT INTO SC_log (Sno, Pno, OldGrade, NewGrade)
        VALUES (OLD.Sno, OLD.Pno, OLD.Grade, NEW.Grade);
    END IF;
END//
DELIMITER ;

-- =============================================
-- 第五部分：清理工作（实验完成后执行）
-- =============================================

-- 删除触发器
DROP TRIGGER IF EXISTS UpdateStudentCascade;
DROP TRIGGER IF EXISTS LimitStudentCount;
DROP TRIGGER IF EXISTS GradeUpdateLog;

-- 删除视图
DROP VIEW IF EXISTS FemaleStudentView;
DROP VIEW IF EXISTS GradeView;

-- 删除表
DROP TABLE IF EXISTS SC_log;
DROP TABLE IF EXISTS SP;
DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Teacher;
DROP TABLE IF EXISTS Student;

-- 删除数据库
DROP DATABASE IF EXISTS comprehensive_test;