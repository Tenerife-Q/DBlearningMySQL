-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 Day 1 SQL 查询语法复习总结
-- 📅 复习日期：2025-12-26
-- 🎯 目标：掌握 DQL（数据查询语言）从基础到进阶的完整语法
-- ═══════════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第一部分：测试数据准备
-- ═══════════════════════════════════════════════════════════════════════════════

-- 创建测试数据库
DROP DATABASE IF EXISTS sql_review;
CREATE DATABASE sql_review DEFAULT CHARSET utf8mb4;
USE sql_review;

drop database if exists 
use someone


-- -----------------------------------------------------------------------------
-- 表1：部门表 department
-- -----------------------------------------------------------------------------
CREATE TABLE department (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '部门ID',
    department_name VARCHAR(50) NOT NULL COMMENT '部门名称',
    location VARCHAR(50) COMMENT '部门所在地'
) COMMENT '部门表';

create table department (
		id int primary key auto_increment comment '  '   auto_increment
		department_name varchar(50) not null comment ' ',
		location varchar(50) 

INSERT INTO department (department_name, location) VALUES
    ('技术部', '北京'),
    ('销售部', '上海'),
    ('人事部', '北京'),
    ('财务部', '广州'),
    ('市场部', '深圳');

-- -----------------------------------------------------------------------------
-- 表2：员工表 employee
-- -----------------------------------------------------------------------------
CREATE TABLE employee (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID',
    name VARCHAR(20) NOT NULL COMMENT '姓名',
    gender CHAR(1) CHECK (gender IN ('男', '女')) COMMENT '性别',
    age TINYINT UNSIGNED COMMENT '年龄',
    phone VARCHAR(11) COMMENT '手机号',
    department_id INT COMMENT '部门ID',
    salary DECIMAL(10, 2) COMMENT '工资',
    entry_date DATE COMMENT '入职日期',
    manager_id INT COMMENT '直属经理ID',
    FOREIGN KEY (department_id) REFERENCES department(id)
) COMMENT '员工表';

insert into employee (name, gender, age, phone, ...) values 

INSERT INTO employee (name, gender, age, phone, department_id, salary, entry_date, manager_id) VALUES
    ('张三', '男', 28, '13800001111', 1, 15000.00, '2020-03-15', NULL),
    ('李四', '男', 32, '13800002222', 1, 12000.00, '2019-07-01', 1),
    ('王五', '女', 25, '13800003333', 1, 10000.00, '2021-06-20', 1),
    ('赵六', '女', 29, '13800004444', 2, 11000.00, '2020-01-10', NULL),
    ('钱七', '男', 35, '13800005555', 2, 9000.00, '2018-05-05', 4),
    ('孙八', '男', 27, NULL, 3, 8000.00, '2022-02-28', NULL),
    ('周九', '女', 31, '13800007777', 3, 8500.00, '2021-09-15', 6),
    ('吴十', '男', 24, '13800008888', 4, 7500.00, '2023-01-01', NULL),
    ('郑十一', '女', 26, '13800009999', NULL, 9500.00, '2022-08-08', NULL),  -- 未分配部门
    ('王十二', '男', 30, '13800000000', 1, 18000.00, '2017-03-20', NULL);

-- -----------------------------------------------------------------------------
-- 表3：项目表 project
-- -----------------------------------------------------------------------------
CREATE TABLE project (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '项目ID',
    project_name VARCHAR(50) NOT NULL COMMENT '项目名称',
    department_id INT COMMENT '负责部门ID',
    FOREIGN KEY (department_id) REFERENCES department(id)
) COMMENT '项目表';

foreign key (department_id) references department(id) 阐述外键

INSERT INTO project (project_name, department_id) VALUES
    ('电商平台开发', 1),
    ('移动APP开发', 1),
    ('数据分析系统', 1),
    ('年度营销活动', 2),
    ('人才招聘计划', 3);

-- -----------------------------------------------------------------------------
-- 表4：任务分配表 assignment
-- -----------------------------------------------------------------------------
CREATE TABLE assignment (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '分配ID',
    employee_id INT NOT NULL COMMENT '员工ID',
    project_id INT NOT NULL COMMENT '项目ID',
    work_percentage DECIMAL(5, 2) COMMENT '工作占比(%)',
    FOREIGN KEY (employee_id) REFERENCES employee(id),
    FOREIGN KEY (project_id) REFERENCES project(id)
) COMMENT '任务分配表';

INSERT INTO assignment (employee_id, project_id, work_percentage) VALUES
    (1, 1, 50.00),
    (1, 2, 50.00),
    (2, 1, 100.00),
    (3, 2, 80.00),
    (3, 3, 20.00),
    (4, 4, 100.00),
    (5, 4, 100.00),
    (7, 5, 100.00);


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第二部分：基础查询语法
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 2.1 SELECT 基本查询
-- =============================================================================

-- 【语法】SELECT 字段列表 FROM 表名;

-- 查询所有字段（不推荐生产环境使用 *）
SELECT * FROM employee;

-- 查询指定字段
SELECT name, age, salary FROM employee;

-- 使用别名（AS 可省略）
SELECT name AS 姓名, age AS 年龄, salary AS 工资 FROM employee;
SELECT name 姓名, age 年龄, salary 工资 FROM employee;  -- 等价写法

-- 去重查询 DISTINCT
SELECT DISTINCT department_id FROM employee;  -- 查询所有不重复的部门ID
SELECT DISTINCT gender, department_id FROM employee;  -- 组合去重


-- =============================================================================
-- 2.2 条件查询 WHERE
-- =============================================================================

-- 【语法】SELECT 字段列表 FROM 表名 WHERE 条件;

-- -----------------------------------------------------------------------------
-- 2.2.1 比较运算符
-- -----------------------------------------------------------------------------
-- | 运算符      | 说明                      |
-- |-------------|---------------------------|
-- | =           | 等于                      |
-- | <> 或 !=    | 不等于                    |
-- | >           | 大于                      |
-- | >=          | 大于等于                  |
-- | <           | 小于                      |
-- | <=          | 小于等于                  |
-- | BETWEEN AND | 在某个范围内（包含边界）  |
-- | IN(...)     | 在列表中的值              |
-- | LIKE        | 模糊匹配                  |
-- | IS NULL     | 是否为 NULL               |
-- -----------------------------------------------------------------------------

-- 查询年龄等于28的员工
SELECT * FROM employee WHERE age = 28;

-- 查询年龄不等于28的员工（两种写法等价）
SELECT * FROM employee WHERE age <> 28;
SELECT * FROM employee WHERE age != 28;  -- 等价写法

-- 查询工资大于10000的员工
SELECT * FROM employee WHERE salary > 10000;

-- 查询年龄在25到30之间的员工（包含25和30）
SELECT * FROM employee WHERE age BETWEEN 25 AND 30;
SELECT * FROM employee WHERE age >= 25 AND age <= 30;  -- 等价写法

-- 查询年龄为25、28、30的员工
SELECT * FROM employee WHERE age IN (25, 28, 30);
SELECT * FROM employee WHERE age = 25 OR age = 28 OR age = 30;  -- 等价写法

-- 查询手机号为空的员工
SELECT * FROM employee WHERE phone IS NULL;

-- 查询手机号不为空的员工
SELECT * FROM employee WHERE phone IS NOT NULL;

-- ⚠️ 注意：NULL 不能用 = 判断，必须用 IS NULL / IS NOT NULL
-- 错误写法：SELECT * FROM employee WHERE phone = NULL;  ❌

-- -----------------------------------------------------------------------------
-- 2.2.2 模糊查询 LIKE
-- -----------------------------------------------------------------------------
-- | 通配符 | 说明                 |
-- |--------|----------------------|
-- | %      | 匹配任意个字符       |
-- | _      | 匹配单个字符         |
-- -----------------------------------------------------------------------------

-- 查询姓"王"的员工
SELECT * FROM employee WHERE name LIKE '王%';

-- 查询名字中包含"十"的员工
SELECT * FROM employee WHERE name LIKE '%十%';

-- 查询名字是两个字的员工
SELECT * FROM employee WHERE name LIKE '__';

-- 查询手机号以138开头的员工
SELECT * FROM employee WHERE phone LIKE '138%';

-- 查询手机号倒数第四位是5的员工
SELECT * FROM employee WHERE phone LIKE '%5___';

-- -----------------------------------------------------------------------------
-- 2.2.3 逻辑运算符
-- -----------------------------------------------------------------------------
-- | 运算符  | 说明                          |
-- |---------|-------------------------------|
-- | AND / && | 并且（多条件同时满足）        |
-- | OR / || | 或者（任一条件满足）          |
-- | NOT / !  | 非（取反）                    |
-- -----------------------------------------------------------------------------

-- 查询年龄大于25且工资大于10000的员工
SELECT * FROM employee WHERE age > 25 AND salary > 10000;
SELECT * FROM employee WHERE age > 25 && salary > 10000;  -- 等价写法

-- 查询年龄小于25或工资大于15000的员工
SELECT * FROM employee WHERE age < 25 OR salary > 15000;
SELECT * FROM employee WHERE age < 25 || salary > 15000;  -- 等价写法

-- 查询年龄不等于28的员工
SELECT * FROM employee WHERE NOT age = 28;
SELECT * FROM employee WHERE age != 28;  -- 等价写法

-- ⚠️ 运算符优先级：NOT > AND > OR
-- 建议使用括号明确优先级
SELECT * FROM employee WHERE (age > 25 AND salary > 10000) OR department_id = 2;


-- =============================================================================
-- 2.3 聚合函数
-- =============================================================================

-- 【语法】SELECT 聚合函数(字段) FROM 表名;
-- 【特点】聚合函数不统计 NULL 值（除了 COUNT(*)）

-- | 函数    | 说明       |
-- |---------|------------|
-- | COUNT   | 统计数量   |
-- | SUM     | 求和       |
-- | AVG     | 平均值     |
-- | MAX     | 最大值     |
-- | MIN     | 最小值     |

-- 统计员工总数
SELECT COUNT(*) AS 员工总数 FROM employee;  -- 包含所有行
SELECT COUNT(id) AS 员工总数 FROM employee;  -- 等价（id 非空）
SELECT COUNT(phone) AS 有手机号的员工数 FROM employee;  -- 不统计 NULL

-- 统计工资总和
SELECT SUM(salary) AS 工资总和 FROM employee;

-- 统计平均工资
SELECT AVG(salary) AS 平均工资 FROM employee;

-- 统计最高工资和最低工资
SELECT MAX(salary) AS 最高工资, MIN(salary) AS 最低工资 FROM employee;

-- 统计技术部（department_id = 1）的平均年龄
SELECT AVG(age) AS 技术部平均年龄 FROM employee WHERE department_id = 1;


-- =============================================================================
-- 2.4 分组查询 GROUP BY
-- =============================================================================

-- 【语法】SELECT 字段, 聚合函数 FROM 表名 [WHERE 条件] GROUP BY 分组字段 [HAVING 分组后条件];

-- 【核心规则】
-- 1. 分组后，SELECT 只能查询 分组字段 和 聚合函数
-- 2. WHERE 在分组前过滤，不能使用聚合函数
-- 3. HAVING 在分组后过滤，可以使用聚合函数

-- 按性别分组，统计男女员工数量
SELECT gender AS 性别, COUNT(*) AS 人数 FROM employee GROUP BY gender;

-- 按部门分组，统计每个部门的平均工资
SELECT department_id AS 部门ID, AVG(salary) AS 平均工资 
FROM employee 
GROUP BY department_id;

-- 按部门分组，统计每个部门员工数量，只显示人数大于2的部门
SELECT department_id AS 部门ID, COUNT(*) AS 人数 
FROM employee 
GROUP BY department_id 
HAVING COUNT(*) > 2;

-- -----------------------------------------------------------------------------
-- 【WHERE vs HAVING 对比】
-- -----------------------------------------------------------------------------
-- | 区别点   | WHERE                  | HAVING               |
-- |----------|------------------------|----------------------|
-- | 执行时机 | 分组前过滤             | 分组后过滤           |
-- | 过滤对象 | 原始表中的行           | 分组后的结果         |
-- | 聚合函数 | ❌ 不能使用            | ✅ 可以使用          |
-- -----------------------------------------------------------------------------

-- 综合示例：查询年龄大于25的员工，按部门分组，筛选平均工资大于10000的部门
SELECT department_id AS 部门ID, AVG(salary) AS 平均工资
FROM employee
WHERE age > 25                  -- 分组前：过滤年龄 > 25
GROUP BY department_id
HAVING AVG(salary) > 10000;     -- 分组后：过滤平均工资 > 10000


-- =============================================================================
-- 2.5 排序查询 ORDER BY
-- =============================================================================

-- 【语法】SELECT 字段 FROM 表名 ORDER BY 字段1 [ASC|DESC], 字段2 [ASC|DESC];
-- ASC：升序（默认）  DESC：降序

-- 按工资升序排列
SELECT * FROM employee ORDER BY salary ASC;
SELECT * FROM employee ORDER BY salary;  -- 等价写法（默认升序）

-- 按工资降序排列
SELECT * FROM employee ORDER BY salary DESC;

-- 多字段排序：先按年龄升序，年龄相同再按工资降序
SELECT * FROM employee ORDER BY age ASC, salary DESC;

-- 按入职日期降序，查询最近入职的员工
SELECT * FROM employee ORDER BY entry_date DESC;


-- =============================================================================
-- 2.6 分页查询 LIMIT
-- =============================================================================

-- 【语法】SELECT 字段 FROM 表名 LIMIT 起始索引, 查询条数;
-- 【起始索引】= (页码 - 1) × 每页条数
-- 【注意】MySQL 中 LIMIT 是最后执行的


所谓起始索引 和 每页查询条数 0,5 就是 0,1,2,3,4 索引的数据


-- 查询前5条记录（第1页，每页5条）
SELECT * FROM employee LIMIT 0, 5;
SELECT * FROM employee LIMIT 5;  -- 等价写法（起始索引为0可省略）

-- 查询第2页数据（每页5条，起始索引 = (2-1) × 5 = 5）
SELECT * FROM employee LIMIT 5, 5;

-- 查询第3页数据（每页5条，起始索引 = (3-1) × 5 = 10）
SELECT * FROM employee LIMIT 10, 5;

-- 另一种写法：LIMIT 条数 OFFSET 起始索引
SELECT * FROM employee LIMIT 5 OFFSET 5;  -- 等价于 LIMIT 5, 5


-- =============================================================================
-- 2.7 DQL 执行顺序总结
-- =============================================================================

-- 【编写顺序】
-- SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT

-- 【执行顺序】
-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT

-- 验证执行顺序：别名在 WHERE 中不能用，但在 ORDER BY 中可以用
SELECT name, salary AS sal FROM employee WHERE salary > 10000 ORDER BY sal DESC;
-- ✅ ORDER BY 可以使用别名 sal
-- ❌ WHERE 不能使用别名：WHERE sal > 10000 会报错

因为where的执行顺序在select之前 执行到where的时候还不知道字段被重命名了
order by 可以的原因是在select执行之后


where和having
看需不需要分组/用不用的上统计函数 

where在前 
1. 什么时候用 WHERE？
当你的筛选条件不需要用到求和（SUM）、平均值（AVG）、计数（COUNT）等统计函数时，必须使用 WHERE。

场景：HR 想要统计“技术部”中“年龄大于 25 岁”的员工分布。

SQL

SELECT department_id, COUNT(*) 
FROM employee
WHERE age > 25 AND department_id = 1  -- 这里的筛选针对每一位员工
GROUP BY department_id;
逻辑： 在把员工扔进各个部门的“桶”里之前，先把 25 岁以下的和非技术部的人直接“扔掉”。

优势： 效率高。数据库不需要处理那些根本不符合条件的行，节省内存和计算资源

having在后
2. 什么时候用 HAVING？
当你的筛选条件必须基于统计结果（聚合函数）时，只能使用 HAVING。

场景：财务部想要找出“平均工资超过 10,000 元”的部门。

SQL

SELECT department_id, AVG(salary)
FROM employee
GROUP BY department_id
HAVING AVG(salary) > 10000;  -- 这里的筛选针对的是“部门”这个组
逻辑： 数据库必须先查出所有员工，按部门分好组，算出每个组的平均分，然后才能判断哪个组留下来。

为什么不能用 WHERE？ 因为在 WHERE 执行的时候，数据库还没开始分组，它根本不知道每个部门的平均工资是多少。


综合应用
找出“工资大于 8,000 的员工”中，哪些“部门的平均工资超过了 12,000”

select department_id as '部门' , AVG(salary) as '部门平均工资' 
from employee 
where salary > 8000 
group by department_id 
having AVG(salary) > 12000;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第三部分：连接查询（JOIN）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 3.1 内连接 INNER JOIN
-- =============================================================================

-- 【作用】返回两表中满足连接条件的交集记录

-- 【语法1】显式内连接（推荐）
-- SELECT 字段 FROM 表1 INNER JOIN 表2 ON 连接条件;

-- 【语法2】隐式内连接
-- SELECT 字段 FROM 表1, 表2 WHERE 连接条件;

-- 查询所有员工及其部门名称
SELECT e.name AS 员工姓名, e. salary AS 工资, d.department_name AS 部门名称
FROM employee e
INNER JOIN department d
ON e.department_id = d.id;

-- 等价的隐式写法
SELECT e. name AS 员工姓名, e.salary AS 工资, d.department_name AS 部门名称
FROM employee e, department d
WHERE e.department_id = d. id;

-- 查询技术部所有员工
SELECT e.name AS 员工姓名, e.age AS 年龄, d.department_name AS 部门名称
FROM employee e
INNER JOIN department d
ON e.department_id = d. id
WHERE d. department_name = '技术部';

先找连接字段匹配on连接条件 
列出两个连接上的表 中间使用inner join连接两张表（这里可以给表重命名） 
然后添加on的匹配字段 后面加上where筛选条件  
最后在加上查询字段

-- =============================================================================
-- 3.2 左外连接 LEFT JOIN
-- =============================================================================

-- 【作用】返回左表所有记录 + 右表匹配的记录，右表无匹配则显示 NULL

-- 【语法】SELECT 字段 FROM 表1 LEFT JOIN 表2 ON 连接条件;

-- 查询所有员工及其部门（包括未分配部门的员工）
SELECT e.name AS 员工姓名, d.department_name AS 部门名称
FROM employee e
LEFT JOIN department d
ON e.department_id = d.id;
-- 结果中"郑十一"的部门名称为 NULL（因为 department_id 为 NULL）

-- 查询未分配部门的员工
SELECT e.name AS 员工姓名
FROM employee e
LEFT JOIN department d
ON e.department_id = d.id
WHERE d.id IS NULL;

先找到目标 员工 
连接表单 employee和department from后面使用left join 重点找人 特别是找右边为null的人
找到两张表连接字段 匹配on建立连接
列出员工匹配部门的所有然后再添加where条件筛出要求的那个人


-- =============================================================================
-- 3.3 右外连接 RIGHT JOIN
-- =============================================================================

-- 【作用】返回右表所有记录 + 左表匹配的记录，左表无匹配则显示 NULL

-- 【语法】SELECT 字段 FROM 表1 RIGHT JOIN 表2 ON 连接条件;

-- 查询所有部门及其员工（包括没有员工的部门）
SELECT d.department_name AS 部门名称, e.name AS 员工姓名
FROM employee e
RIGHT JOIN department d
ON e. department_id = d.id;
-- 结果中"市场部"没有员工，员工姓名显示 NULL
注意这里是找没有员工的部门 逻辑与上面相似 

-- -----------------------------------------------------------------------------
-- 【LEFT JOIN vs RIGHT JOIN 等价转换】
-- LEFT JOIN 和 RIGHT JOIN 可以通过交换表的顺序互相转换
-- -----------------------------------------------------------------------------
-- 以下两条 SQL 结果相同：
SELECT d.department_name, e.name FROM employee e RIGHT JOIN department d ON e.department_id = d.id;
SELECT d.department_name, e.name FROM department d LEFT JOIN employee e ON d.id = e.department_id;


-- =============================================================================
-- 3.4 自连接 Self Join
-- =============================================================================

-- 【作用】表与自身进行连接，用于处理层级关系（如员工-经理）

-- 【语法】SELECT 字段 FROM 表 AS 别名1 JOIN 表 AS 别名2 ON 连接条件;

-- 查询员工及其直属经理的姓名
SELECT e.name AS 员工姓名, m.name AS 经理姓名
FROM employee e
LEFT JOIN employee m
ON e.manager_id = m.id;
-- 使用 LEFT JOIN 保证没有经理的员工也能显示
注意还是使用的是left join 处理层级关系 记住这个例子


-- =============================================================================
-- 3.5 多表连接
-- =============================================================================

-- 查询员工姓名、部门名称、参与的项目名称
SELECT e. name AS 员工姓名, 
       d.department_name AS 部门名称, 
       p.project_name AS 项目名称,
       a.work_percentage AS 工作占比
FROM employee e
LEFT JOIN department d ON e.department_id = d.id
LEFT JOIN assignment a ON e.id = a.employee_id
LEFT JOIN project p ON a.project_id = p. id
ORDER BY e.name;
这里把order by 看成 group by了 注意后者使用了查询字段只能是分组字段和聚合函数

-- ═══════════════════════════════════════════════════════════════════════════════
-- 第四部分：子查询（嵌套查询）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 4.1 标量子查询（返回单个值）
-- =============================================================================

-- 【特点】子查询返回单行单列，可用于 = > < >= <= <> 比较

-- 查询工资高于平均工资的员工
SELECT name, salary FROM employee 
WHERE salary > (SELECT AVG(salary) FROM employee);

-- 查询与"张三"同部门的员工
SELECT name, department_id FROM employee
WHERE department_id = (SELECT department_id FROM employee WHERE name = '张三')
  AND name != '张三';

-- 查询工资最高的员工信息
SELECT * FROM employee 
WHERE salary = (SELECT MAX(salary) FROM employee);


-- =============================================================================
-- 4.2 列子查询（返回一列多行）
-- =============================================================================

-- 【特点】子查询返回多行单列，常用操作符：IN, NOT IN, ANY, SOME, ALL

多行单列就是从很多目标单元中的一个字段中筛选 一般用于子查询过程中

-- | 操作符 | 说明                                     |
-- |--------|------------------------------------------|
-- | IN     | 在列表中                                 |
-- | NOT IN | 不在列表中                               |
-- | ANY    | 满足任意一个即可（等价于 SOME）          |
-- | ALL    | 必须满足所有                             |

-- 查询"技术部"和"销售部"的所有员工
SELECT * FROM employee 
WHERE department_id IN (
    SELECT id FROM department WHERE department_name IN ('技术部', '销售部')
);

select e.* from employee e 
inner join department d on e.department_id = d.id 
where d.department_name in ('','');


-- 等价的 JOIN 写法
SELECT e.* FROM employee e
INNER JOIN department d ON e.department_id = d.id
WHERE d.department_name IN ('技术部', '销售部');

-- 查询工资比"销售部"所有人都高的员工
SELECT * FROM employee
WHERE salary > ALL (
    SELECT salary FROM employee 
    WHERE department_id = (SELECT id FROM department WHERE department_name = '销售部')
);

-- 查询工资比"销售部"任意一人高的员工
SELECT * FROM employee
WHERE salary > ANY (
    SELECT salary FROM employee 
    WHERE department_id = (SELECT id FROM department WHERE department_name = '销售部')
);


-- =============================================================================
-- 4.3 行子查询（返回一行多列）
-- =============================================================================

-- 【特点】子查询返回单行多列，用于多字段同时比较

这种行子查询 每次查询只返回一行 但是多个列 用于多字段的同时比较 比写两个AND条件更简洁

-- 查询与"李四"年龄和部门都相同的员工
SELECT * FROM employee
WHERE (age, department_id) = (SELECT age, department_id FROM employee WHERE name = '李四')
  AND name != '李四';


-- =============================================================================
-- 4.4 表子查询（返回多行多列）
-- =============================================================================

-- 【特点】子查询返回多行多列，作为临时表使用

-- 查询年龄大于25岁的员工及其部门名称
SELECT e.name, e.age, d. department_name
FROM (SELECT * FROM employee WHERE age > 25) e
LEFT JOIN department d ON e.department_id = d. id;


-- =============================================================================
-- 4.5 EXISTS 子查询
-- =============================================================================

-- 【特点】判断子查询是否有结果，有则返回 TRUE，无则返回 FALSE
-- 【优势】大数据量时效率通常优于 IN

-- 查询有员工的部门
SELECT * FROM department d
WHERE EXISTS (
    SELECT 1 FROM employee e WHERE e.department_id = d.id
);

-- 等价的 IN 写法
SELECT * FROM department
WHERE id IN (SELECT DISTINCT department_id FROM employee WHERE department_id IS NOT NULL);

-- 查询没有分配任务的员工
SELECT * FROM employee e
WHERE NOT EXISTS (
    SELECT 1 FROM assignment a WHERE a.employee_id = e.id
);

-- 等价的 LEFT JOIN 写法
SELECT e.* FROM employee e
LEFT JOIN assignment a ON e.id = a. employee_id
WHERE a.id IS NULL;

-- -----------------------------------------------------------------------------
-- 【IN vs EXISTS 对比】
-- -----------------------------------------------------------------------------
-- | 场景                 | 推荐使用 | 原因                           |
-- |----------------------|----------|--------------------------------|
-- | 子查询结果集小       | IN       | 子查询只执行一次               |
-- | 子查询结果集大       | EXISTS   | 主查询每行检查一次，可利用索引 |
-- | 子查询表远大于主表   | EXISTS   | 效率更高                       |
-- | 主表远大于子查询表   | IN       | 效率更高                       |
-- -----------------------------------------------------------------------------


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第五部分：高级查询技巧
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 5.1 UNION / UNION ALL 联合查询
-- =============================================================================

-- 【作用】将多个 SELECT 结果合并
-- 【区别】UNION 去重，UNION ALL 不去重

-- 查询年龄小于25或工资大于15000的员工（去重）
SELECT name, age, salary FROM employee WHERE age < 25
UNION
SELECT name, age, salary FROM employee WHERE salary > 15000;

-- 不去重版本
SELECT name, age, salary FROM employee WHERE age < 25
UNION ALL
SELECT name, age, salary FROM employee WHERE salary > 15000;

-- ⚠️ UNION 要求：列数相同，对应列的数据类型兼容
就是需要联合几个查询 两个查询字段都要对应相等


-- =============================================================================
-- 5.2 CASE WHEN 条件表达式
-- =============================================================================

-- 【语法】
-- CASE 
--     WHEN 条件1 THEN 结果1
--     WHEN 条件2 THEN 结果2
--     ELSE 默认结果
-- END

-- 根据工资划分等级
SELECT name, salary,
    CASE
        WHEN salary >= 15000 THEN '高薪'
        WHEN salary >= 10000 THEN '中等'
        WHEN salary >= 8000 THEN '一般'
        ELSE '低薪'
    END AS 工资等级
FROM employee;

-- 统计各工资等级人数
SELECT 
    CASE
        WHEN salary >= 15000 THEN '高薪'
        WHEN salary >= 10000 THEN '中等'
        WHEN salary >= 8000 THEN '一般'
        ELSE '低薪'
    END AS 工资等级,
    COUNT(*) AS 人数
FROM employee
GROUP BY 工资等级;


-- =============================================================================
-- 5.3 IFNULL / COALESCE 空值处理
-- =============================================================================

-- IFNULL(expr1, expr2)：如果 expr1 为 NULL，返回 expr2
SELECT name, IFNULL(phone, '未填写') AS 手机号 FROM employee;

-- COALESCE(expr1, expr2, ...)：返回第一个非 NULL 值
SELECT name, COALESCE(phone, '未填写') AS 手机号 FROM employee;


-- =============================================================================
-- 5.4 窗口函数（MySQL 8.0+）
-- =============================================================================

-- 【语法】函数名() OVER (PARTITION BY 分组字段 ORDER BY 排序字段)

-- | 函数         | 说明                                    |
-- |--------------|-----------------------------------------|
-- | ROW_NUMBER() | 行号，无并列（1,2,3,4）                 |
-- | RANK()       | 排名，有并列会跳过（1,2,2,4）           |
-- | DENSE_RANK() | 排名，有并列不跳过（1,2,2,3）           |
-- | SUM() OVER   | 累计求和                                |
-- | AVG() OVER   | 累计平均                                |

-- 各部门员工工资排名
SELECT name, department_id, salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank_num,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dense_rank_num
FROM employee
WHERE department_id IS NOT NULL;

-- 查询每个部门工资最高的员工
SELECT * FROM (
    SELECT e.*, d.department_name,
        RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS rk
    FROM employee e
    LEFT JOIN department d ON e.department_id = d.id
    WHERE e.department_id IS NOT NULL
) ranked
WHERE rk = 1;

-- 累计工资求和
SELECT name, salary,
    SUM(salary) OVER (ORDER BY entry_date) AS 累计工资
FROM employee;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第六部分：综合练习题
-- ═══════════════════════════════════════════════════════════════════════════════

-- 练习1：查询各部门平均工资，按平均工资降序排列

select d.department as 部门 , AVG(e.salary) as 平均工资
from employee e inner join department d on e.department_id = d.id 
group by d.department_name
order by 平均工资 这里可以用代名 因为order by 是在select后执行

SELECT d.department_name AS 部门, AVG(e. salary) AS 平均工资
FROM employee e
INNER JOIN department d ON e.department_id = d.id
GROUP BY d.department_name
ORDER BY 平均工资 DESC;

-- 练习2：查询工资高于本部门平均工资的员工
就是线筛出所有部门的平均工资 做成一个新的列表 命名为dept_avg 然后和employee inner join 使用部门id作为on连接条件
SELECT e.name, e.salary, e.department_id, dept_avg.avg_salary AS 部门平均工资
FROM employee e
INNER JOIN (
		子查询先找出每个部门的平均工资 以部门名称分类 要学会拆分问题
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employee
    GROUP BY department_id
) dept_avg
ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg. avg_salary;

-- 练习3：查询参与项目数量最多的员工
SELECT e.name AS 员工姓名, COUNT(a.project_id) AS 参与项目数
FROM employee e
LEFT JOIN assignment a ON e.id = a. employee_id
GROUP BY e.id, e.name
ORDER BY 参与项目数 DESC
LIMIT 1;

-- 练习4：查询每个部门的项目数量，包括没有项目的部门
SELECT d. department_name AS 部门, COUNT(p.id) AS 项目数量
FROM department d
LEFT JOIN project p ON d.id = p.department_id
GROUP BY d.department_name;

-- 练习5：查询没有参与任何项目且没有分配部门的员工
SELECT e.name AS 员工姓名
FROM employee e
LEFT JOIN assignment a ON e.id = a. employee_id
WHERE a.id IS NULL AND e.department_id IS NULL;

select e.name as 姓名
from employee e 
where e.department_id is null 
and not exists (
		select 1 from assignment a where a.employee_id = e.id
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 第七部分：关键语法速查表
-- ═══════════════════════════════════════════════════════════════════════════════

/*
┌───────────────────────────────────────────────────────────────────────────────┐
│                           SQL 查询语法速查表                                   │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【基础查询】                                                                   │
│   SELECT 字段 FROM 表 WHERE 条件 GROUP BY 分组 HAVING 分组条件                │
│   ORDER BY 排序字段 LIMIT 偏移, 条数;                                          │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【执行顺序】                                                                   │
│   FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT               │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【连接类型】                                                                   │
│   INNER JOIN  →  交集（两表都有的记录）                                        │
│   LEFT JOIN   →  左表全部 + 右表匹配                                          │
│   RIGHT JOIN  →  右表全部 + 左表匹配                                          │
│   SELF JOIN   →  表与自身连接                                                 │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【子查询类型】                                                                 │
│   标量子查询  →  返回单值，用于 = > < 比较                                    │
│   列子查询    →  返回一列，用于 IN, ANY, ALL                                  │
│   行子查询    →  返回一行，用于多字段比较 (a, b) = (SELECT ...)              │
│   表子查询    →  返回多行多列，作为临时表                                     │
│   EXISTS      →  判断是否存在，返回布尔值                                     │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【聚合函数】                                                                   │
│   COUNT(*), COUNT(字段), SUM(), AVG(), MAX(), MIN()                           │
│   ⚠️ 聚合函数忽略 NULL（COUNT(*) 除外）                                       │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【WHERE vs HAVING】                                                            │
│   WHERE   →  分组前过滤，不能用聚合函数                                       │
│   HAVING  →  分组后过滤，可以用聚合函数                                       │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【IN vs EXISTS】                                                               │
│   子查询结果集小  →  用 IN                                                    │
│   子查询结果集大  →  用 EXISTS                                                │
├───────────────────────────────────────────────────────────────────────────────┤
│ 【常见等价写法】                                                               │
│   BETWEEN a AND b  ⟺  >= a AND <= b                                          │
│   IN (a, b, c)     ⟺  = a OR = b OR = c                                      │
│   NOT IN           ⟺  <> ALL                                                 │
│   ANY              ⟺  SOME                                                   │
│   LEFT JOIN + IS NULL  ⟺  NOT EXISTS                                         │
└───────────────────────────────────────────────────────────────────────────────┘
*/


-- ═══════════════════════════════════════════════════════════════════════════════
-- 📝 Day 1 复习完成！
-- 明天继续：完整性、安全性、事务、存储过程、触发器
-- ═══════════════════════════════════════════════════════════════════════════════