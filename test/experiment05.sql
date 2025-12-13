 
-- =================================================================================================================
use liuq;
DROP TABLE IF EXISTS sc;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;

-- -----------------------------------------------------
-- 创建表1：学生表 student
-- -----------------------------------------------------
create table Student( 
   Sno    CHAR(9)  PRIMARY KEY,
   Sname  CHAR(20) NOT NULL,     
   Ssex   CHAR(2) CHECK (Ssex IN ('男','女')),
   Sage   SMALLINT CHECK (Sage > 0 AND Sage < 100),
   Sdept  CHAR(20)
);
insert into student(sname,ssex,sno, sage, sdept) values
		('李勇','男','200215121',20,'CS'),
		('刘晨','女','200215122',19,'CS'),
		('王敏','女','200215123',18,'MA'),
		('张立','男','200215125',19,'IS');
select * from student;

-- -----------------------------------------------------
-- 创建表2：课程表 course（关键：Cno 改为 CHAR(4)，与 SC 表完全匹配）
-- -----------------------------------------------------
create table course(
		cno     CHAR(4)  PRIMARY KEY COMMENT '课程号',  
		cname   CHAR(20) COMMENT '课程名',
		cpno    CHAR(4)  COMMENT '先行课',  
		ccredit SMALLINT COMMENT '学分'
);
insert into course(cno,cname,cpno,ccredit) values
		('6','数据处理',null,2),
		('2','数学',null,2),
		('7','PASCAL语言','6',4),
		('5','数据结构','7',4),
		('1','数据库','5',4),
		('3','信息系统','1',4),
		('4','操作系统','6',3);
select * from course;

-- -----------------------------------------------------
-- 创建表3：学生选课成绩表 sc（彻底解决语法报错）
-- -----------------------------------------------------
CREATE TABLE SC (
    Sno    CHAR(9)  NOT NULL COMMENT '学号',
    Cno    CHAR(4)  NOT NULL COMMENT '课程号',  
    Grade  SMALLINT CHECK (Grade BETWEEN 0 AND 100) COMMENT '成绩' , 
    PRIMARY KEY (Sno, Cno), 
    FOREIGN KEY (Sno) REFERENCES student(Sno),    
    FOREIGN KEY (Cno) REFERENCES course(Cno)
);  
insert into sc(sno,cno,grade) values
	('200215121','1',92),
	('200215121','2',85),
	('200215121','3',88),
	('200215122','2',90),
	('200215122','3',80);
select * from sc;

-- -----------------------------------------------------
-- 通用日志表：存储所有触发器的执行记录
-- -----------------------------------------------------
DROP TABLE IF EXISTS trigger_log;
CREATE TABLE trigger_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    trigger_name VARCHAR(50) NOT NULL, -- 触发器名称
    operate_table VARCHAR(20) NOT NULL,-- 操作的表名
    operate_type VARCHAR(10) NOT NULL,-- 操作类型（INSERT/UPDATE/DELETE）
    operate_time DATETIME DEFAULT CURRENT_TIMESTAMP,-- 操作时间
    detail VARCHAR(100) -- 操作详情
);


-- 实验前置说明
-- 所有案例基于已创建的 student（学生表）、course（课程表）、sc（选课表），新增通用日志表 trigger_log 用于存储触发记录（避免重复创建表）：
/*******************************************************************************************************************************************
第1关：INSERT 型触发器（学生选课日志）
向 sc 表插入选课记录时，自动在 trigger_log 中记录 “学生 XXX（学号 XXX）选了 XXX 课程（课程号 XXX）” 的日志。
*******************************************************************************************************************************************/
DELIMITER $$
DROP TRIGGER IF EXISTS sc_insert_log;
CREATE TRIGGER sc_insert_log
AFTER INSERT ON sc
FOR EACH ROW
BEGIN
    -- 拼接日志详情（关联student和course表的真实数据）
    INSERT INTO trigger_log (trigger_name, operate_table, operate_type, detail)
    VALUES (
        'sc_insert_log',
        'sc',
        'INSERT',
        CONCAT(
            '学生', (SELECT sname FROM student WHERE sno = NEW.sno), 
            '(学号', NEW.sno, ')选了', 
            (SELECT cname FROM course WHERE cno = NEW.cno), 
            '(课程号', NEW.cno, ')'
        )
    );
END $$
DELIMITER ;

-- delimiter $$
-- drop trigger if exists  sc_insert_log;
-- create trigger sc_insert_log
-- after insert on sc
-- for each row 
-- begin 
-- insert into trigger_log (trigger_name, operate_table, operate_type, detail)
--     values (
--         'sc_insert_log',
--         'sc',
--         'insert',
--         concat(
            

-- 测试代码（插入真实学生的选课记录）
INSERT INTO sc (sno, cno, grade) VALUES ('200215123', '1', 85); -- 王敏（200215123）选数据库（课程号1）
INSERT INTO sc (sno, cno, grade) VALUES ('200215125', '5', 90); -- 张立（200215125）选数据结构（课程号5）

-- 查看触发结果
SELECT * FROM trigger_log WHERE trigger_name = 'sc_insert_log';

/*******************************************************************************************************************************************
第2关：UPDATE 型触发器（学生年龄校验）
更新 student 表的学生年龄时，若新年龄小于 15 或大于 40，自动将年龄修正为 20，并在 trigger_log 中记录 “学号 XXX 的年龄输入无效，已修正为 20”。
*******************************************************************************************************************************************/

DELIMITER $$
DROP TRIGGER IF EXISTS student_age_check;
CREATE TRIGGER student_age_check
BEFORE UPDATE ON student
FOR EACH ROW
BEGIN
    IF NEW.sage < 15 OR NEW.sage > 40 THEN
        SET NEW.sage = 20; -- 修正无效年龄
        -- 记录日志（关联真实学生信息）
        INSERT INTO trigger_log (trigger_name, operate_table, operate_type, detail)
        VALUES (
            'student_age_check',
            'student',
            'UPDATE',
            CONCAT('学生', NEW.sname, '(学号', NEW.sno, ')的年龄输入无效，已修正为20')
        );
    END IF;
END $$
DELIMITER ;

-- delimiter $$
-- drop trigger if exists student_age_check;
-- create trigger student_age_check
-- before update on student
-- for each row 
-- begin 
-- if new.sage < 15 or new.sage > 40 then 
-- set new.sage = 20;
-- insert into trigger_log(trigger_name,operate_table,operate_type,detail)
-- values (
-- 'student_age_check',
-- 'student',
-- 'update',
-- concat()
-- end if
-- end $$
-- delimiter ;

-- 测试代码（更新真实学生的年龄）
UPDATE student SET sage = 14 WHERE sno = '200215121'; -- 李勇（200215121）年龄改为14（无效）
UPDATE student SET sage = 45 WHERE sno = '200215122'; -- 刘晨（200215122）年龄改为45（无效）

-- 验证结果
SELECT sno, sname, sage FROM student WHERE sno IN ('200215121', '200215122');

SELECT *FROM trigger_log WHERE trigger_name = 'student_age_check';
/*******************************************************************************************************************************************
第3关：DELETE 型触发器（删除课程级联日志）
删除 course 表的课程记录时，自动在 trigger_log 中记录 “课程 XXX（课程号 XXX）已删除，关联选课记录共 XXX 条”（统计该课程的选课数）。
*******************************************************************************************************************************************/
DELIMITER $$
DROP TRIGGER IF EXISTS course_delete_log;
CREATE TRIGGER course_delete_log
BEFORE DELETE ON course
FOR EACH ROW
BEGIN
    -- 统计该课程的真实选课记录数
    DECLARE sc_count INT;
    SELECT COUNT(*) INTO sc_count FROM sc WHERE cno = OLD.cno;
    
    -- 记录日志（关联真实课程信息）
    INSERT INTO trigger_log (trigger_name, operate_table, operate_type, detail)
    VALUES (
        'course_delete_log',
        'course',
        'DELETE',
        CONCAT(
            '课程', OLD.cname, '(课程号', OLD.cno, ')已删除，关联选课记录共',
            sc_count, '条'
        )
    );
END $$
DELIMITER ;
-- 
--     declare sc_count int;
--     select count(*) into sc_count from sc where cno = old.cno;
--     
--     insert into trigger_log(trigger_name, operate_table, operate_type, detail)
--     values (
--         'course_delete_log',
--         'course',
--         'delete',
--         concat(
-- 
-- 测试代码（删除真实课程）
DELETE FROM course WHERE cno = '3'; -- 删除“信息系统”（课程号3，初始有2条选课记录：李勇、刘晨）

-- 验证结果
SELECT * FROM trigger_log WHERE trigger_name = 'course_delete_log';

/*******************************************************************************************************************************************
第4关：INSERT 型触发器（选课成绩默认值）
向 sc 表插入选课记录时，若未指定成绩（grade 为 NULL），自动设置成绩为 60 分，并在 trigger_log 中记录 “学号 XXX 选课程 XXX 未填成绩，默认设为 60”。
*******************************************************************************************************************************************/
DELIMITER $$
DROP TRIGGER IF EXISTS sc_grade_default;
CREATE TRIGGER sc_grade_default
BEFORE INSERT ON sc
FOR EACH ROW
BEGIN
    IF NEW.grade IS NULL THEN
        SET NEW.grade = 60; -- 默认成绩60分
        -- 记录日志（关联真实数据）
        INSERT INTO trigger_log (trigger_name, operate_table, operate_type, detail)
        VALUES (
            'sc_grade_default',
            'sc',
            'INSERT',
            CONCAT(
                '学生', (SELECT sname FROM student WHERE sno = NEW.sno), 
                '(学号', NEW.sno, ')选了', 
                (SELECT cname FROM course WHERE cno = NEW.cno), 
                '(课程号', NEW.cno, ')，未填成绩默认设为60'
            )
        );
    END IF;
END $$
DELIMITER ;

-- 测试代码（插入无成绩的选课记录）
INSERT INTO sc (sno, cno) VALUES ('200215125', '2'); -- 张立（200215125）选数学（课程号2），不填成绩

-- 验证结果
SELECT * FROM sc WHERE sno = '200215125' AND cno = '2';
SELECT * FROM trigger_log WHERE trigger_name = 'sc_grade_default';

/*******************************************************************************************************************************************
第5关：UPDATE 型触发器（课程先行课校验）
更新 course 表的先行课（cpno）时，若指定的先行课编号在 course 表中不存在，禁止更新，并在 trigger_log 中记录 “课程 XXX（课程号 XXX）更新先行课 XXX 失败：先行课不存在”。
*******************************************************************************************************************************************/
DELIMITER $$
DROP TRIGGER IF EXISTS course_cpno_check;
CREATE TRIGGER course_cpno_check
BEFORE UPDATE ON course
FOR EACH ROW
BEGIN
    -- 校验先行课是否存在（排除NULL情况，因为允许无先行课）
    IF NEW.cpno IS NOT NULL AND NOT EXISTS (SELECT 1 FROM course WHERE cno = NEW.cpno) THEN
        -- 记录日志（关联真实课程信息）
        INSERT INTO trigger_log (trigger_name, operate_table, operate_type, detail)
        VALUES (
            'course_cpno_check',
            'course',
            'UPDATE',
            CONCAT(
                '课程', OLD.cname, '(课程号', OLD.cno, 
                ')更新先行课', NEW.cpno, '失败：先行课不存在'
            )
        );
        -- 抛出错误，终止更新
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '先行课编号不存在，更新失败';
    END IF;
END $$
DELIMITER ;

-- 测试代码（更新真实课程的先行课）
UPDATE course SET cpno = '99' WHERE cno = '5'; -- 数据结构（课程号5）的先行课改为99（不存在）
UPDATE course SET cpno = '8' WHERE cno = '2'; -- 数学（课程号2）的先行课改为8（不存在）

-- 验证结果
SELECT * FROM trigger_log WHERE trigger_name = 'course_cpno_check';
SELECT cno, cname, cpno FROM course WHERE cno IN ('5', '2'); -- 课程信息未变更


/*******************************************************************************************************************************************
第6关：DELETE 型触发器（学生删除级联选课记录）
删除 student 表的学生记录时，自动删除该学生在 sc 表中的所有选课记录，并在 trigger_log 中记录 “学号 XXX（姓名 XXX）已删除，同步删除选课记录 XXX 条”。
*******************************************************************************************************************************************/
DELIMITER $$
DROP TRIGGER IF EXISTS student_delete_cascade_sc;
CREATE TRIGGER student_delete_cascade_sc
BEFORE DELETE ON student
FOR EACH ROW
BEGIN
    -- 统计该学生的真实选课数
    DECLARE sc_count INT;
    SELECT COUNT(*) INTO sc_count FROM sc WHERE sno = OLD.sno;
    
    -- 级联删除选课记录
    DELETE FROM sc WHERE sno = OLD.sno;
    
    -- 记录日志（关联真实学生信息）
    INSERT INTO trigger_log (trigger_name, operate_table, operate_type, detail)
    VALUES (
        'student_delete_cascade_sc',
        'student',
        'DELETE',
        CONCAT(
            '学生', OLD.sname, '(学号', OLD.sno, 
            ')已删除，同步删除选课记录', sc_count, '条'
        )
    );
END $$
DELIMITER ;

-- 测试代码（删除真实学生）
DELETE FROM student WHERE sno = '200215123'; -- 删除王敏（200215123），初始有1条选课记录

-- 验证结果
SELECT * FROM sc WHERE sno = '200215123'; -- 选课记录已删除
SELECT * FROM trigger_log WHERE trigger_name = 'student_delete_cascade_sc';

-- =================================================================================================================
-- END
-- =================================================================================================================