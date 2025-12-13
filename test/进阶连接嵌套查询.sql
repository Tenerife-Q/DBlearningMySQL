-- 创建数据库和表
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

-- 创建部门表
CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    budget DECIMAL(12,2)
);

-- 创建职位表
CREATE TABLE positions (
    position_id INT PRIMARY KEY AUTO_INCREMENT,
    position_name VARCHAR(50) NOT NULL,
    level VARCHAR(20)
);

-- 创建员工表
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2),
    age INT,
    dept_id INT,
    manager_id INT,
    position_id INT,
    hire_date DATE,
    email VARCHAR(100),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id),
    FOREIGN KEY (position_id) REFERENCES positions(position_id)
);

-- 创建项目表
CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    status VARCHAR(20)
);

-- 创建员工项目关联表
CREATE TABLE emp_projects (
    emp_id INT,
    project_id INT,
    role VARCHAR(50),
    hours_worked DECIMAL(5,2),
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- 插入部门数据
INSERT INTO departments (dept_name, location, budget) VALUES 
('技术研发部', '北京总部', 5000000.00),
('市场营销部', '上海分公司', 3000000.00),
('人力资源部', '北京总部', 1500000.00),
('财务部', '北京总部', 2000000.00),
('产品设计部', '深圳分公司', 1800000.00),
('客户服务部', '广州分公司', 1200000.00);

-- 插入职位数据
INSERT INTO positions (position_name, level) VALUES 
('技术总监', '高层管理'),
('高级工程师', '资深'),
('软件工程师', '中级'),
('初级开发', '初级'),
('市场总监', '高层管理'),
('市场专员', '中级'),
('HR经理', '中层管理'),
('招聘专员', '初级'),
('财务经理', '中层管理'),
('会计', '中级'),
('UI设计师', '中级'),
('产品经理', '中层管理');

-- 插入员工数据
INSERT INTO employees (emp_name, salary, age, dept_id, manager_id, position_id, hire_date, email) VALUES 
('张明', 35000.00, 45, 1, NULL, 1, '2015-03-15', 'zhangming@company.com'),
('李华', 25000.00, 38, 1, 1, 2, '2017-08-20', 'lihua@company.com'),
('王强', 18000.00, 32, 1, 2, 3, '2019-05-10', 'wangqiang@company.com'),
('赵雪', 12000.00, 26, 1, 2, 4, '2021-02-28', 'zhaoxue@company.com'),
('刘洋', 28000.00, 42, 2, NULL, 5, '2016-11-05', 'liuyang@company.com'),
('陈静', 15000.00, 29, 2, 5, 6, '2020-07-15', 'chenjing@company.com'),
('杨光', 22000.00, 35, 3, NULL, 7, '2018-04-22', 'yangguang@company.com'),
('周婷', 10000.00, 24, 3, 7, 8, '2022-01-10', 'zhouting@company.com'),
('吴刚', 24000.00, 40, 4, NULL, 9, '2017-09-30', 'wugang@company.com'),
('郑丽', 13000.00, 28, 4, 9, 10, '2020-03-18', 'zhengli@company.com'),
('孙磊', 16000.00, 31, 5, NULL, 12, '2019-08-25', 'sunlei@company.com'),
('钱芳', 14000.00, 27, 5, 11, 11, '2021-06-12', 'qianfang@company.com');

-- 插入项目数据
INSERT INTO projects (project_name, start_date, end_date, budget, status) VALUES 
('电商平台重构', '2023-01-15', '2023-12-31', 1200000.00, '进行中'),
('移动App开发', '2023-03-01', '2023-10-30', 800000.00, '已完成'),
('数据分析系统', '2023-06-01', '2024-02-28', 950000.00, '进行中'),
('官网改版项目', '2023-02-15', '2023-08-15', 450000.00, '已完成'),
('智能客服系统', '2023-04-10', '2023-11-30', 680000.00, '进行中');

-- 插入员工项目关联数据
INSERT INTO emp_projects (emp_id, project_id, role, hours_worked) VALUES 
(2, 1, '技术负责人', 320.50),
(3, 1, '后端开发', 280.75),
(4, 1, '前端开发', 265.25),
(2, 2, '架构师', 180.00),
(3, 2, '核心开发', 220.50),
(4, 2, '移动端开发', 195.75),
(5, 3, '项目经理', 150.25),
(6, 3, '业务分析师', 175.50),
(11, 4, '产品负责人', 120.75),
(12, 4, 'UI设计师', 145.25),
(2, 5, '技术顾问', 90.00),
(3, 5, '系统集成', 135.50);

-- ========== 联合查询 UNION ==========
-- 案例1：查询薪资低于15000或年龄大于35岁的员工
SELECT emp_id, emp_name, salary, age, '薪资低于15000' as reason 
FROM employees WHERE salary < 15000
UNION
SELECT emp_id, emp_name, salary, age, '年龄大于35岁' as reason 
FROM employees WHERE age > 35;

-- 案例2：查询技术研发部或产品设计部的员工（不去重）
SELECT e.emp_id, e.emp_name, d.dept_name 
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id 
WHERE d.dept_name = '技术研发部'
UNION ALL
SELECT e.emp_id, e.emp_name, d.dept_name 
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id 
WHERE d.dept_name = '产品设计部';

-- ========== 标量子查询 ==========
-- 案例1：查询薪资高于平均薪资的员工
SELECT emp_name, salary 
FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 案例2：查询最早入职的员工信息
SELECT emp_name, hire_date, dept_id 
FROM employees 
WHERE hire_date = (SELECT MIN(hire_date) FROM employees);

-- 案例3：查询预算最高的部门信息
SELECT dept_name, budget 
FROM departments 
WHERE budget = (SELECT MAX(budget) FROM departments);

-- ========== 列子查询 ==========
-- 案例1：查询所有在预算超过200万的部门工作的员工
SELECT emp_name, dept_id 
FROM employees 
WHERE dept_id IN (SELECT dept_id FROM departments WHERE budget > 2000000);

-- 案例2：查询比所有市场部员工薪资都高的员工
SELECT emp_name, salary 
FROM employees 
WHERE salary > ALL (
    SELECT salary FROM employees 
    WHERE dept_id = (SELECT dept_id FROM departments WHERE dept_name = '市场营销部')
);

-- 案例3：查询比任一技术研发部员工薪资高的员工
SELECT emp_name, salary 
FROM employees 
WHERE salary > ANY (
    SELECT salary FROM employees 
    WHERE dept_id = (SELECT dept_id FROM departments WHERE dept_name = '技术研发部')
);

-- ========== 行子查询 ==========
-- 案例1：查询与李华职位和薪资都相同的员工
SELECT emp_name, position_id, salary 
FROM employees 
WHERE (position_id, salary) = (
    SELECT position_id, salary 
    FROM employees 
    WHERE emp_name = '李华'
);

-- 案例2：查询与王强部门和直属领导都相同的员工
SELECT emp_name, dept_id, manager_id 
FROM employees 
WHERE (dept_id, manager_id) = (
    SELECT dept_id, manager_id 
    FROM employees 
    WHERE emp_name = '王强'
);

-- ========== 表子查询 ==========
-- 案例1：查询2020年以后入职的员工及其部门信息
SELECT e.emp_name, e.hire_date, d.dept_name, d.location 
FROM (SELECT * FROM employees WHERE hire_date > '2020-01-01') e 
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- 案例2：查询薪资排名前3的员工及其项目参与情况
SELECT e.emp_name, e.salary, ep.project_id, ep.role 
FROM (SELECT * FROM employees ORDER BY salary DESC LIMIT 3) e 
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id;

-- ========== 内连接 ==========
-- 案例1：隐式内连接 - 查询员工及其部门信息
SELECT e.emp_name, e.salary, d.dept_name, d.location 
FROM employees e, departments d 
WHERE e.dept_id = d.dept_id;

-- 案例2：显式内连接 - 查询员工及其职位信息
SELECT e.emp_name, p.position_name, p.level 
FROM employees e 
INNER JOIN positions p ON e.position_id = p.position_id;

-- 案例3：多表内连接 - 查询员工参与的项目的详细信息
SELECT e.emp_name, p.project_name, ep.role, ep.hours_worked 
FROM employees e 
INNER JOIN emp_projects ep ON e.emp_id = ep.emp_id 
INNER JOIN projects p ON ep.project_id = p.project_id;

-- ========== 外连接 ==========
-- 案例1：左外连接 - 查询所有员工及其参与的项目（包括没有参与项目的员工）
SELECT e.emp_name, p.project_name, ep.role 
FROM employees e 
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id 
LEFT JOIN projects p ON ep.project_id = p.project_id;

-- 案例2：右外连接 - 查询所有部门及其员工（包括没有员工的部门）
SELECT d.dept_name, e.emp_name, e.position_id 
FROM employees e 
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 案例3：左外连接 - 查询所有项目及其参与员工（包括没有员工参与的项目）
SELECT p.project_name, e.emp_name, ep.role 
FROM projects p 
LEFT JOIN emp_projects ep ON p.project_id = ep.project_id 
LEFT JOIN employees e ON ep.emp_id = e.emp_id;

-- ========== 自连接 ==========
-- 案例1：查询每个员工及其直接领导的姓名
SELECT e.emp_name AS '员工', m.emp_name AS '领导' 
FROM employees e 
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- 案例2：查询每个领导及其直接下属
SELECT m.emp_name AS '领导', e.emp_name AS '下属' 
FROM employees m 
INNER JOIN employees e ON m.emp_id = e.manager_id 
ORDER BY m.emp_name;

-- 案例3：查询没有下属的员工（基层员工）
SELECT emp_name, position_name 
FROM employees e 
INNER JOIN positions p ON e.position_id = p.position_id 
WHERE e.emp_id NOT IN (
    SELECT DISTINCT manager_id 
    FROM employees 
    WHERE manager_id IS NOT NULL
);

-- ========== 复杂嵌套查询 ==========
-- 案例1：查询参与项目数量最多的员工
SELECT e.emp_name, COUNT(ep.project_id) as project_count 
FROM employees e 
INNER JOIN emp_projects ep ON e.emp_id = ep.emp_id 
GROUP BY e.emp_id, e.emp_name 
HAVING COUNT(ep.project_id) = (
    SELECT MAX(project_count) 
    FROM (
        SELECT COUNT(project_id) as project_count 
        FROM emp_projects 
        GROUP BY emp_id
    ) as temp
);

-- 案例2：查询每个部门薪资最高的员工
SELECT d.dept_name, e.emp_name, e.salary 
FROM employees e 
INNER JOIN departments d ON e.dept_id = d.dept_id 
WHERE (e.dept_id, e.salary) IN (
    SELECT dept_id, MAX(salary) 
    FROM employees 
    GROUP BY dept_id
);

-- 案例3：查询薪资超过部门平均薪资的员工
SELECT e.emp_name, e.salary, d.dept_name, 
       (SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id) as dept_avg_salary
FROM employees e 
INNER JOIN departments d ON e.dept_id = d.dept_id 
WHERE e.salary > (SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id);

-- 案例4：查询参与预算最高项目的员工信息
SELECT e.emp_name, p.project_name, p.budget, ep.role 
FROM employees e 
INNER JOIN emp_projects ep ON e.emp_id = ep.emp_id 
INNER JOIN projects p ON ep.project_id = p.project_id 
WHERE p.budget = (SELECT MAX(budget) FROM projects);

-- 案例5：查询每个员工的总工作时长和参与项目数
SELECT e.emp_name, 
       COUNT(ep.project_id) as total_projects,
       COALESCE(SUM(ep.hours_worked), 0) as total_hours
FROM employees e 
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id 
GROUP BY e.emp_id, e.emp_name 
ORDER BY total_hours DESC;