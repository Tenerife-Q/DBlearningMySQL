-- =============================================
-- 学生管理系统数据库脚本
-- 包含现代数据示例、连接查询和子查询
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS school_management;
USE school_management;

-- 删除已存在的表（如果存在）
DROP TABLE IF EXISTS students_tb;
DROP TABLE IF EXISTS classes_tb;

-- =============================================
-- 1. 创建表结构
-- =============================================

-- 创建班级表（主表）
CREATE TABLE classes_tb(
    class_id INT PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL,
    teacher_name VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建学生表（子表）
CREATE TABLE students_tb(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    class_id INT,
    enrollment_date DATE,
    
    -- 创建表时定义外键
    FOREIGN KEY (class_id) REFERENCES classes_tb(class_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =============================================
-- 2. 插入现代示例数据
-- =============================================

-- 插入班级数据
INSERT INTO classes_tb (class_id, class_name, teacher_name) VALUES
(101, '计算机科学2023级', '张教授'),
(102, '数据科学2023级', '李博士'),
(103, '人工智能2023级', '王教授'),
(104, '网络安全2023级', '赵老师'),
(105, '软件工程2023级', '刘教授');

-- 插入学生数据
INSERT INTO students_tb (student_id, student_name, email, phone, class_id, enrollment_date) VALUES
(2023001, '陈晓明', 'chenxiaoming@email.com', '13812345678', 101, '2023-09-01'),
(2023002, '林婉儿', 'linwaner@email.com', '13987654321', 101, '2023-09-01'),
(2023003, '吴宇森', 'wuyusen@email.com', '13611112222', 102, '2023-09-01'),
(2023004, '赵灵儿', 'zhaolinger@email.com', '13733334444', 102, '2023-09-01'),
(2023005, '孙悟饭', 'sunwufan@email.com', '13555556666', 103, '2023-09-01'),
(2023006, '周芷若', 'zhouzhiruo@email.com', '13477778888', 103, '2023-09-01'),
(2023007, '郑小龙', 'zhengxiaolong@email.com', '13399990000', 104, '2023-09-01'),
(2023008, '王语嫣', 'wangyuyan@email.com', '13212341234', 104, '2023-09-01'),
(2023009, '冯宝宝', 'fengbaobao@email.com', '13156785678', 105, '2023-09-01'),
(2023010, '楚云飞', 'chuyunfei@email.com', '13098769876', 105, '2023-09-01'),
(2023011, '慕容复', 'murongfu@email.com', '15912345678', 101, '2023-09-01'),
(2023012, '黄蓉', 'huangrong@email.com', '15887654321', 102, '2023-09-01');

-- =============================================
-- 3. 连接查询示例
-- =============================================

-- 示例3.1: 内连接 - 查询所有学生及其班级详细信息
SELECT '=== 内连接：所有学生及班级信息 ===' AS '';
SELECT 
    s.student_id,
    s.student_name,
    s.email,
    c.class_name,
    c.teacher_name
FROM students_tb s
INNER JOIN classes_tb c ON s.class_id = c.class_id
ORDER BY c.class_id, s.student_id;

-- 示例3.2: 左连接 - 查询所有学生（包括未分班的学生）
SELECT '=== 左连接：所有学生（含未分班） ===' AS '';
SELECT 
    s.student_id,
    s.student_name,
    IFNULL(c.class_name, '未分班') AS class_name,
    IFNULL(c.teacher_name, '暂无') AS teacher_name
FROM students_tb s
LEFT JOIN classes_tb c ON s.class_id = c.class_id
ORDER BY s.student_id;

-- 示例3.3: 右连接 - 查询所有班级（包括没有学生的班级）
-- 先插入一个空班级用于演示
INSERT INTO classes_tb (class_id, class_name, teacher_name) 
VALUES (106, '物联网2023级', '钱教授');

SELECT '=== 右连接：所有班级（含无学生班级） ===' AS '';
SELECT 
    c.class_name,
    c.teacher_name,
    COUNT(s.student_id) AS student_count
FROM students_tb s
RIGHT JOIN classes_tb c ON s.class_id = c.class_id
GROUP BY c.class_id, c.class_name, c.teacher_name
ORDER BY c.class_id;

-- =============================================
-- 4. 子查询示例
-- =============================================

-- 示例4.1: WHERE子查询 - 查询特定老师所教的学生
SELECT '=== WHERE子查询：张教授的学生 ===' AS '';
SELECT 
    student_id,
    student_name,
    email
FROM students_tb
WHERE class_id IN (
    SELECT class_id 
    FROM classes_tb 
    WHERE teacher_name LIKE '%张教授%'
);

-- 示例4.2: SELECT子查询 - 查询学生信息并显示班级人数
SELECT '=== SELECT子查询：学生信息及班级人数 ===' AS '';
SELECT 
    student_id,
    student_name,
    class_id,
    (SELECT class_name FROM classes_tb WHERE class_id = students_tb.class_id) AS class_name,
    (SELECT COUNT(*) FROM students_tb s2 WHERE s2.class_id = students_tb.class_id) AS class_student_count
FROM students_tb
ORDER BY class_id, student_id;

-- 示例4.3: FROM子查询 - 查询各班级统计信息
SELECT '=== FROM子查询：班级统计信息 ===' AS '';
SELECT 
    c.class_id,
    c.class_name,
    c.teacher_name,
    IFNULL(stats.student_count, 0) AS student_count,
    IFNULL(stats.avg_id, 0) AS average_student_id
FROM classes_tb c
LEFT JOIN (
    SELECT 
        class_id,
        COUNT(*) AS student_count,
        AVG(student_id) AS avg_id
    FROM students_tb
    GROUP BY class_id
) stats ON c.class_id = stats.class_id
ORDER BY c.class_id;

-- =============================================
-- 5. 综合查询练习
-- =============================================

-- 练习5.1: 统计每个班级的学生人数和联系方式
SELECT '=== 综合练习1：班级统计详情 ===' AS '';
SELECT 
    c.class_id,
    c.class_name,
    c.teacher_name,
    COUNT(s.student_id) AS total_students,
    GROUP_CONCAT(s.student_name ORDER BY s.student_id SEPARATOR ', ') AS student_list
FROM classes_tb c
LEFT JOIN students_tb s ON c.class_id = s.class_id
GROUP BY c.class_id, c.class_name, c.teacher_name
HAVING total_students > 0
ORDER BY total_students DESC;

-- 练习5.2: 查找学生人数最多的班级
SELECT '=== 综合练习2：人数最多的班级 ===' AS '';
SELECT 
    c.class_name,
    c.teacher_name,
    COUNT(*) AS student_count
FROM classes_tb c
JOIN students_tb s ON c.class_id = s.class_id
GROUP BY c.class_id, c.class_name, c.teacher_name
HAVING student_count = (
    SELECT MAX(student_count) 
    FROM (
        SELECT COUNT(*) AS student_count
        FROM students_tb
        GROUP BY class_id
    ) AS count_table
);

-- 练习5.3: 查询学生详情及班级信息（综合查询）
SELECT '=== 综合练习3：学生完整档案 ===' AS '';
SELECT 
    s.student_id,
    s.student_name,
    s.email,
    s.phone,
    c.class_name,
    c.teacher_name,
    s.enrollment_date,
    (SELECT COUNT(*) FROM students_tb s2 WHERE s2.class_id = s.class_id) AS classmates_count
FROM students_tb s
JOIN classes_tb c ON s.class_id = c.class_id
WHERE s.enrollment_date >= '2023-09-01'
ORDER BY c.class_name, s.student_name;

-- =============================================
-- 6. 外键约束测试
-- =============================================

SELECT '=== 外键约束测试 ===' AS '';

-- 测试6.1: 成功插入（存在的班级ID）
INSERT INTO students_tb (student_id, student_name, email, class_id, enrollment_date) 
VALUES (2023013, '测试学生', 'test@email.com', 101, '2023-09-01');

SELECT '成功插入测试学生到101班级' AS '测试结果';

-- 测试6.2: 失败插入（不存在的班级ID）
-- 注意：这行会报错，所以注释掉在实际运行时使用
-- INSERT INTO students_tb (student_id, student_name, email, class_id, enrollment_date) 
-- VALUES (2023014, '错误测试', 'error@email.com', 999, '2023-09-01');
-- 预期错误：Cannot add or update a child row: a foreign key constraint fails

SELECT '尝试插入不存在的班级ID会失败（外键约束生效）' AS '测试结果';

-- 测试6.3: 清理测试数据
DELETE FROM students_tb WHERE student_id = 2023013;
SELECT '清理测试数据完成' AS '';

-- =============================================
-- 7. 数据验证和总结查询
-- =============================================

SELECT '=== 数据验证：班级表 ===' AS '';
SELECT * FROM classes_tb ORDER BY class_id;

SELECT '=== 数据验证：学生表 ===' AS '';
SELECT 
    student_id,
    student_name,
    email,
    class_id,
    enrollment_date
FROM students_tb 
ORDER BY class_id, student_id;

SELECT '=== 系统总结 ===' AS '';
SELECT 
    '数据库状态' AS item,
    '正常' AS status,
    CONCAT(COUNT(*), ' 个班级') AS details
FROM classes_tb
UNION ALL
SELECT 
    '数据统计' AS item,
    '正常' AS status,
    CONCAT(COUNT(*), ' 名学生') AS details
FROM students_tb
UNION ALL
SELECT 
    '外键约束' AS item,
    '已启用' AS status,
    'students_tb.class_id → classes_tb.class_id' AS details
FROM dual;

-- =============================================
-- 脚本执行完成
-- =============================================
SELECT '=== 脚本执行完成 ===' AS '';