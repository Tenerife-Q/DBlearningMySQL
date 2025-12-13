use liuq;
DROP TABLE IF EXISTS sc;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;

-- -----------------------------------------------------
-- 创建表1：学生表 student
-- -----------------------------------------------------
DROP TABLE IF EXISTS student;
create table Student( 
   Sno    CHAR(9)  PRIMARY KEY,
   Sname  CHAR(20) NOT NULL,     
   Ssex   CHAR(2) CHECK (Ssex IN ('男','女')),
   Sage   SMALLINT CHECK (Sage > 0 AND Sage < 100),
   Sdept  CHAR(20)
);

DESCRIBE student;

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
DROP TABLE IF EXISTS course;
create table course(
		cno     CHAR(4)  PRIMARY KEY COMMENT '课程号',  -- 与 SC 表 Cno 类型一致（外键必须类型完全匹配）
		cname   CHAR(20) COMMENT '课程名',
		cpno    CHAR(4)  COMMENT '先行课',  -- 与 cno 类型一致（自引用外键规范）
		ccredit SMALLINT COMMENT '学分'
 
);
DESCRIBE course;  -- 修正原代码的笔误（原写为 DESCRIBE student）

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
DROP TABLE IF EXISTS sc;
CREATE TABLE SC (
    Sno    CHAR(9)  NOT NULL COMMENT '学号',
    Cno    CHAR(4)  NOT NULL COMMENT '课程号',  -- 改为 CHAR(4)，与 course.Cno 完全匹配（避免隐式转换报错）
    Grade  SMALLINT CHECK (Grade BETWEEN 0 AND 100) COMMENT '成绩' , -- 成绩范围校验
    PRIMARY KEY (Sno, Cno),
    -- 外键关联（需确保 student、course 表已存在，字段类型一致）
    FOREIGN KEY (Sno) REFERENCES student(Sno)
        ON DELETE RESTRICT    -- 限制：禁止删除父表关联记录（避免 SC 表出现 “孤儿数据”—— 存在无对应学生/课程的选课记录）；
        ON UPDATE CASCADE,    -- 级联更新：若 student 表学号修改，SC 表对应学号自动同步
    FOREIGN KEY (Cno) REFERENCES course(Cno)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);  
-- ON DELETE CASCADE：删除父表记录时，自动删除 SC 表对应记录（可能误删数据）；
-- ON DELETE SET NULL：删除父表记录时，SC 表对应字段设为 NULL（但 Sno/Cno 是 NOT NULL，冲突）。
DESCRIBE sc;

insert into sc(sno,cno,grade) values
	('200215121','1',92),
	('200215121','2',85),
	('200215121','3',88),
	('200215122','2',90),
	('200215122','3',80);
select * from sc;  # 查看表数据  
 
-- ==============================================================================================
-- insert into sc(sno,cno,grade) values ('200215126','1',92);   --  违背参照完整性：被参考表student中无此学号！
-- delete From student where sno="200215121";										--  违背参照完整性：参考表中有该学号的成绩信息！ 如要删除，请先删除 参照表 数据，然后删除 参照表 的数据！

-- 先删除 参照表 数据，然后删除 参照表 的数据！
-- delete From sc where sno="200215121";
-- delete From student where sno="200215121";	

-- update student set sno='200215131' where sno='200215121';    --  student 表学号修改，SC 表对应学号自动同步
-- ==============================================================================================
show CREATE TABLE SC;

-- CREATE TABLE `sc` (
--   `Sno` char(9) COLLATE utf8mb4_general_ci NOT NULL COMMENT '学号',
--   `Cno` char(4) COLLATE utf8mb4_general_ci NOT NULL COMMENT '课程号',
--   `Grade` smallint DEFAULT NULL COMMENT '成绩',
--   PRIMARY KEY (`Sno`,`Cno`),
--   KEY `Cno` (`Cno`),
--   CONSTRAINT `sc_ibfk_1` FOREIGN KEY (`Sno`) REFERENCES `student` (`Sno`) ON DELETE RESTRICT ON UPDATE CASCADE,
--   CONSTRAINT `sc_ibfk_2` FOREIGN KEY (`Cno`) REFERENCES `course` (`cno`) ON DELETE RESTRICT ON UPDATE CASCADE,
--   CONSTRAINT `sc_chk_1` CHECK ((`Grade` between 0 and 100))
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci

-- ENGINE=InnoDB -- 存储引擎：支持外键、事务、行锁（必须用 InnoDB 才能建立外键）
-- DEFAULT CHARSET=utf8mb4 -- 字符集：支持所有中文、emoji、特殊符号（比 utf8 更全面）
-- COLLATE=utf8mb4_general_ci; -- 排序规则：不区分大小写（查询时 'A' 和 'a' 视为相同）
==============================================================================================
