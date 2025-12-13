
insert into emp(id, workno, name, gender, age, idcard, entrydate,workaddress) values (1, '1', 'Itcast', '男', 10, '123456789123456789', '2000-01-01','shenzhen');
-- insert into emp(id, workno, name, gender, age, idcard, entrydate) values (2, '2', 'Itcast2', '男', 10, '123456789123456789', '2000-01-01');

select * from emp;

insert into emp values (2,'2','Su san','男',19,'12345678912345678','2024-08-26','Hongkong');
insert into emp values (3, '3', 'Tenerife', '男', 19, '12342024131065', '2006-06-23','Singapore'),
(4, '4', 'Su', '女', 19, '12345678659', '2006-06-08','London'),
(5,'5','qinzi','男',10, '165165416','2008-06-10','Manchester');


-- update emp set name = 'it' where id = 1;
-- 
-- update emp set name = 'fuck', gender = '女' where id = 1;
-- 
-- update emp set entrydate = '2006-06-08' where id = 4;
-- 
-- update emp set gender = '男' where id = 5;
-- 
-- update emp set idcard = '234657861' where name = 'Su san';
-- 
-- update emp set gender = '男' where id = 2;
-- 
-- delete from emp where id = 1;

-- delete from emp;--全部删除


-- select * from emp order by id;
-- 
-- alter table emp add workaddress varchar(20) comment '工作地点';
-- 
-- insert into emp (workaddress) values ('shenzhen') ;
-- 
-- delete from emp where id = null;