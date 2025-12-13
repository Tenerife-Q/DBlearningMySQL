-- 创建部门表
CREATE TABLE dept (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL
);

-- 创建员工表
CREATE TABLE emp (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2),
    age INT,
    dept_id INT,
    managerid INT,
    entrydate DATE,
    job VARCHAR(50),
    FOREIGN KEY (dept_id) REFERENCES dept(id)
);

-- 插入部门数据
INSERT INTO dept (name) VALUES 
('销售部'),
('市场部'),
('财务部'),
('研发部'),
('人事部');

-- 插入员工数据
INSERT INTO emp (name, salary, age, dept_id, managerid, entrydate, job) VALUES 
('张三', 8000.00, 28, 1, NULL, '2020-01-15', '销售经理'),
('李四', 4500.00, 25, 1, 1, '2021-03-20', '销售专员'),
('王五', 7500.00, 45, 2, NULL, '2018-06-10', '市场总监'),
('赵六', 4800.00, 52, 3, 3, '2015-11-30', '财务主管'),
('钱七', 9000.00, 35, 4, NULL, '2019-08-22', '研发经理'),
('孙八', 5500.00, 29, 4, 5, '2022-02-14', '研发工程师'),
('周九', 4200.00, 55, 1, 1, '2010-05-18', '销售顾问'),
('吴十', 6000.00, 32, 2, 3, '2020-09-05', '市场专员');

-- ========== 联合查询 UNION ==========
-- 将薪资低于5000的员工和年龄大于50岁的员工全部查询出来
SELECT * FROM emp WHERE salary < 5000
UNION ALL
SELECT * FROM emp WHERE age > 50;

-- 合并后去重
SELECT * FROM emp WHERE salary < 5000
UNION
SELECT * FROM emp WHERE age > 50;

-- ========== 子查询 - 标量子查询 ==========
-- 查询销售部的所有员工信息
SELECT * FROM emp WHERE dept_id = (SELECT id FROM dept WHERE name = '销售部');

-- 查询在张三入职之后的员工信息
SELECT * FROM emp WHERE entrydate > (SELECT entrydate FROM emp WHERE name = '张三');

-- ========== 子查询 - 列子查询 ==========
-- 查询销售部和市场部所有员工信息
SELECT * FROM emp WHERE dept_id IN (SELECT id FROM dept WHERE name = '销售部' OR name = '市场部');

-- 查询比财务部所有人工资都高的人
SELECT * FROM emp WHERE salary > ALL (SELECT salary FROM emp WHERE dept_id = (SELECT id FROM dept WHERE name = '财务部'));

-- 查询比研发部其中任意一个员工工资高的员工信息
SELECT * FROM emp WHERE salary > ANY (SELECT salary FROM emp WHERE dept_id = (SELECT id FROM dept WHERE name = '研发部'));

-- ========== 子查询 - 行子查询 ==========
-- 查询和李四的薪资及其直属领导相同的员工信息
SELECT * FROM emp WHERE (salary, managerid) = (SELECT salary, managerid FROM emp WHERE name = '李四');

-- ========== 子查询 - 表子查询 ==========
-- 查询与张三、王五职位和薪资相同的员工
SELECT * FROM emp WHERE (job, salary) IN (SELECT job, salary FROM emp WHERE name = '张三' OR name = '王五');

-- 查询入职日期是'2020-01-01'之后的员工及其部门信息
SELECT e.*, d.* FROM (SELECT * FROM emp WHERE entrydate > '2020-01-01') e 
LEFT JOIN dept d ON e.dept_id = d.id;

-- ========== 内连接 ==========
-- 隐式内连接：查询每一个员工姓名，及其关联部门名称
SELECT emp.name, dept.name FROM emp, dept WHERE emp.dept_id = dept.id;

-- 使用别名
SELECT e.name, d.name FROM emp e, dept d WHERE e.dept_id = d.id;

-- 显示内连接
SELECT e.name, d.name FROM emp e INNER JOIN dept d ON e.dept_id = d.id;

-- ========== 外连接 ==========
-- 左外连接：查询emp表的所有数据及其对应部门信息
SELECT e.*, d.name FROM emp e LEFT OUTER JOIN dept d ON e.dept_id = d.id;

-- 右外连接：查询dept表所有数据及其对应员工信息
SELECT d.*, e.* FROM emp e RIGHT OUTER JOIN dept d ON e.dept_id = d.id;

-- 使用左外连接实现同样的效果
SELECT d.*, e.* FROM dept d LEFT OUTER JOIN emp e ON e.dept_id = d.id;

-- ========== 自连接 ==========
-- 查询员工以及他领导的名字（内连接方式）
SELECT a.name AS '员工', b.name AS '领导' 
FROM emp a, emp b 
WHERE a.managerid = b.id;

-- 查询所有员工及其领导名字，如果没有领导也要查询出来（左外连接方式）
SELECT a.name AS '员工', b.name AS '领导' 
FROM emp a 
LEFT JOIN emp b ON a.managerid = b.id;