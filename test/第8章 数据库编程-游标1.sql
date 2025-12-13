
/********************************************************************************************

游标是 SQL 的一种数据访问机制 ，游标是一种处理数据的方法。众所周知，使用SQL的select 查询操作返回的结果是一个包含一行或者是多行的数据集，如果我们要对查询的结果再进行查询，比如（查看结果的第一行、下一行、最后一行、前十行等等操作）简单的通过 select 语句是无法完成的，因为这时候索要查询的结果不是数据表，而是已经查询出来的结果集。游标就是针对这种情况而出现的。我们可以将 “游标” 简单的看成是结果集的一个指针，可以根据需要在结果集上面来回滚动，浏览我需要的数据。


一、游标
1、游标
		﻿一个对表进行操作的SQL语句（如 select）通常都可产生或处理一组记录，但是许多应用不能把整个结果集作为一个单元来处理，
		所以就需要一种机制来保证每次处理结果其中的一行或几行，游标（cursor）就提供了这种机制。
		
		﻿SQL Server 通过游标提供了对一个结果集进行逐行处理的能力，游标可看做一种特殊的指针，它与某个查询结果相联系，可以指向结果集的任意位置，
		以便对指定位置的数据进行处理。使用游标可以在查询数据的同时对数据进行处理。
		
		﻿游标是系统为用户开设的一个数据缓冲区，存放SQL语句的结果数据集，每个游标区都有一个名字，通过移动游标名代表的指针来访问数据集中的数据

2、使用游标需要经历五个步骤：
		﻿定义游标：declare
		﻿﻿打开游标：open
		﻿逐行提取游标集中的行：fetch
		﻿﻿关闭游标：close
		释放游标：dealloca

3、游标的定义
		declare <游标名>［scroll] cursor
		for<select语句>
		[for［read only / update｛of<列名>}]

		scroll：说明所声明的游标可以前滚，后滚，可使用所有的提取选项。如省略，则只能使用 next 提取选项。
		﻿﻿read only 表示当前游标集中的元组仅可以查询，不能修改；
		﻿﻿update ｛of <列名>｝表示可以对当前游标集中的元组进行更新操作。如果有of <列名>，表示仅可以对游标集中指定的属性

		如, 定义一个能够存放sc表数据的游标:
		declare cur_sc cursor


4、游标的打开
		游标定义后，如果要使用游标，必须先打开游标。
		打开游标操作表示：
		1）﻿系统按照游标的定义从数据库中将数据检索出来，放在内存的游标集中（如果内存不够，会放在临时数据库中）
		﻿2）为游标集指定一个游标，该游标指向游标集中的第1个元组

		格式：open 游标名；
		open cur_sc;

		打开游标后，可以使用全局变量 @@CURSOR_ROWS 查看游标集中数据行的数目。
		全局变量 @@CURSOR_ROWS 中保存着最后打开的游标中的数据行数。
		当其值为0时，表示没有游标打开； 
		当其值为m（m为正整数）时，游标已被完全填充，m是游标中的数据行数。

5、游标的读取
		﻿fetch [ next | prior | first | last | absolute {n| @nvar | relative {n|@nvar] from {游标} [into @变量名,...]
		﻿﻿next |prior|first |last：说明读取数据的位置。

		1. next：读取当前行的下一行，并使其置为当前行。如 fetch next 为对游标的第一次提取操作，则读取第一行，next 为默认值。
		2. prior：读取当前行的前一行，并使其置为当前行。如是第一次操作，则无值返回，游标被置于第一行之前。
		3. first ：读取第一行，并使其置为当前行。
		4. last：读取最后一行，并使其置为当前行。
		5. absolute {n| @nvar } | relative {n| @nvar} : 
			 给出读取数据的位置与游标头或当前位置的关系，其中n必须为整型常量，@nvar 必须smallint、tinyint或int型 

		例：从游标xs_cur1中提取数据。设该游标已经声明并打开。
		fetch next from xs_cur1

		fetch语句的执行状态保存在全局变量 @@fetch_status 中，
		其值为 0 表示上一个fetch执行成功；
		其值为 -1表示所要读取的行不在结果集中；
		其值为 2 表示被提取的行已不存在（已被删除）。

		例如，接着上例继续执行如下语句：(此时游标在倒数第三行）
		fetch relative 3 from xs_cur1
		select 'fetch执行情况' = @@fetch_status
		执行结果为：-1，此时游标已出界

6、游标的关闭
		﻿关闭游标: close 游标
		﻿﻿释放游标：游标关闭后，其定义仍在，需要时可用open语句打开它再使用。
		
		若确认游标不再需要，就要释放其定义占用的系统空间，即删除游标。
		deallocate  游标名

/********************************************************************************************/

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
   ssex   char(2)  check (ssex in ('男','女')),
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


-- =================================================================================================================
-- 声明变量 → 声明游标（绑定查询语句） → 声明异常处理 → 打开游标 → 循环遍历（FETCH 数据） → 业务逻辑 → 关闭游标。
-- =================================================================================================================
-- 案例1：单表游标-批量更新学生年龄（模拟生日年份修正）
-- 需求：假设所有学生的年龄录入时少算了1岁，使用游标遍历学生表，批量将每个学生的年龄+1，并打印更新前后的信息。
-- =================================================================================================================
-- =================================================================================================================

USE liuq;

-- 为了重复实验，我们将年龄修改为最开始的！
UPDATE student 
SET Sage = CASE 
    WHEN Sno = '200215121' THEN 20
    WHEN Sno = '200215122' THEN 19
    WHEN Sno = '200215123' THEN 18
    WHEN Sno = '200215125' THEN 19
END;


-- 删除已存在的存储过程（避免重复创建报错）
DROP PROCEDURE IF EXISTS UpdateStudentAge;

-- 创建存储过程
DELIMITER //  -- 临时修改语句结束符为 //（避免与存储过程中的 ; 冲突）
CREATE PROCEDURE UpdateStudentAge()
BEGIN
    -- 1. 声明变量（存储游标读取的字段值）
    DECLARE v_sno CHAR(9);       -- 学号
    DECLARE v_sname CHAR(20);    -- 姓名
    DECLARE v_old_sage SMALLINT; -- 更新前年龄
    DECLARE v_new_sage SMALLINT; -- 更新后年龄
    DECLARE done INT DEFAULT 0;  -- 游标结束标记（0=未结束，1=已结束）

    -- 2. 声明游标：查询所有学生的学号、姓名、年龄
    DECLARE student_cursor CURSOR FOR				 -- 声明游标
    SELECT Sno, Sname, Sage FROM student;    -- 游标关联

    -- 3. 声明异常处理：游标遍历结束时将 done 设为1
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- 4. 打开游标
    OPEN student_cursor;

    -- 5. 循环遍历游标
    student_loop: REPEAT
        FETCH student_cursor INTO v_sno, v_sname, v_old_sage;
        
        IF done = 1 THEN
            LEAVE student_loop;
        END IF;
        
        -- 业务逻辑：年龄+1
        SET v_new_sage = v_old_sage + 1;
        UPDATE student SET Sage = v_new_sage WHERE Sno = v_sno;
        
        -- 打印更新日志（用 SELECT 输出）
        SELECT CONCAT('学生 [', v_sname, '] (学号:', v_sno, ') 年龄更新：', v_old_sage, '→', v_new_sage) AS 更新日志;

    UNTIL done = 1 END REPEAT student_loop;

    -- 6. 关闭游标
    CLOSE student_cursor;

END //
DELIMITER ;  -- 恢复语句结束符为 ;

-- 调用存储过程（执行游标逻辑）
CALL UpdateStudentAge();

-- 验证结果
SELECT * FROM student;


-- =================================================================================================================
-- =================================================================================================================
-- 案例2：多表关联游标-统计学生选课平均分（按院系分组）
-- 需求：关联学生表（student）、选课表（sc）、课程表（course），使用游标遍历每个院系的所有学生选课成绩，计算每个院系的平均分，并打印统计结果。
-- =================================================================================================================
-- =================================================================================================================
USE liuq;

-- 删除已存在的存储过程
drop procedure if exists StatDeptAvgGrade;

-- 创建存储过程
DELIMITER //
create procedure StatDeptAvgGrade()
begin
    -- 1. 声明变量
    declare v_sdept char(20);    -- 院系
    declare v_grade smallint;    -- 学生成绩
    declare v_total_grade int default 0; -- 院系总分数
    declare v_student_count int default 0; -- 院系选课人数
    declare v_avg_grade decimal(5,2); -- 平均分
    declare done int default 0;  -- 游标结束标记
    declare next_sdept char(20); -- 下一条记录的院系（用于分组）
    declare next_grade smallint; -- 下一条记录的成绩

    -- 2. 声明游标：关联3表，按院系排序
    DECLARE dept_grade_cursor CURSOR FOR
    SELECT s.Sdept, sc.Grade
    FROM student s
    JOIN sc ON s.Sno = sc.Sno
    JOIN course c ON sc.Cno = c.Cno
    ORDER BY s.Sdept;

    -- 3. 异常处理
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- 4. 打开游标
    OPEN dept_grade_cursor;

    -- 5. 读取第一条记录初始化
    FETCH dept_grade_cursor INTO v_sdept, v_grade;

    -- 6. 循环遍历统计
    dept_stat_loop: LOOP
        IF done = 1 THEN
            -- 处理最后一个院系
            IF v_student_count > 0 THEN
                SET v_avg_grade = v_total_grade / v_student_count;
                SELECT CONCAT('院系 [', v_sdept, '] 统计结果：平均分=', v_avg_grade, '，选课人数=', v_student_count, '，总分数=', v_total_grade) AS 院系统计;
            END IF;
            LEAVE dept_stat_loop;
        END IF;

        -- 累加当前院系数据
        SET v_total_grade = v_total_grade + v_grade;
        SET v_student_count = v_student_count + 1;

        -- 预读下一条记录
        FETCH dept_grade_cursor INTO next_sdept, next_grade;

        -- 下一条院系不同或遍历结束，计算当前院系平均分
        IF next_sdept <> v_sdept OR done = 1 THEN
            SET v_avg_grade = v_total_grade / v_student_count;
            SELECT CONCAT('院系 [', v_sdept, '] 统计结果：平均分=', v_avg_grade, '，选课人数=', v_student_count, '，总分数=', v_total_grade) AS 院系统计;
            
            -- 重置变量，准备下一个院系
            SET v_sdept = next_sdept;
            SET v_total_grade = next_grade;
            SET v_student_count = 1;
        END IF;
    END LOOP dept_stat_loop;

    -- 7. 关闭游标
    CLOSE dept_grade_cursor;

END //
DELIMITER ;

-- 调用存储过程（执行统计逻辑）
CALL StatDeptAvgGrade();

-- 验证原始关联数据
SELECT s.Sdept, s.Sname, c.Cname, sc.Grade
FROM student s
JOIN sc ON s.Sno = sc.Sno
JOIN course c ON sc.Cno = c.Cno
ORDER BY s.Sdept;
-- =================================================================================================================
-- =================================================================================================================





