use liuq;
-- -----------------------------------------------------
-- 创建表1----
-- -----------------------------------------------------
DROP TABLE IF EXISTS student;
CREATE TABLE student(
		Sno   char(9)     primary key COMMENT '学号',
		Sname varchar(10) unique COMMENT '姓名',
		Ssex  char(1)  COMMENT '性别',
		Sage  int      COMMENT '年龄',
		Sdept char(10) COMMENT '所在系'	
);
DESCRIBE student;        # 查看表结构

insert into student(sname,ssex,sno, sage, sdept) values
		('李勇','男','200215121',20,'CS'),
		('刘晨','女','200215122',19,'CS'),
		('王敏','女','200215123',18,'MA'),
		('张立','男','200215125',19,'IS');
select * from student;


-- -----------------------------------------------------
-- 创建表2----
-- -----------------------------------------------------
DROP TABLE IF EXISTS course;
create table course(
		cno     int      COMMENT '课程号',
		cname   char(20) COMMENT '课程名',
		cpno    int      COMMENT '先行课',
		ccredit smallint COMMENT '学分'
);
DESCRIBE student;        # 查看表结构

insert into course(cno,cname,cpno,ccredit) values
		('6','数据处理',null,2),
		('2','数学',null,2),
		('7','PASCAL语言','6',4),
		('5','数据结构','7',4),
		('1','数据库','5',4),
		('3','信息系统','1',4),
		('4','操作系统','6',3);
select * from course;  	# 查看表数据   


-- -----------------------------------------------------
-- 创建表3----
-- -----------------------------------------------------
DROP TABLE IF EXISTS sc;
create table sc(
		sno char(9) COMMENT '学号',
		cno int COMMENT '课程号',
		grade smallint COMMENT '成绩'
);
DESCRIBE sc;        # 查看表结构		
		
insert into sc(sno,cno,grade) values
	('200215121','1',92),
	('200215121','2',85),
	('200215121','3',88),
	('200215122','2',90),
	('200215122','3',80);
select * from sc;  # 查看表数据  
 
-- ====================================================================== 


-- ====================================================================== 
-- 创建用户
-- ====================================================================== 
-- 1. 创建允许远程登录的用户（设置密码、允许从远程登录）
CREATE USER 'cuit1'@'%' IDENTIFIED BY 'cuit@1234';

-- 2. 创建本地用户（仅数据库服务器本地可用，设置密码、允许从本地登录）
CREATE USER 'cuit2'@'localhost' IDENTIFIED BY 'cuit@1234';

-- 3. 删除普通用户
DROP USER 'cuit1'@'%';

-- 4. 同时删除多个普通用户
DROP USER 'cuit1'@'%','cuit2'@'localhost';

-- 5. 登录测试（终端执行）
-- cd C:\Program Files\MySQL\MySQL Server 9.1\bin
mysql -u cuit1 -p cuit1@1234 -h localhost  	-- 成功登录
mysql -u cuit2 -p cuit2@1234 -h localhost  	-- 成功登录




-- ====================================================================== 
-- 授予用于权限
-- ====================================================================== 
-- 1. 直接给用户赋权（对 `liuq` 库的所有表有查询权限）
GRANT SELECT 
ON liuq.* 
TO 'cuit1'@'localhost';

-- 2. 直接给用户赋权（对 `liuq` 库的所有表有查询、插入、更新和删除权限）
GRANT SELECT,INSERT,UPDATE,DELETE
ON liuq.* 
TO 'cuit1'@'localhost';


-- 3. 授予用户cuit1对 `liuq` 库中 student 表的所有权限
GRANT ALL PRIVILEGES 
ON  liuq.student 
TO 'cuit1'@'localhost';

/*
ALL PRIVILEGES：表示 “所有权限”，包含 SELECT/INSERT/UPDATE/DELETE/ALTER/CREATE/DROP 等所有操作权限
ON 数据库.表：指定权限作用范围（必选），常见取值：
		*.*：所有数据库的所有表（最高范围，仅管理员可用）；
		liuq.*：指定数据库（liuq）的所有表；
		liuq.student：指定数据库（liuq）的指定表（student）；
*/

-- ====================================================================== 
-- 1. 创建允许远程登录的用户cuit1（设置密码、允许从远程登录）
CREATE USER 'cuit1'@'%' IDENTIFIED BY 'cuit@1234';

-- 2：给 cuit1 授予 liuq 库的全权限（推荐，最小权限原则）
GRANT ALL PRIVILEGES ON liuq.* TO 'cuit1'@'%';

-- 3：给 cuit1 授予所有库表的全权限（仅管理员可用，慎用）
GRANT ALL PRIVILEGES ON *.* TO 'cuit1'@'%';

-- 4. cuit1 的权限（确认是否授予成功）
SHOW GRANTS FOR 'cuit1'@'%';


-- 5：回收全权限（避免误授权后无法撤销）
-- 回收 cuit1 的所有库表全权限
REVOKE ALL PRIVILEGES ON *.* FROM 'cuit1'@'%';

-- 回收后刷新权限（部分版本需执行）
FLUSH PRIVILEGES;

DROP USER 'cuit1'@'%';

======================================================================
-- 1. 创建允许远程登录的用户 cuit2（设置密码、允许从远程登录）
CREATE USER 'cuit2'@'localhost' IDENTIFIED BY 'cuit@1234';

-- 2：给 cuit2 授予 liuq 库的全权限（推荐，最小权限原则）
GRANT ALL PRIVILEGES ON liuq.* TO 'cuit2'@'localhost';

-- 3：给 cuit2 授予所有库表的全权限（仅管理员可用，慎用）
GRANT ALL PRIVILEGES ON *.* TO 'cuit2'@'localhost';

-- 4. cuit2 的权限（确认是否授予成功）
SHOW GRANTS FOR 'cuit2'@'localhost';

-- 5：回收全权限（避免误授权后无法撤销）
-- 回收 cuit2 的所有库表全权限
REVOKE ALL PRIVILEGES ON *.* FROM 'cuit2'@'localhost';

-- 回收后刷新权限（部分版本需执行）
FLUSH PRIVILEGES;

DROP USER 'cuit2'@'localhost';

-- ======================================================================
-- 场景 1：给管理员账号授予最高权限（生产环境慎用 *.*）
-- 创建管理员账号，授予所有库表全权限+转授权限

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Admin@1234';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON liuq.* TO 'admin'@'localhost';  

DROP USER 'admin'@'localhost';



-- ======================================================================
-- 角色 使用示例
-- ======================================================================
DROP USER '张三'@'localhost';
DROP USER '李四'@'localhost';
DROP ROLE user_role;

-- ------------------------------------------------------
-- 步骤1：创建本地访问用户
CREATE USER '张三'@'localhost' IDENTIFIED BY 'cuit@1234';
CREATE USER '李四'@'localhost' IDENTIFIED BY 'cuit@1234';

-- 步骤1：创建一个角色 user_role
CREATE  ROLE  user_role;
-- ------------------------------------------------------
-- 步骤2：给角色赋权（指定「数据库.表」，这里假设 Student 表在 test_db 库，需替换为你的实际库名）
-- 注意：必须指定数据库（如 test_db.Student），否则会报 1046 错误（No database selected）

GRANT SELECT, UPDATE, INSERT 
ON Student 
TO user_role;

-- 步骤3：将角色授予用户张三、李四。使他们具有角色 user_role 所包含的全部权限
GRANT user_role TO '张三'@'localhost','李四'@'localhost';

-- 步骤4：激活角色（关键步骤！否则用户无法使用角色权限）
-- 方式1：给用户设置默认角色（永久生效，推荐）
SET DEFAULT ROLE user_role TO '张三'@'localhost', '李四'@'localhost';

-- 方式2：全局开启「登录时自动激活所有已分配角色」（对所有用户生效，更便捷）
SET GLOBAL activate_all_roles_on_login = ON;

-- 步骤5：回收张三的角色（你的语句正确，无需修改）
REVOKE user_role FROM '张三'@'localhost', '李四'@'localhost';

-- ======================================================================


 