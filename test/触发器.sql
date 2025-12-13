use liuq;
DROP TABLE IF EXISTS sc;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS sys_log;
 
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

-- insert into student(sname,ssex,sno, sage, sdept) values ('李勇','男',NULL,20,'CS');    -- 违背实体完整性：不能为空的约束

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
    FOREIGN KEY (Sno) REFERENCES student(Sno) ON DELETE RESTRICT  ON UPDATE CASCADE,    
    FOREIGN KEY (Cno) REFERENCES course(Cno)  ON DELETE RESTRICT ON UPDATE CASCADE
);  
insert into sc(sno,cno,grade) values
	('200215121','1',92),
	('200215121','2',85),
	('200215121','3',88),
	('200215122','2',90),
	('200215122','3',80);
select * from sc;

-- ----------------------------------------------------------------------------------------
-- 第1关: INSERT型触发器
-- ----------------------------------------------------------------------------------------
/*
定义一个insert前触发的触发器，在向表Student插入记录时，表sys_log中content内容为“学生人数”的记录num字段的值自动加一。
*/
-- 第1步：sys_log表的定义
DROP TABLE IF EXISTS sys_log;
create table sys_log(
	id      int auto_increment primary key,  -- 自增主键（可选，用于唯一标识日志记录）
	content char(20) not null unique,        -- 日志内容（唯一索引，确保“学生人数”记录唯一）
	num     int not null default 0          -- 统计数值（学生人数）
 );

-- 第2步：初始化：插入「学生人数」记录，初始值为当前student表的记录数（4条）
INSERT INTO sys_log (content, num)
SELECT '学生人数', (SELECT COUNT(*) FROM student)
ON DUPLICATE KEY UPDATE num = VALUES(num);    -- 能插入就插入，插不了（重复了）就更新
/*************
ON DUPLICATE KEY UPDATE语句是MySQL中用于插入或更新记录的一种方式。
它的主要作用是，如果尝试将一条记录插入到已存在的唯一索引（如主键、唯一约束等）中，则会执行更新操作，而不是插入新记录。
具体来说，当插入数据时，如果发现指定的索引已经存在，则执行UPDATE操作，将新记录的值更新到该索引对应的原有记录上；
否则，执行INSERT操作，插入新记录。
************************/

-- 查看初始化后的 sys_log
SELECT * FROM sys_log;

-- -----------------------------------------------------
-- 第3步：创建INSERT型触发器
-- -----------------------------------------------------
DELIMITER $$ -- 定义语句结束符为$$（避免与触发器内的;冲突）
DROP TRIGGER IF EXISTS update_student_count;
CREATE TRIGGER update_student_count 
BEFORE INSERT 
ON Student
FOR EACH ROW
BEGIN
    -- 核心逻辑：更新「学生人数」的num字段（自增1）
    UPDATE sys_log 
    SET num = num + 1 
    WHERE content = '学生人数';
    
    -- 可选：如果不存在该记录，则自动插入（避免初始化遗漏）
    IF ROW_COUNT() = 0 THEN
        INSERT INTO sys_log (content, num) VALUES ('学生人数', 1);
    END IF;
END $$
DELIMITER ; -- 恢复默认语句结束符（注意DELIMITER后有空格）


-- 第2步：测试 INSERT型触发器
-- 插入1名新学生
INSERT INTO student (sname, ssex, sno, sage, sdept) 
VALUES ('赵六', '男', '200215126', 21, 'CS');

-- 查看sys_log结果（num应从4变为5）
SELECT * FROM sys_log;

-- ----------------------------------------------------------------------------------------
-- 第2关: UPDATE型触发器
-- ----------------------------------------------------------------------------------------
/*
定义一个update后触发的触发器，在更新表Course的学分记录时，表sys_log中content内容为“学分总计”的记录num字段的值自动修改，
使得Course表数据更新后，sys_log表中学分总计的值与Course中所有课程的学分总数一致。*/
		
-- 第1步：创建 sys_log 表
DROP TABLE IF EXISTS sys_log;
create table sys_log(
	id      int auto_increment primary key,  -- 自增主键（可选，用于唯一标识日志记录）
	content char(20) not null unique,        -- 日志内容（唯一索引，确保“学生人数”记录唯一）
	num     int not null default 0           -- 统计数值（学生人数）
 );
 
-- 第2步：先初始化sys_log表的「学分总计」记录（若已存在则更新为当前总和）
INSERT INTO sys_log (content, num)
SELECT '学分总计', COALESCE(SUM(ccredit), 0) FROM course   -- 先在 SELECT 中计算学分总计（COALESCE 确保空表时返回 0，避免 NULL）
on duplicate key UPDATE num = VALUES(num);     -- 冲突时复用插入的 num 值（即上面计算的学分总计）
/*************
ON DUPLICATE KEY UPDATE语句是MySQL中用于插入或更新记录的一种方式。
它的主要作用是，如果尝试将一条记录插入到已存在的唯一索引（如主键、唯一约束等）中，则会执行更新操作，而不是插入新记录。
具体来说，当插入数据时，如果发现指定的索引已经存在，则执行UPDATE操作，将新记录的值更新到该索引对应的原有记录上；
否则，执行INSERT操作，插入新记录。
************************/

-- 第3步：创建UPDATE后触发器
DELIMITER $$
DROP TRIGGER IF EXISTS sync_credit_total;
CREATE TRIGGER sync_credit_total
AFTER UPDATE ON Course  -- 课程表更新后触发（学分变更才同步）
FOR EACH ROW  -- 行级触发器：每更新一条课程记录触发一次
BEGIN
    -- 核心修复：用 IF 语句替代 WHEN，判断学分是否实际变更
    IF OLD.ccredit <> NEW.ccredit THEN
        -- 重新计算所有课程的学分总和，同步到 sys_log
        UPDATE sys_log
        SET num = (SELECT COALESCE(SUM(ccredit), 0) FROM course)
        WHERE content = '学分总计';
        
        -- 容错处理：若「学分总计」记录不存在，则自动插入
        IF ROW_COUNT() = 0 THEN
            INSERT INTO sys_log (content, num)
            VALUES ('学分总计', (SELECT COALESCE(SUM(ccredit), 0) FROM course));
        END IF;
    END IF;
END $$
DELIMITER ;


-- 第4步：测试UPDATE后触发器
-- 1. 查看初始学分总计（当前Course表学分总和：2+2+4+4+4+4+3=23）
SELECT * FROM sys_log WHERE content = '学分总计';

-- 2. 更新1门课程的学分（比如将「数学」的学分从2改为3）
UPDATE course SET ccredit = 3 WHERE cno = '2';

-- 3. 再次查看学分总计（应变为23-2+3=24）
SELECT * FROM sys_log WHERE content = '学分总计';

-- 4. 批量更新多门课程学分（比如将「数据处理」2分、「操作系统」3分，均改为5分）
UPDATE course SET ccredit = 5 WHERE cno IN ('6', '4');

-- 5. 查看最终学分总计（24-2-3+5+5=29）
SELECT * FROM sys_log WHERE content = '学分总计';


-- ----------------------------------------------------------------------------------------
-- 第3关: DELETE型触发器
-- ----------------------------------------------------------------------------------------
/*使得Course表数据更新后，sys_log表中学分总计的值与Course中所有课程的学分总数一致。*/

-- 第1步：创建 sys_log 表
DROP TABLE IF EXISTS sys_log;
create table sys_log(
	id      int auto_increment primary key,  -- 自增主键（可选，用于唯一标识日志记录）
	content char(20) not null unique,        -- 日志内容（唯一索引，确保“学生人数”记录唯一）
	num     int not null default 0           -- 统计数值（学生人数）
 );
 
-- 第2步：初始化“学分总计”（此时 course 已有数据，统计结果=23）
INSERT INTO sys_log (content, num)
SELECT '学分总计', COALESCE(SUM(ccredit), 0) FROM course
ON DUPLICATE KEY UPDATE num = VALUES(num);
/*************
ON DUPLICATE KEY UPDATE语句是MySQL中用于插入或更新记录的一种方式。
它的主要作用是，如果尝试将一条记录插入到已存在的唯一索引（如主键、唯一约束等）中，则会执行更新操作，而不是插入新记录。
具体来说，当插入数据时，如果发现指定的索引已经存在，则执行UPDATE操作，将新记录的值更新到该索引对应的原有记录上；
否则，执行INSERT操作，插入新记录。
************************/

-- 第3步：创建触发器
DELIMITER //
DROP TRIGGER IF EXISTS update_credit_total_after_delete;
CREATE TRIGGER update_credit_total_after_delete 
AFTER DELETE 
ON Course
FOR EACH ROW
BEGIN
    UPDATE sys_log 
    SET num = (SELECT COALESCE(SUM(Ccredit), 0) FROM Course) 
    WHERE content = '学分总计';
END //
DELIMITER ;

-- 第4步：测试（按顺序执行）
select * from course;  -- 查看所有课程（含 cno='4'，学分3）

SELECT * FROM sys_log WHERE content = '学分总计';
DELETE FROM course WHERE cno = '4';  -- 该课程学分=3
SELECT * FROM sys_log WHERE content = '学分总计';

DELETE FROM course WHERE cno IN ('6', '7');  -- 总减少学分=2+4=6
SELECT * FROM sys_log WHERE content = '学分总计';

DELETE FROM course WHERE cno = '999';  -- 无匹配课程，删除行数=0
SELECT * FROM sys_log WHERE content = '学分总计';

DELETE FROM course;  -- 清空课程表
SELECT * FROM sys_log WHERE content = '学分总计';
