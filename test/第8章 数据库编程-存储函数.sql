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


-- ===============================================================================================
-- 案例1：存储过程：查询学生选课成绩详情（带条件过滤）
-- 根据输入的学号和可选的课程号，查询该学生的选课记录（含学生姓名、课程名、成绩、学分），支持只查指定课程或查询该学生所有选课记录。
-- ===============================================================================================

-- 创建存储过程：查询学生选课成绩详情（兼容 MySQL 5.7+）
DELIMITER // 
CREATE PROCEDURE GetStudentScoreDetail(
    IN p_sno CHAR(9),        -- 输入参数：学号（必填）
    IN p_cno CHAR(4)         -- 输入参数：课程号（可选，不写默认值，后续处理NULL）
)
BEGIN
    -- 关联三张表，查询完整信息（用IFNULL处理p_cno的默认逻辑）
    SELECT 
        s.sno AS 学号,
        s.sname AS 学生姓名,
        c.cno AS 课程号,
        c.cname AS 课程名,
        c.ccredit AS 学分,
        sc.grade AS 成绩
    FROM student s
    JOIN sc ON s.sno = sc.sno
    JOIN course c ON sc.cno = c.cno
    WHERE s.sno = p_sno  -- 过滤指定学号
      -- 若传入p_cno为NULL，则查询所有课程；否则查询指定课程
      AND sc.cno = IFNULL(p_cno, sc.cno);
END //
DELIMITER ;

-- 调用存储过程
-- 查询学号 200215121 的所有选课成绩：
CALL GetStudentScoreDetail('200215121', NULL);
-- 查询学号 200215121 选修课程号 1 的成绩：
CALL GetStudentScoreDetail('200215121', '1');


-- ===============================================================================================
-- 案例2：存储函数：计算学生平均成绩（含学分加权）
-- 根据输入的 学号，计算该学生的 学分加权平均成绩（核心逻辑：总成绩 =Σ(成绩 × 学分)，平均成绩 = 总成绩 ÷ 总学分），若学生无选课记录则返回 0。
-- ===============================================================================================
-- 创建存储函数：计算学生学分加权平均成绩（兼容 MySQL 5.7+）
DELIMITER //
CREATE FUNCTION CalculateWeightedAvgScore(p_sno CHAR(9))
RETURNS DECIMAL(5,2)  -- 返回值：保留2位小数的小数（如87.50）
DETERMINISTIC         -- 相同输入返回相同结果（优化性能，MySQL 5.7支持）
BEGIN
    DECLARE total_score DECIMAL(10,2);  -- 总成绩（成绩×学分之和）
    DECLARE total_credit SMALLINT;     -- 总学分
    DECLARE avg_score DECIMAL(5,2);    -- 加权平均成绩

    -- 计算总成绩和总学分（IFNULL处理无选课记录的情况）
    SELECT 
        IFNULL(SUM(sc.grade * c.ccredit), 0),  -- 无数据时返回0
        IFNULL(SUM(c.ccredit), 0)
    INTO total_score, total_credit
    FROM sc
    JOIN course c ON sc.cno = c.cno
    WHERE sc.sno = p_sno;

    -- 计算加权平均（避免除数为0）
    IF total_credit = 0 THEN
        SET avg_score = 0.00;
    ELSE
        SET avg_score = total_score / total_credit;
    END IF;

    RETURN avg_score;
END //
DELIMITER ;

-- 调用存储函数
-- 计算单个学生的加权平均成绩：
SELECT 
    sno AS 学号,
    sname AS 学生姓名,
    CalculateWeightedAvgScore(sno) AS 学分加权平均成绩
FROM student
WHERE sno = '200215121';

-- 计算所有学生的加权平均成绩：
SELECT 
    sno AS 学号,
    sname AS 学生姓名,
    CalculateWeightedAvgScore(sno) AS 学分加权平均成绩
FROM student;


-- ===============================================================================================
-- ===============================================================================================
-- ===============================================================================================
use liuq;
drop table if exists users;
drop table if exists orders;
DROP PROCEDURE IF EXISTS proc_get_7days_order;
DROP FUNCTION IF EXISTS func_get_7days_order;

-- 创建用户表（若不存在）
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID（自增主键，与订单表user_id关联）',
    username VARCHAR(50) NOT NULL COMMENT '用户名（不可为空）',
    phone VARCHAR(20) UNIQUE NOT NULL COMMENT '手机号（唯一，用于登录/验证）',
    email VARCHAR(100) UNIQUE COMMENT '邮箱（可选，唯一）',
    register_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间（默认当前时间）',
    user_status TINYINT NOT NULL DEFAULT 1 COMMENT '用户状态：1-正常，0-禁用',
    -- 索引优化：手机号查询（登录场景常用）
    INDEX idx_phone (phone)
) ;

-- 插入4个测试用户（user_id 1001~1004，与订单表关联）
INSERT INTO users (user_id, username, phone, email, register_time, user_status)
VALUES
(1001, '张三', '13800138001', 'zhangsan@example.com', '2025-09-15 09:30:00', 1),
(1002, '李四', '13900139002', 'lisi@example.com', '2025-09-20 14:15:00', 1),
(1003, '王五', '13700137003', 'wangwu@example.com', '2025-09-25 10:00:00', 1),
(1004, '赵六', '13600136004', 'zhaoliu@example.com', '2025-10-01 16:45:00', 1);
-- 查询所有用户数据
SELECT * FROM users;

-- 创建订单表（若不存在）
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID（自增主键）',
    user_id INT NOT NULL COMMENT '下单用户ID（关联用户表）',
    order_amount DECIMAL(10, 2) NOT NULL COMMENT '订单金额（保留2位小数）',
    order_status VARCHAR(20) NOT NULL DEFAULT '未支付' COMMENT '订单状态：未支付/已支付/已取消/已完成',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '订单创建时间（默认当前时间）',
    pay_time DATETIME NULL COMMENT '支付时间（未支付则为NULL）',
		
    -- 索引优化：查询用户订单、按状态筛选时提速
    INDEX idx_user_id (user_id),
    INDEX idx_order_status (order_status)
);

-- 插入10行测试数据
INSERT INTO orders (user_id, order_amount, order_status, create_time, pay_time)
VALUES
-- 用户1001：2个已支付订单
(1001, 199.99, '已支付', '2025-11-01 10:23:45', '2025-11-01 10:30:12'),
(1001, 359.00, '已支付', '2025-11-05 14:12:33', '2025-11-05 14:15:08'),
-- 用户1002：1个已完成、1个未支付
(1002, 89.50, '已完成', '2025-11-02 09:05:18', '2025-11-02 09:10:44'),
(1002, 299.00, '未支付', '2025-11-10 16:48:22', NULL),
-- 用户1003：2个已支付、1个已取消
(1003, 599.99, '已支付', '2025-11-03 11:30:00', '2025-11-03 11:35:21'),
(1003, 129.00, '已取消', '2025-11-07 15:20:10', NULL),
(1003, 459.00, '已支付', '2025-11-09 13:08:55', '2025-11-09 13:12:30'),
-- 用户1004：2个未支付、1个已完成
(1004, 79.99, '未支付', '2025-11-04 17:15:33', NULL),
(1004, 1599.00, '已完成', '2025-11-06 10:00:00', '2025-11-06 10:05:18'),
(1004, 239.00, '未支付', '2025-11-12 08:45:12', NULL);

-- 查询所有订单数据
SELECT * FROM orders;

 
-- ============================================================================================
-- 通过两个功能相似的案例，直观感受存储过程和存储函数二者语法差异：计算用户近 7 天的订单数。
-- ============================================================================================
-- 1. 存储过程实现（支持输出多个结果，用 OUT 参数返回）
-- ============================================================================================
DELIMITER //
DROP PROCEDURE IF EXISTS proc_get_7days_order;

-- 存储过程：通过 OUT 参数返回订单数（可扩展返回多个结果）
CREATE PROCEDURE proc_get_7days_order(
    IN p_user_id INT,          -- 输入参数： p_user_id（避免与表字段user_id冲突）
    OUT order_count INT,       -- 输出参数：订单数（可加多个OUT参数）
    OUT avg_amount DECIMAL(10,2)  -- 额外输出：平均订单金额
)
BEGIN
    -- 第一个结果：订单数
    SELECT COUNT(*) INTO order_count
    FROM  orders
    WHERE user_id = p_user_id AND create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
    -- CURDATE() ：获取 MySQL 服务器的当前日期（格式：YYYY-MM-DD），不含时分秒。
		-- INTERVAL 7 DAY	：定义 “时间间隔”：7 DAY 表示 “7天”（可灵活替换单位，如 3 HOUR 3 小时、1 MONTH 1 个月）。
		-- DATE_SUB(date, interval)	：日期 “减法” 函数：从第一个参数 date 中，减去第二个参数 interval 定义的时间间隔，返回新日期。
		
    -- 第二个结果：平均订单金额
    SELECT AVG(order_amount) INTO avg_amount
    FROM orders
    WHERE user_id = p_user_id AND create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
END //
DELIMITER ;

-- 调用存储过程：用用户变量接收输出结果
CALL proc_get_7days_order(1004, @cnt, @avg);
-- 查看结果
SELECT @cnt AS 近7天订单数, @avg AS 平均订单金额;

--- 测试前注意日期

-- ============================================================================================
-- 2. 存储函数实现（仅返回单一结果，嵌入 SQL 调用）
-- ============================================================================================

DELIMITER //
DROP FUNCTION IF EXISTS func_get_7days_order;

-- 存储函数：必须指定返回类型（RETURNS INT），通过 RETURN 返回结果
CREATE FUNCTION func_get_7days_order(user_id INT)
RETURNS INT  -- 明确返回值类型
DETERMINISTIC  -- 可选：相同输入返回相同结果，优化性能
BEGIN
    DECLARE cnt INT;  -- 局部变量存储结果
    SELECT COUNT(*) INTO cnt
    FROM orders
    WHERE user_id = user_id AND create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
    RETURN cnt;  -- 必须有且仅有一个 RETURN
END //
DELIMITER ;

-- 调用方式1：嵌入 SELECT 语句（核心优势）
SELECT user_id, func_get_7days_order(user_id) AS 近7天订单数
FROM users
WHERE user_id IN (1001, 1002, 1003);  -- 批量查询多个用户的订单数

-- 调用方式2：单独调用（用变量接收）
SET @cnt = func_get_7days_order(1001);
SELECT @cnt AS 近7天订单数;

