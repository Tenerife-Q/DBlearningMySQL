-- 第1关：建立数据库
DROP DATABASE IF EXISTS jwxt;
-- 创建数据库
CREATE DATABASE jwxt;
-- 选中数据库
USE jwxt;

-- 第2关：建立学生数据表
DROP TABLE IF EXISTS student;
CREATE TABLE student (
    studentid CHAR(12) PRIMARY KEY,
    name VARCHAR(10),
    birthday DATE,
    sex ENUM('男', '女') DEFAULT '男',
    nativeplace VARCHAR(3),
    political ENUM('党员', '团员', '群众') DEFAULT '团员',
    interest SET('运动', '旅游', '阅读', '写作', '音乐', '影视', '电子竞技', '其他'),
    resume TEXT,
    photo VARCHAR(20)
);

-- 第3关：建立课程数据表
CREATE TABLE course (
    courseid CHAR(4) PRIMARY KEY COMMENT '课程编号，固定4位字符，作为主键',
    coursename VARCHAR(20) COMMENT '课程名称，最长20个字符',
    credit TINYINT UNSIGNED COMMENT '学分，非负整数，适用tinyint范围',
    required TINYINT(1) DEFAULT 1 COMMENT '是否为必修课，1表示必修，0表示选修，默认值为1',
    period TINYINT UNSIGNED COMMENT '学时，非负整数，适用tinyint范围',
    introduce VARCHAR(100) COMMENT '课程简介，最长100个字符',
    department VARCHAR(20) COMMENT '所属学院，最长20个字符'
) COMMENT '存储课程相关信息的表';

-- 第4关：建立成绩数据表
CREATE TABLE score (
    studentid CHAR(12) COMMENT '学号，关联学生表的学号字段',
    courseid CHAR(4) COMMENT '课程编号，关联课程表的课程编号字段',
    session YEAR COMMENT '学年，存储课程对应的学年信息',
    score DECIMAL(4,1) COMMENT '分数，总长度为4位（含1位小数），表示学生该课程的成绩',
    PRIMARY KEY (studentid, courseid) COMMENT '联合主键，确保一名学生对一门课程的成绩记录唯一'
) COMMENT '存储学生选课及成绩信息的关联表';

-- 第5关：修改数据表名字
-- 任务描述：将student学生数据表改名为xs
-- 相关知识：ALTER TABLE <旧表名> RENAME [to] <新表名> ;
USE JWXT;
ALTER TABLE student RENAME TO xs;
DESCRIBE xs;

-- 第6关：在数据表中添加字段
-- 任务描述：在student学生数据表中增加一个address地址字段，存储30位地址。
-- 相关知识：ALTER TABLE <表名> ADD <新字段名> <数据类型> [约束条件] [FIRST | AFTER 已存在字段名]
USE JWXT;
ALTER TABLE xs ADD address VARCHAR(30) AFTER nativeplace;
DESCRIBE xs;

-- 第7关：修改数据表的字段名称
-- 任务描述：修改课程数据表course的课程名称字段coursename，改名为kcmc，该字段为varchar类型，宽度为20
-- 相关知识：ALTER TABLE <表名> CHANGE <旧字段名> <新字段名> <数据类型> ;
USE JWXT;
ALTER TABLE course CHANGE coursename kcmc VARCHAR(20);
DESCRIBE course;

-- 第8关：修改数据表的字段类型
-- 任务描述：修改course数据表的课程介绍(introduce)字段为text类型
-- 相关知识：ALTER TABLE <表名> MODIFY <字段名> <数据类型> ;
USE JWXT;
ALTER TABLE course MODIFY introduce TEXT;
DESCRIBE course;

-- 第9关：删除数据表的字段
-- 任务描述：删除xs数据表的地址字段address
-- 相关知识：ALTER TABLE <表名> DROP <字段名>
USE JWXT;
ALTER TABLE xs DROP address;
DESCRIBE xs;

-- 第10关：删除数据表
-- 任务描述：删除xs数据表，显示数据库中所有的数据表
-- 相关知识：删除数据表 DROP TABLE <表名> ;
--          查看数据库的所有数据表 SHOW TABLES;
USE jwxt;
DROP TABLE xs;
SHOW TABLES;

-- 第11关：删除数据库
-- 任务描述：删除jwxt数据库，显示所有的数据库
-- 相关知识：删除数据库 DROP DATABASE <数据库名> ;
SHOW DATABASES;
DROP DATABASE IF EXISTS jwxt;
SHOW DATABASES;