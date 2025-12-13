-- 事务操作
-- ACID 
-- 原子性
-- 一致性
-- 隔离性
-- 持久性


-- 查看设置事务提交方式
select @@autocommit;
set @@autocommit = 0;

-- 提交事务
commit;

-- 回滚事务
rollback;



create table account (
    id int auto_increment primary key comment '主键ID',
    name varchar(10) comment '姓名',
    money int comment '余额'
) comment '账户表';
insert into account(id, name, money) values (null, '张三', 2000), (null,'李四',2000);

-- 恢复数据
update account set money = 2000 where name = '张三' or name = '李四';



-- select @@autocommit;

-- 设置为手动提交
select @@autocommit = 0;
-- 设置为自动提交
select @@autocommit = 1;


-- 转账操作
select * from account where name = '张三';

update account set money = money - 1000 where name = '张三';

update account set money = money + 1000 where name = '李四';

commit;




-- 方式二
start transaction;

select * from account where name = '张三';

update account set money = money - 1000 where name = '张三';

wrong

update account set money = money + 1000 where name = '李四';

commit;

rollback;