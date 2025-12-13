-- 约束
select * from user;

create table user(
    id int primary key auto_increment comment '主键',
    name varchar(10) not null unique comment '姓名',
    age int check(age > 0 && age <= 120) comment '年龄',
    status char(1) default '1' comment '状态',
    gender char(1) comment '性别'
) comment'用户表';

insert into user(name,age,status,gender) values('Tenerife',19,'1','男'),('Susan',19,'0','女');
insert into user(name,age,status,gender) values ('qinzi',10,'1','男');
insert into user(name,age,gender) values ('Qin',20,'男');


-- 添加外键约束
-- create table 表名(
--       字段名 数据类型,
--       ...
--       [constraint] [外键名称] foreign key (外键字段名) references 主表 (主表列名);
-- )
-- alter table 表名 add constraint 外键名称 foreign key (外键字段名) references 主表(主表列名);
-- 
-- 删除外键
-- alter table 表名 drop foreign key 外键名称;
-- 

-- 删除更新行为 父表更新子表也跟着更新 删除同理
-- alter table 表名 add constraint 外键名称 foreign key(外键字段) references 主表(主表列名) on update cascade on delete cascade;
-- 
-- 父表删除记录 检查记录是否有对应外键 有则设置子表中该外键值为null
-- alter table 表名 add constraint 外键名称 foreign key(外键字段) references 主表(主表列名) on update set null on delete set null;
-- 
