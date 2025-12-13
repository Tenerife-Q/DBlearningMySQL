-- FUNCTION


-- 1. String字符串函数
select * from emp;

select concat('Hello','MySQL');

select lower('HELLO');

select upper('Hello');

select lpad('01',5,'-');

select rpad('01',5,'-');

-- 去除首尾的空格 中间不去
select trim(' Hello  Mysql ');

-- 从第2个开始 提取8个出来
select substring('Hello mysql',2,8);

update emp set workno = lpad(workno,5,'0');



-- 2. 数值函数

-- 向上取整
select ceil(1.3);

select floor(1.9);

select mod (5,4);

select rand();

-- 保留两位小数
select round(2.3456,2);


-- 生成六位数随机数
select rpad(round(rand()*1000000,0),6,'0');




-- 3. 日期函数
select curdate();

select curtime();

select now();

select year(now());
select month(now());
select day(now());

-- 固定间隔时间
select date_add(now(),INTERVAL 70 DAY);

-- 返回date1-date2之间天数
select datediff('2019-10-31','2025-10-31');



-- 查询所有员工入职天数，并根据入职天数倒叙排序
select name, datediff(curdate(), entrydate) as datediff from emp order by datediff desc;




-- 4. 流程控制函数
-- 判断true则返回第一个 false返回第二个
select if(false,'ok','Error');

-- 只有第一个是空值时 才返回第二个默认值 其余都返回第一个
select ifnull('ok','Default');
select ifnull('','default');
select ifnull(null,'default');


-- 查询emp员工姓名和工作地址 单字段更换数据
select name,
      (case workaddress 
      when 'Singapore' then 'dream' 
      when 'Manchester' then 'dream' 
      else 'realitydream' end ) as '工作地点'
from emp;


eg.
-- 统计成绩
create table score(
    id int comment 'ID',
    name varchar(20) comment '姓名',
    math int comment '数学',
    english int comment '英语',
    chinese int comment '语文'
) comment '成绩表';
insert into score values (1,'Tom',67,88,95),(2,'Rose',23,66,92),(3,'gin',98,96,88);

select * from score;

-- 多字段更换数据
select 
    id,
    name,
    (case when math >= 85 then 'A' when math >= 60 then 'B' else 'C' end )'数学',
    (case when english >= 85 then 'A' when english >= 60 then 'B' else 'C' end )'英语',
    (case when chinese >= 85 then 'A' when chinese >= 60 then 'B' else 'C' end )'语文'
from score;
    
    