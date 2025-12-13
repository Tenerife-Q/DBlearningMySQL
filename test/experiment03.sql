SET FOREIGN_KEY_CHECKS=0;
DROP DATABASE IF EXISTS studb;
create database studb;
use studb;
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
 
 -- -----------------------------------------------------
 -- -----------------------------------------------------
-- 1 (update)将不及格学生的最低修课成绩改为60。

 -- -----------------------------------------------------
-- 2 （insert）用一条语句为学生表插入两行数据，数据分别为：
-- '200215127', '李明', '男', '19', 'MA'
-- '200215126', '周晓晓', '女', '18', 'CS'

 -- -----------------------------------------------------
-- 3 （delete和多表连接）删除CS系“操作系统”课程的全部选课记录。

 -- -----------------------------------------------------
-- 4 （insert）统计每门课程的选课的男生和女生人数，并以课程号的升序排列，要求将查询结果放在一张新的永久表sctemp中。
-- 新表中的列名分别为：Cno, Ssex,人数。

 -- -----------------------------------------------------
-- 5 （update和子查询）修改数据结构课程的前置课程为数学
-- 提示：大家可以参考资料http://t.zoukankan.com/007sx-p-7404651.html.

 -- -----------------------------------------------------
-- 6 （update case when）对数据库考试成绩进行如下修改：如果成绩低于60分，则提高10％；
-- 如果成绩在60到80之间，则增加6％；
-- 如果成绩在81到95之间则提高4％，其他情况不提高。
-- 提示：使用case when，语法规则为：

 -- -----------------------------------------------------
-- 7 (视图，update和多表连接)将数据库考试成绩最低（但不是null）的且成绩为不及格学生的数据库考试成绩改为60。
-- 首先要求建立一个数据库课程最低分数的视图，存放课程名称（列名：cname）和最低分数（列名：mingrade），然后再更改选课表中数据库考试成绩最低（但不是null）的且成绩为不及格学生的数据库考试成绩为60.

 -- -----------------------------------------------------
-- 8 （视图，delete和多表连接）删除信息系统考试成绩最低（但不是null）的两个学生的信息系统考试记录。
-- 首先建立视图存放系统考试成绩最低（但不是null）的两个学生的学号。然后再在选课表中删除这两个学生的信息系统考试记录。

 
-- =========================================================================================
-- 参考答案如下
-- =========================================================================================
-- 1 (update)将不及格学生的最低修课成绩改为60。
set sql_safe_updates=0;   -- 关闭安全模式（仅当前会话）

update sc set grade=60
where grade<60;

select * from sc; 

 -- -----------------------------------------------------
-- 2 （insert）用一条语句为学生表插入两行数据，数据分别为：
-- '200215127', '李明', '男', '19', 'MA'
-- '200215126', '周晓晓', '女', '18', 'CS'
 
insert into student 
values
	('200215127','李明', '男','19', 'MA'),
	('200215126','周晓晓','女', '18', 'CS');

select * from student; 

 -- -----------------------------------------------------
-- 3 （delete和多表连接）删除CS系“操作系统”课程的全部选课记录。
delete sc 
from sc join student s on s.sno = sc.sno
join course c on c.cno = sc.cno
where (sdept = 'CS') and (cname = '操作系统');

 -- -----------------------------------------------------
-- 4 （insert）统计每门课程的选课的男生和女生人数，并以课程号的升序排列，要求将查询结果放在一张新的永久表sctemp中。
-- 新表中的列名分别为：Cno, Ssex,人数。
-- 提示：语法为：CREATE TABLE TABLENAME AS  +你的select语句

create table sctemp
as
select Cno, Ssex,count(*)人数
from sc join student on student.sno=sc.sno
group by cno,Ssex
order by cno;

select * from sctemp;

 -- -----------------------------------------------------
-- 5 （update和子查询）修改数据结构课程的前置课程为数学
-- 提示：大家可以参考资料http://t.zoukankan.com/007sx-p-7404651.html.
/*
mysql的update的一些特点
1、update 时，更新的表不能在set和where中用于子查询；
2、update 时，可以对多个表进行更新（sqlserver不行）；
         如：update ta a,tb b set a.Bid=b.id ,b.Aid=a.id;  
所以我们可以将select cno from course where cname='数学' 的结果取一个别名作为一个临时表，跟在update后面。
*/

update course,(select cno from course where cname='数学') b set cpno=b.cno  
where Cname='数据结构';


 -- -----------------------------------------------------
-- 6 （update case when）对数据库考试成绩进行如下修改：如果成绩低于60分，则提高10％；
-- 如果成绩在60到80之间，则增加6％；
-- 如果成绩在81到95之间则提高4％，其他情况不提高。
/*
提示：使用case when，语法规则为：
CASE WHEN condition THEN result 

　　　WHEN condition THEN result 

　　　.............
　　　[WHEN ...] 
　　　[ELSE result] 
END 
*/

-- 方法1
update sc,course set grade=grade+grade*
   case
     when grade<60 then 0.1
     when grade between 60 and 79 then 0.06
     when grade between 81 and 95 then 0.04
     else 0
   end
where cname='数据库' and sc.cno=course.cno;

-- 方法2
update sc 
set Grade = case
when Grade<60 then Grade*1.1
when (Grade>=60 and Grade<=80) then Grade*1.06
when (Grade>=81 and Grade<=95) then Grade*1.04
else Grade
end
where Cno in (
    select Cno
    from course
    where Cname='数据库');

select * from sc;

 -- -----------------------------------------------------
-- 7 (视图，update和多表连接)将数据库考试成绩最低（但不是null）的且成绩为不及格学生的数据库考试成绩改为60。
-- 首先要求建立一个数据库课程最低分数的视图，存放课程名称（列名：cname）和最低分数（列名：mingrade），然后再更改选课表中数据库考试成绩最低（但不是null）的且成绩为不及格学生的数据库考试成绩为60.

create view one as
select cname,min(grade) mingrade from sc
        join course c on c.cno = sc.cno
        where cname = '数据库' and grade is not null;
	
update sc,course set grade = 60
where cname = '数据库' 
		and grade <60 
		and grade = (select mingrade from one );

 -- -----------------------------------------------------
-- 8 （视图，delete和多表连接）删除信息系统考试成绩最低（但不是null）的两个学生的信息系统考试记录。
-- 首先建立视图存放系统考试成绩最低（但不是null）的两个学生的学号。然后再在选课表中删除这两个学生的信息系统考试记录。
create view two as
select sno
  from sc join course c on sc.cno=c.cno
  where cname='信息系统' and grade is not null
  order by grade asc limit 2;
  
delete  sc
from sc join course c on sc.cno=c.cno
where sno in( select sno from two) and cname='信息系统';

-- =========================================================================================
