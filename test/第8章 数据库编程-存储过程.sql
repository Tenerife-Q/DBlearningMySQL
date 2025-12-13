-- =================================================================================================================
-- 存储过程（Stored Procedure）是数据库中预编译、可重复执行的 SQL 代码块，可以理解为数据库层面的 “函数” 或 “脚本”—— 它将一组复杂的 SQL 操作（查询、插入、更新、删除、循环、判断等）封装成一个命名实体，
-- 存储在数据库服务器中，后续通过 “调用” 即可重复执行，无需每次重新编写完整 SQL。

/*
1、相关知识
为了完成本关任务，你需要掌握：存储过程的编写。


2、Delimiter的用法
	一般情况下MYSQL以；结尾表示确认输入并执行语句，但在存储过程中；不是表示结束，因此可以用该命令将；号改为//表示确认输入并执行，否则创建存储过程将报错。

	delimiter $$
	CREATE PROCEDURE delete_matches(IN p_playerno INTEGER)
	BEGIN
	DELETE FROM MATCHES
	WHERE playerno = p_playerno;
	END$$
	delimiter ; //恢复分号来作为语句标识。

-- =================================================================================================================
一.创建存储过程
1.基本语法：
		delimiter //  -- 临时修改语句分隔符（默认;会与存储过程内的;冲突）
		create procedure 存储过程名(
				[in/out/inout 参数名 数据类型]  -- 可选：输入/输出/输入输出参数
		)
		begin
				-- 核心逻辑：变量声明、sql操作、循环、判断等
				declare 变量名 数据类型 [default 默认值];  -- 局部变量
				-- ... 业务sql语句 ...
		end //
		delimiter ;  -- 恢复默认分隔符
 

2.参数传递
	存储过程的参数有三种：
	IN：输入参数，也是默认模式，表示该参数的值必须在调用存储过程时指定，在存储过程中修改该参数的值不能被返回；
	OUT：输出参数，该值可在存储过程内部被改变，并可返回；
	INOUT：输入输出参数，调用时指定，并且可被改变和返回。
	proc_parameter:
			[ IN | OUT | INOUT ] param_name type

二.调用存储过程
	call 存储过程名([参数]);
	注意：存储过程名称后面必须加括号，哪怕该存储过程没有参数传递

三.删除存储过程
	1.基本语法：
	drop procedure if exists sp_name;

	2.注意事项
	(1)不能在一个存储过程中删除另一个存储过程，只能调用另一个存储过程

四.区块，条件，循环
	1.区块定义，常用
	begin
	......
	end;
	也可以给区块起别名，如：
	lable:begin
	...........
	end lable;
	可以用leave lable;跳出区块，执行区块以后的代码

	2.条件语句
	if 条件 then
	 statement
	 else
	 statement
	 end if;

3.循环语句
	(1).while循环
	[label:] WHILE expression DO
	 statements
	 END WHILE [label] ;

	(2).loop循环
	[label:] LOOP
	 statements
	 END LOOP [label];

	(3).repeat until循环
	[label:] REPEAT
	 statements
	 UNTIL expression
	 END REPEAT [label] ;

五.其他常用命令
	1.show procedure status;
	显示数据库中所有存储的存储过程基本信息，包括所属数据库，存储过程名称，创建时间等

	2.show create procedure sp_name;
	显示某一个存储过程的详细信息

	定义临时变量
	尽量在存储过程最开始执行。
	定义语法为：declare 变量名 变量数据类型。如 declare tempStr char(10);
	变量赋值语法为： set tempStr="你好";
	也可以用select 结果直接赋值，临时变量为temp1和temp2： select SUM(grade), AVG(grade) into temp1, temp2 from SC;
	编程要
*/

-- =================================================================================================================
use liuq;
drop table if exists sc;
drop table if exists course;
drop table if exists student;

-- -----------------------------------------------------
-- 创建表1：学生表 student
-- -----------------------------------------------------
create table student( 
   sno    char(9)  primary key,
   sname  char(20) not null,     
   ssex   char(2) check (ssex in ('男','女')),
   sage   smallint check (sage > 0 and sage < 100),
   sdept  char(20)
);
insert into student(sname,ssex,sno, sage, sdept) values
		('李勇','男','200215121',20,'cs'),
		('刘晨','女','200215122',19,'cs'),
		('王敏','女','200215123',18,'ma'),
		('张立','男','200215125',19,'is');
select * from student;

-- -----------------------------------------------------
-- 创建表2：课程表 course（关键：cno 改为 char(4)，与 sc 表完全匹配）
-- -----------------------------------------------------
create table course(
		cno     char(4)  primary key comment '课程号',  
		cname   char(20) comment '课程名',
		cpno    char(4)  comment '先行课',  
		ccredit smallint comment '学分'
);
insert into course(cno,cname,cpno,ccredit) values
		('6','数据处理',null,2),
		('2','数学',null,2),
		('7','pascal语言','6',4),
		('5','数据结构','7',4),
		('1','数据库','5',4),
		('3','信息系统','1',4),
		('4','操作系统','6',3);
select * from course;

-- -----------------------------------------------------
-- 创建表3：学生选课成绩表 sc（彻底解决语法报错）
-- -----------------------------------------------------
create table sc (
    sno    char(9)  not null comment '学号',
    cno    char(4)  not null comment '课程号',  
    grade  smallint check (grade between 0 and 100) comment '成绩' , 
    primary key (sno, cno), 
    foreign key (sno) references student(sno),    
    foreign key (cno) references course(cno)
);  
insert into sc(sno,cno,grade) values
	('200215121','1',92),
	('200215121','2',85),
	('200215121','3',88),
	('200215122','2',90),
	('200215122','3',80);
select * from sc;

-- ----------------------------------------------------------------------------------------
-- 第1关: 单循环游标
-- ----------------------------------------------------------------------------------------
/*
编写一个单循环游标的存储过程，并调用它，打印表Student中所有学生的名字(Sname)和年龄(Sage)两个字段的信息。
并将所有学生的信息使用","连接为一个字符串。

其中，每个学生的信息格式如下：姓名:Sname 年龄:Sage
例如，学生“张三”年龄为28, 该学生的信息为：学生:张三 年龄:28

将信息存入result时可以使用concat函数,如果要将'我是字符串'和数字28连接到result的尾部,可使用以下语句：
set result = concat(result, '我是字符串'， 28) ，在具体使用过程中可以将对应的常量替换为变量名。
注意：每个学生的信息中姓名和年龄之间用空格隔开，学生信息之间用英文逗号隔开
*/

DELIMITER //
DROP PROCEDURE IF EXISTS GetAllStudents;
CREATE PROCEDURE GetAllStudents()
BEGIN
    -- 声明变量：存储学生姓名、年龄、游标结束标志、结果字符串
    DECLARE s_name VARCHAR(20);
    DECLARE s_age INT;
    DECLARE done INT DEFAULT 0;
    DECLARE result_str VARCHAR(1000) DEFAULT '';
    
    -- 声明游标，用于获取所有学生的姓名和年龄
    DECLARE student_cursor CURSOR FOR
    SELECT Sname, Sage FROM Student;   -- 游标关联SELECT Sname, Sage FROM Student查询，用于遍历所有学生记录。
    
    -- 声明游标结束处理程序
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;   -- 表示当游标无记录可提取时，将done设为 1，触发循环退出。
     
    -- 打开游标
    OPEN student_cursor;
    
    -- 循环遍历游标
    student_loop: LOOP
        -- 提取当前行的姓名和年龄
        FETCH student_cursor INTO s_name, s_age;
        
        -- 若游标已遍历所有记录，退出循环
        IF done THEN
            LEAVE student_loop;
        END IF;
        
        -- 拼接当前学生的信息（格式：学生:姓名 年龄:年龄,）
        SET result_str = CONCAT(result_str, '学生:', s_name, ' 年龄:', s_age, ',');
    END LOOP student_loop;
    
    -- 关闭游标
    CLOSE student_cursor;
    
    -- 移除最后一个多余的逗号（若结果不为空）
    IF LENGTH(result_str) > 0 THEN
        SET result_str = SUBSTRING(result_str, 1, LENGTH(result_str) - 1);
    END IF;
    
    -- 打印最终结果
    SELECT result_str AS result;
END //

DELIMITER ;

-- 调用存储过程
CALL GetAllStudents();

-- 学生:李勇 年龄:20,学生:刘晨 年龄:19,学生:王敏 年龄:18,学生:张立 年龄:19,

-- ----------------------------------------------------------------------------------------
-- 第2关: 游标的嵌套
-- ----------------------------------------------------------------------------------------
/********
依次遍历学生表(Student)并按照学生学号（Sno）去查询选课表(SC)表格记录并统计打印出每个学生的所有课程成绩总和。
统计结果存在一字符串内并打印出来，结果格式为不同学生的信息使用英文逗号','进行连接。
其中每种书籍信息内容为： Sno: 总成绩

例如，学号为"001"的学生在SC表中有3条记录，Grade分别为3,4,5。该书籍的信息则为：001:12
注意：12为3+4+5的结果

将信息存入result时可以使用concat函数,如果要将'我是字符串'和数字128连接到result的尾部,可使用以下语句：
set result = concat(result, '我是字符串'， 128)，在具体使用过程中可以将对应的常量替换为变量名。
注意：不同学生信息之间用英文逗号隔开
***********/

DELIMITER //
DROP PROCEDURE IF EXISTS GetStudentGradeSum;
CREATE PROCEDURE GetStudentGradeSum()
BEGIN
    -- 外层变量：存储学生学号、外层游标结束标志
    DECLARE outer_sno CHAR(9);
    DECLARE outer_done INT DEFAULT 0;
    -- 结果字符串变量
    DECLARE result_str VARCHAR(1000) DEFAULT '';
    
    -- 外层游标：遍历所有学生的学号
    DECLARE outer_cursor CURSOR FOR
        SELECT Sno FROM Student;
    
    -- 外层游标结束处理程序（仅作用于外层作用域）
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET outer_done = 1;
    
    -- 打开外层游标
    OPEN outer_cursor;
    
    -- 外层循环：遍历每个学生
    outer_loop: LOOP
        -- 提取当前学生学号
        FETCH outer_cursor INTO outer_sno;
        
        -- 若外层游标遍历结束，退出外层循环
        IF outer_done THEN
            LEAVE outer_loop;
        END IF;
        
        -- ********** 内层作用域：独立处理内层游标（避免处理程序冲突）**********
        BEGIN
            -- 内层变量：存储成绩、成绩总和、内层游标结束标志（仅作用于内层）
            DECLARE grade_val SMALLINT;
            DECLARE total_grade INT DEFAULT 0;
            DECLARE inner_done INT DEFAULT 0;
            
            -- 内层游标：根据当前学生学号查询所有成绩
            DECLARE inner_cursor CURSOR FOR
                SELECT Grade FROM SC WHERE Sno = outer_sno;
            
            -- 内层游标结束处理程序（仅作用于内层作用域）
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET inner_done = 1;
            
            -- 重置成绩总和（处理当前学生）
            SET total_grade = 0;
            
            -- 打开内层游标
            OPEN inner_cursor;
            
            -- 内层循环：累加当前学生的成绩
            inner_loop: LOOP
                FETCH inner_cursor INTO grade_val;
                
                IF inner_done THEN
                    LEAVE inner_loop;
                END IF;
                
                -- 累加成绩（COALESCE处理NULL成绩，视为0）
                SET total_grade = total_grade + COALESCE(grade_val, 0);
            END LOOP inner_loop;
            
            -- 关闭内层游标
            CLOSE inner_cursor;
            
            -- 拼接当前学生的成绩总和信息
            IF result_str = '' THEN
                -- 第一个学生直接拼接（无前缀逗号）
                SET result_str = CONCAT(outer_sno, ':', total_grade);
            ELSE
                -- 非第一个学生前加逗号分隔
                SET result_str = CONCAT(result_str, ',', outer_sno, ':', total_grade);
            END IF;
        END; -- 结束内层作用域
        -- *********************************************************************
    END LOOP outer_loop;
    
    -- 关闭外层游标
    CLOSE outer_cursor;
    
    -- 打印最终结果
    SELECT result_str AS result;
END //

DELIMITER ;

-- 调用存储过程
CALL GetStudentGradeSum();


-- =================================================================================================================
-- END
-- =================================================================================================================
