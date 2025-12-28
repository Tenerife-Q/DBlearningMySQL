-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 Day 2 数据库高级特性复习总结
-- 📅 复习日期：2025-12-27
-- 🎯 目标：掌握完整性、安全性、事务、存储过程、存储函数、游标、触发器
-- ═══════════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第一部分：测试数据准备
-- ═══════════════════════════════════════════════════════════════════════════════

-- 创建测试数据库
DROP DATABASE IF EXISTS db_advanced;
CREATE DATABASE db_advanced DEFAULT CHARSET utf8mb4;
USE db_advanced;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第二部分：数据完整性（Integrity）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 2.1 三类完整性约束概述
-- =============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        三类完整性约束                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│  类型            │  含义                    │  实现方式                      │
│─────────────────────────────────────────────────────────────────────────────│
│  实体完整性      │  主键唯一且非空          │  PRIMARY KEY                   │
│  参照完整性      │  外键引用必须有效        │  FOREIGN KEY ...  REFERENCES    │
│  用户定义完整性  │  自定义业务规则          │  CHECK, NOT NULL, UNIQUE, DEFAULT│
└─────────────────────────────────────────────────────────────────────────────┘
*/


-- =============================================================================
-- 2.2 实体完整性 - PRIMARY KEY
-- =============================================================================

-- 【作用】保证表中每条记录的唯一标识
-- 【特点】自动具有 NOT NULL + UNIQUE 约束，一个表只能有一个主键

-- -----------------------------------------------------------------------------
-- 2.2.1 单字段主键
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS student;
CREATE TABLE student (
    sno CHAR(9) PRIMARY KEY,              -- 单字段主键：学号
    sname VARCHAR(20) NOT NULL,
    ssex CHAR(2),
    sage SMALLINT,
    sdept VARCHAR(20)
) COMMENT '学生表';

-- 等价写法：在表级定义主键
CREATE TABLE student2 (
    sno CHAR(9),
    sname VARCHAR(20) NOT NULL,
    ssex CHAR(2),
    sage SMALLINT,
    sdept VARCHAR(20),
    PRIMARY KEY (sno)                     -- 表级定义主键
) COMMENT '学生表2';

-- -----------------------------------------------------------------------------
-- 2.2.2 联合主键（多字段组合）
-- -----------------------------------------------------------------------------
-- 【场景】当单个字段无法唯一标识记录时，使用多个字段组合作为主键

DROP TABLE IF EXISTS sc;
CREATE TABLE sc (
    sno CHAR(9) NOT NULL,                 -- 学号
    cno CHAR(4) NOT NULL,                 -- 课程号
    grade SMALLINT,                       -- 成绩
    PRIMARY KEY (sno, cno)                -- 联合主键：(学号, 课程号) 组合唯一
) COMMENT '选课表';

-- 📌 联合主键含义：同一个学生选同一门课只能有一条记录
-- ✅ 允许：('001', 'C1'), ('001', 'C2'), ('002', 'C1')
-- ❌ 禁止：('001', 'C1') 出现两次

-- -----------------------------------------------------------------------------
-- 2.2.3 自增主键 AUTO_INCREMENT
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS department;
CREATE TABLE department (
    id INT PRIMARY KEY AUTO_INCREMENT,    -- 自增主键
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
) COMMENT '部门表';

-- 插入时不指定 id，系统自动分配
INSERT INTO department (dept_name, location) VALUES ('技术部', '北京');
INSERT INTO department (dept_name, location) VALUES ('销售部', '上海');
SELECT * FROM department;

-- 📌 AUTO_INCREMENT 特点：
-- 1. 必须是主键或唯一键
-- 2. 必须是整数类型
-- 3. 每次插入自动 +1


-- =============================================================================
-- 2.3 参照完整性 - FOREIGN KEY
-- =============================================================================

-- 【作用】保证表之间的引用关系有效
-- 【语法】FOREIGN KEY (本表字段) REFERENCES 被引用表(被引用字段) [动作]

-- -----------------------------------------------------------------------------
-- 2.3.1 创建带外键的表
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    dept_id INT,                          -- 外键字段
    salary DECIMAL(10, 2),
    
    -- 外键约束：dept_id 必须在 department 表的 id 中存在
    FOREIGN KEY (dept_id) REFERENCES department(id)
        ON DELETE RESTRICT                -- 删除策略：禁止删除被引用的记录
        ON UPDATE CASCADE                 -- 更新策略：级联更新
) COMMENT '员工表';

-- 插入测试数据
INSERT INTO employee (name, dept_id, salary) VALUES 
    ('张三', 1, 15000),
    ('李四', 1, 12000),
    ('王五', 2, 10000);

-- -----------------------------------------------------------------------------
-- 2.3.2 外键动作选项对比
-- -----------------------------------------------------------------------------

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        外键动作选项对比                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  动作          │  ON DELETE               │  ON UPDATE                      │
│─────────────────────────────────────────────────────────────────────────────│
│  RESTRICT      │  禁止删除父表记录        │  禁止更新父表主键               │
│  CASCADE       │  级联删除子表记录        │  级联更新子表外键               │
│  SET NULL      │  子表外键设为 NULL       │  子表外键设为 NULL              │
│  NO ACTION     │  同 RESTRICT             │  同 RESTRICT（SQL标准写法）     │
└─────────────────────────────────────────────────────────────────────────────┘

📌 选择建议：
   - RESTRICT：最安全，防止误删（默认行为）
   - CASCADE：适合"父子同生死"的场景（如删订单同时删订单明细）
   - SET NULL：适合"解除关联但保留记录"的场景
*/

-- -----------------------------------------------------------------------------
-- 2.3.3 外键约束验证
-- -----------------------------------------------------------------------------

-- ❌ 错误：违反参照完整性（部门ID不存在）
-- INSERT INTO employee (name, dept_id, salary) VALUES ('测试', 999, 8000);
-- 报错：Cannot add or update a child row:  a foreign key constraint fails

-- ❌ 错误：违反参照完整性（有员工引用该部门，无法删除）
-- DELETE FROM department WHERE id = 1;
-- 报错：Cannot delete or update a parent row:  a foreign key constraint fails

-- ✅ 正确删除顺序：先删子表，再删父表
-- DELETE FROM employee WHERE dept_id = 1;
-- DELETE FROM department WHERE id = 1;

-- ✅ 测试级联更新：修改部门ID，员工表自动同步
UPDATE department SET id = 100 WHERE id = 1;
SELECT * FROM employee;  -- dept_id 自动变成 100


-- =============================================================================
-- 2.4 用户定义完整性
-- =============================================================================

-- 【作用】根据业务需求自定义约束规则

-- -----------------------------------------------------------------------------
-- 2.4.1 NOT NULL - 非空约束
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS test_not_null;
CREATE TABLE test_not_null (
    id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL             -- 非空约束
);

-- ❌ 错误：name 不能为空
-- INSERT INTO test_not_null VALUES (1, NULL);

-- ✅ 正确
INSERT INTO test_not_null VALUES (1, '张三');

-- -----------------------------------------------------------------------------
-- 2.4.2 UNIQUE - 唯一约束
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS test_unique;
CREATE TABLE test_unique (
    id INT PRIMARY KEY,
    phone CHAR(11) UNIQUE,                -- 唯一约束
    email VARCHAR(50) UNIQUE
);

-- ✅ 允许：NULL 不算重复
INSERT INTO test_unique VALUES (1, '13800001111', NULL);
INSERT INTO test_unique VALUES (2, NULL, NULL);  -- 多个 NULL 允许

-- ❌ 错误：手机号重复
-- INSERT INTO test_unique VALUES (3, '13800001111', 'test@test.com');

-- 📌 UNIQUE vs PRIMARY KEY 区别：
-- | 特性     | PRIMARY KEY | UNIQUE  |
-- |----------|-------------|---------|
-- | 允许NULL | ❌          | ✅      |
-- | 数量限制 | 只能1个     | 可多个  |

-- -----------------------------------------------------------------------------
-- 2.4.3 CHECK - 检查约束
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS test_check;
CREATE TABLE test_check (
    id INT PRIMARY KEY,
    age SMALLINT CHECK (age > 0 AND age < 150),           -- 年龄范围
    gender CHAR(2) CHECK (gender IN ('男', '女')),        -- 性别枚举
    score DECIMAL(5,2) CHECK (score BETWEEN 0 AND 100)    -- 成绩范围
);

-- ✅ 正确
INSERT INTO test_check VALUES (1, 20, '男', 85. 5);

-- ❌ 错误：年龄超出范围
-- INSERT INTO test_check VALUES (2, 200, '男', 60);

-- ❌ 错误：性别不在枚举中
-- INSERT INTO test_check VALUES (3, 25, '未知', 70);

-- 📌 MySQL 8.0.16+ 才真正强制执行 CHECK 约束！

-- -----------------------------------------------------------------------------
-- 2.4.4 DEFAULT - 默认值约束
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS test_default;
CREATE TABLE test_default (
    id INT PRIMARY KEY,
    status TINYINT DEFAULT 1,                             -- 默认状态为1
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP        -- 默认当前时间
);

-- 不指定字段时使用默认值
INSERT INTO test_default (id) VALUES (1);
SELECT * FROM test_default;


-- =============================================================================
-- 2.5 完整性约束综合示例
-- =============================================================================

-- 创建完整的学生-课程-选课表结构
DROP TABLE IF EXISTS sc_full;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student_full;

-- 学生表（实体完整性 + 用户定义完整性）
CREATE TABLE student_full (
    sno CHAR(9) PRIMARY KEY,                              -- 主键
    sname VARCHAR(20) NOT NULL,                           -- 非空
    ssex CHAR(2) CHECK (ssex IN ('男', '女')),            -- 检查约束
    sage SMALLINT CHECK (sage > 0 AND sage < 100),        -- 检查约束
    sdept VARCHAR(20) DEFAULT 'CS'                        -- 默认值
) COMMENT '学生表';

-- 课程表
CREATE TABLE course (
    cno CHAR(4) PRIMARY KEY,
    cname VARCHAR(40) NOT NULL,
    cpno CHAR(4),                                         -- 先行课
    ccredit SMALLINT CHECK (ccredit > 0)
) COMMENT '课程表';

-- 选课表（参照完整性）
CREATE TABLE sc_full (
    sno CHAR(9) NOT NULL,
    cno CHAR(4) NOT NULL,
    grade SMALLINT CHECK (grade BETWEEN 0 AND 100),
    PRIMARY KEY (sno, cno),                               -- 联合主键
    FOREIGN KEY (sno) REFERENCES student_full(sno)        -- 外键1
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cno) REFERENCES course(cno)              -- 外键2
        ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT '选课表';


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第三部分：数据库安全性（Security）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 3.1 用户管理
-- =============================================================================

-- 【语法】用户名@主机名 构成完整的用户标识

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        主机名含义                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  主机名          │  含义                    │  使用场景                      │
│─────────────────────────────────────────────────────────────────────────────│
│  localhost       │  仅本机可登录            │  本地开发测试                  │
│  %               │  任意主机可登录          │  远程访问                      │
│  192.168.1.%     │  特定网段可登录          │  内网访问                      │
│  192.168.1.100   │  指定IP可登录            │  精确控制                      │
└─────────────────────────────────────────────────────────────────────────────┘
*/

-- -----------------------------------------------------------------------------
-- 3.1.1 创建用户
-- -----------------------------------------------------------------------------

-- 创建本地用户（只能从本机登录）
-- CREATE USER 'zhangsan'@'localhost' IDENTIFIED BY 'password123';

-- 创建远程用户（可从任意主机登录）
-- CREATE USER 'lisi'@'%' IDENTIFIED BY 'password456';

-- 📌 语法解析：
-- CREATE USER '用户名'@'主机名' IDENTIFIED BY '密码';

-- -----------------------------------------------------------------------------
-- 3.1.2 修改用户密码
-- -----------------------------------------------------------------------------

-- 方式1：ALTER USER（推荐）
-- ALTER USER 'zhangsan'@'localhost' IDENTIFIED BY 'newpassword';

-- 方式2：使用 mysql_native_password 插件
-- ALTER USER 'zhangsan'@'localhost' 
-- IDENTIFIED WITH mysql_native_password BY 'newpassword';

-- -----------------------------------------------------------------------------
-- 3.1.3 删除用户
-- -----------------------------------------------------------------------------

-- 删除单个用户
-- DROP USER 'zhangsan'@'localhost';

-- 删除多个用户
-- DROP USER 'user1'@'localhost', 'user2'@'%';

-- -----------------------------------------------------------------------------
-- 3.1.4 查看用户
-- -----------------------------------------------------------------------------

-- 查看所有用户
SELECT user, host FROM mysql.user;


-- =============================================================================
-- 3.2 权限管理
-- =============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        常用权限列表                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  权限            │  说明                                                    │
│─────────────────────────────────────────────────────────────────────────────│
│  SELECT          │  查询数据                                                │
│  INSERT          │  插入数据                                                │
│  UPDATE          │  更新数据                                                │
│  DELETE          │  删除数据                                                │
│  CREATE          │  创建数据库/表                                           │
│  DROP            │  删除数据库/表                                           │
│  ALTER           │  修改表结构                                              │
│  INDEX           │  创建/删除索引                                           │
│  ALL PRIVILEGES  │  所有权限                                                │
└─────────────────────────────────────────────────────────────────────────────┘
*/

-- -----------------------------------------------------------------------------
-- 3.2.1 授予权限 GRANT
-- -----------------------------------------------------------------------------

-- 【语法】GRANT 权限列表 ON 数据库. 表 TO '用户名'@'主机名';

-- 授予查询权限（指定数据库的所有表）
-- GRANT SELECT ON db_advanced.* TO 'zhangsan'@'localhost';

-- 授予多个权限
-- GRANT SELECT, INSERT, UPDATE, DELETE ON db_advanced. * TO 'zhangsan'@'localhost';

-- 授予所有权限（指定表）
-- GRANT ALL PRIVILEGES ON db_advanced.employee TO 'zhangsan'@'localhost';

-- 授予所有权限（所有数据库）+ 转授权限
-- GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;

/*
📌 权限范围说明：
   *.*              →  所有数据库的所有表（最高权限，仅管理员）
   db_advanced.*    →  指定数据库的所有表
   db_advanced. emp  →  指定数据库的指定表
   
📌 WITH GRANT OPTION：允许该用户将权限授予其他用户
*/

-- -----------------------------------------------------------------------------
-- 3.2.2 查看权限
-- -----------------------------------------------------------------------------

-- 查看当前用户权限
-- SHOW GRANTS;

-- 查看指定用户权限
-- SHOW GRANTS FOR 'zhangsan'@'localhost';

-- -----------------------------------------------------------------------------
-- 3.2.3 撤销权限 REVOKE
-- -----------------------------------------------------------------------------

-- 【语法】REVOKE 权限列表 ON 数据库.表 FROM '用户名'@'主机名';

-- 撤销查询权限
-- REVOKE SELECT ON db_advanced.* FROM 'zhangsan'@'localhost';

-- 撤销所有权限
-- REVOKE ALL PRIVILEGES ON *.* FROM 'admin'@'localhost';

-- 刷新权限（使更改立即生效）
-- FLUSH PRIVILEGES;


-- =============================================================================
-- 3.3 角色管理（MySQL 8.0+）
-- =============================================================================

-- 【作用】将一组权限打包成角色，方便批量授权

-- -----------------------------------------------------------------------------
-- 3.3.1 创建和使用角色
-- -----------------------------------------------------------------------------

-- 步骤1：创建角色
-- CREATE ROLE 'reader_role';
-- CREATE ROLE 'writer_role';

-- 步骤2：给角色授权
-- GRANT SELECT ON db_advanced.* TO 'reader_role';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON db_advanced.* TO 'writer_role';

-- 步骤3：将角色授予用户
-- GRANT 'reader_role' TO 'zhangsan'@'localhost';
-- GRANT 'writer_role' TO 'lisi'@'localhost';

-- 步骤4：激活角色（重要！）
-- 方式1：为用户设置默认角色（永久生效）
-- SET DEFAULT ROLE 'reader_role' TO 'zhangsan'@'localhost';

-- 方式2：全局开启自动激活（对所有用户生效）
-- SET GLOBAL activate_all_roles_on_login = ON;

-- -----------------------------------------------------------------------------
-- 3.3.2 撤销和删除角色
-- -----------------------------------------------------------------------------

-- 撤销用户的角色
-- REVOKE 'reader_role' FROM 'zhangsan'@'localhost';

-- 删除角色
-- DROP ROLE 'reader_role';
-- DROP ROLE 'writer_role';

/*
📌 角色 vs 直接授权对比：
   
   │  方式        │  优点                    │  缺点                      │
   │──────────────────────────────────────────────────────────────────│
   │  直接授权    │  简单直接                │  用户多时管理困难          │
   │  角色授权    │  统一管理，批量授权      │  需要激活步骤              │
*/


-- =============================================================================
-- 3.4 安全性综合示例
-- =============================================================================

/*
场景：公司有三类员工需要不同的数据库权限

1. 普通员工（只读权限）
   CREATE USER 'emp_user'@'localhost' IDENTIFIED BY 'emp123';
   GRANT SELECT ON company_db.* TO 'emp_user'@'localhost';

2. 部门经理（读写权限）
   CREATE USER 'mgr_user'@'localhost' IDENTIFIED BY 'mgr123';
   GRANT SELECT, INSERT, UPDATE ON company_db.* TO 'mgr_user'@'localhost';

3. 数据库管理员（全部权限）
   CREATE USER 'dba_user'@'localhost' IDENTIFIED BY 'dba123';
   GRANT ALL PRIVILEGES ON *.* TO 'dba_user'@'localhost' WITH GRANT OPTION;
*/


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第四部分：事务（Transaction）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 4.1 事务概述与 ACID 特性
-- =============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ACID 特性                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  特性        │  英文          │  含义                                       │
│─────────────────────────────────────────────────────────────────────────────│
│  原子性      │  Atomicity     │  事务中的操作要么全做，要么全不做           │
│  一致性      │  Consistency   │  事务执行前后数据状态一致                   │
│  隔离性      │  Isolation     │  并发事务互不干扰                           │
│  持久性      │  Durability    │  提交后数据永久保存                         │
└─────────────────────────────────────────────────────────────────────────────┘

📌 经典案例：银行转账
   - 原子性：扣款和入账必须同时成功或同时失败
   - 一致性：转账前后总金额不变
   - 隔离性：两人同时转账互不影响
   - 持久性：转账成功后即使断电也不丢失
*/


-- =============================================================================
-- 4.2 事务控制语句
-- =============================================================================

-- 创建测试表
DROP TABLE IF EXISTS account;
CREATE TABLE account (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    money DECIMAL(10, 2) NOT NULL
) COMMENT '账户表';

INSERT INTO account (name, money) VALUES ('张三', 2000), ('李四', 2000);
SELECT * FROM account;

-- -----------------------------------------------------------------------------
-- 4.2.1 方式一：手动控制自动提交
-- -----------------------------------------------------------------------------

-- 查看自动提交状态（1=开启，0=关闭）
SELECT @@autocommit;

-- 关闭自动提交
SET @@autocommit = 0;

-- 执行转账操作
UPDATE account SET money = money - 500 WHERE name = '张三';  -- 张三扣款
UPDATE account SET money = money + 500 WHERE name = '李四';  -- 李四入账

-- 确认无误后提交
COMMIT;

-- 如果出错则回滚
-- ROLLBACK;

-- 恢复自动提交
SET @@autocommit = 1;

-- -----------------------------------------------------------------------------
-- 4.2.2 方式二：显式开启事务（推荐）
-- -----------------------------------------------------------------------------

-- 恢复测试数据
UPDATE account SET money = 2000;

-- 开启事务
START TRANSACTION;  -- 或 BEGIN;

-- 执行转账操作
UPDATE account SET money = money - 500 WHERE name = '张三';
UPDATE account SET money = money + 500 WHERE name = '李四';

-- 查看当前状态（未提交，其他会话看不到变化）
SELECT * FROM account;

-- 提交事务
COMMIT;

-- 或者回滚事务
-- ROLLBACK;

/*
📌 两种方式对比：

   │  方式              │  语法                    │  特点                      │
   │────────────────────────────────────────────────────────────────────────────│
   │  关闭自动提交      │  SET @@autocommit = 0    │  全局生效，所有语句需手动提交│
   │  显式开启事务      │  START TRANSACTION       │  仅当前事务有效，更灵活     │
   
   💡 推荐使用 START TRANSACTION，更清晰明确
*/

-- -----------------------------------------------------------------------------
-- 4.2.3 事务完整示例
-- -----------------------------------------------------------------------------

-- 恢复测试数据
UPDATE account SET money = 2000;

-- 模拟转账业务
DELIMITER //

CREATE PROCEDURE Transfer(
    IN from_name VARCHAR(20),
    IN to_name VARCHAR(20),
    IN amount DECIMAL(10, 2),
    OUT result VARCHAR(50)
)
BEGIN
    -- 声明异常处理：出错时回滚
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET result = '转账失败，已回滚';
    END;
    
    -- 开启事务
    START TRANSACTION;
    
    -- 扣款
    UPDATE account SET money = money - amount WHERE name = from_name;
    
    -- 入账
    UPDATE account SET money = money + amount WHERE name = to_name;
    
    -- 提交事务
    COMMIT;
    SET result = '转账成功';
END //

DELIMITER ;

-- 测试转账
CALL Transfer('张三', '李四', 500, @result);
SELECT @result;
SELECT * FROM account;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第五部分：存储过程（Stored Procedure）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 5.1 存储过程基础语法
-- =============================================================================

/*
【语法结构】
DELIMITER //                        -- 修改分隔符
CREATE PROCEDURE 过程名(
    IN  参数名1 数据类型,           -- 输入参数
    OUT 参数名2 数据类型,           -- 输出参数
    INOUT 参数名3 数据类型          -- 输入输出参数
)
BEGIN
    DECLARE 变量名 数据类型 [DEFAULT 默认值];  -- 局部变量
    -- SQL 语句和逻辑
END //
DELIMITER ;                         -- 恢复分隔符

【调用】CALL 过程名(参数);
【删除】DROP PROCEDURE IF EXISTS 过程名;
【查看】SHOW CREATE PROCEDURE 过程名;
*/


-- =============================================================================
-- 5.2 参数类型详解
-- =============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        参数类型对比                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  类型     │  关键字  │  调用时        │  过程内修改  │  返回修改后的值      │
│─────────────────────────────────────────────────────────────────────────────│
│  输入参数 │  IN      │  必须传值      │  可以修改    │  ❌ 不返回           │
│  输出参数 │  OUT     │  传变量接收    │  可以修改    │  ✅ 返回             │
│  输入输出 │  INOUT   │  传值+接收     │  可以修改    │  ✅ 返回             │
└─────────────────────────────────────────────────────────────────────────────┘
*/

-- -----------------------------------------------------------------------------
-- 5.2.1 IN 参数示例
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS proc_in_demo;

DELIMITER //
CREATE PROCEDURE proc_in_demo(
    IN p_name VARCHAR(20)             -- 输入参数
)
BEGIN
    SELECT * FROM account WHERE name = p_name;
END //
DELIMITER ;

-- 调用
CALL proc_in_demo('张三');

-- -----------------------------------------------------------------------------
-- 5.2.2 OUT 参数示例
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS proc_out_demo;

DELIMITER //
CREATE PROCEDURE proc_out_demo(
    IN p_name VARCHAR(20),            -- 输入参数
    OUT p_money DECIMAL(10, 2)        -- 输出参数
)
BEGIN
    SELECT money INTO p_money FROM account WHERE name = p_name;
END //
DELIMITER ;

-- 调用（用 @变量 接收输出）
CALL proc_out_demo('张三', @result);
SELECT @result AS 张三的余额;

-- -----------------------------------------------------------------------------
-- 5.2.3 INOUT 参数示例
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS proc_inout_demo;

DELIMITER //
CREATE PROCEDURE proc_inout_demo(
    INOUT p_value INT                 -- 输入输出参数
)
BEGIN
    SET p_value = p_value * 2;        -- 翻倍
END //
DELIMITER ;

-- 调用
SET @num = 10;
CALL proc_inout_demo(@num);
SELECT @num AS 翻倍后的值;            -- 结果：20


-- =============================================================================
-- 5.3 变量
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 5.3.1 局部变量 DECLARE
-- -----------------------------------------------------------------------------
-- 【作用域】只在 BEGIN... END 块内有效
-- 【语法】DECLARE 变量名 数据类型 [DEFAULT 默认值];

DROP PROCEDURE IF EXISTS proc_local_var;

DELIMITER //
CREATE PROCEDURE proc_local_var()
BEGIN
    DECLARE v_count INT DEFAULT 0;           -- 声明并初始化
    DECLARE v_name VARCHAR(20);              -- 声明不初始化
    
    SELECT COUNT(*) INTO v_count FROM account;
    SET v_name = '测试';                      -- SET 赋值
    
    SELECT v_count AS 账户数量, v_name AS 测试名称;
END //
DELIMITER ;

CALL proc_local_var();

-- -----------------------------------------------------------------------------
-- 5.3.2 用户变量 @
-- -----------------------------------------------------------------------------
-- 【作用域】当前会话（连接）内有效
-- 【语法】@变量名（无需声明，直接使用）

SET @user_var = 100;
SELECT @user_var;

SELECT name, money INTO @n, @m FROM account LIMIT 1;
SELECT @n AS 姓名, @m AS 余额;

-- -----------------------------------------------------------------------------
-- 5.3.3 系统变量 @@
-- -----------------------------------------------------------------------------
-- 【类型】全局变量 @@global.  会话变量 @@session.  或 @@

SELECT @@autocommit;                 -- 会话级
SELECT @@global.max_connections;     -- 全局级


-- =============================================================================
-- 5.4 流程控制语句
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 5.4.1 IF 条件判断
-- -----------------------------------------------------------------------------
/*
【语法】
IF 条件1 THEN
    语句1;
ELSEIF 条件2 THEN
    语句2;
ELSE
    语句3;
END IF;
*/

DROP PROCEDURE IF EXISTS proc_if_demo;

DELIMITER //
CREATE PROCEDURE proc_if_demo(
    IN p_score INT,
    OUT p_level VARCHAR(10)
)
BEGIN
    IF p_score >= 90 THEN
        SET p_level = '优秀';
    ELSEIF p_score >= 80 THEN
        SET p_level = '良好';
    ELSEIF p_score >= 60 THEN
        SET p_level = '及格';
    ELSE
        SET p_level = '不及格';
    END IF;
END //
DELIMITER ;

CALL proc_if_demo(85, @level);
SELECT @level;

-- -----------------------------------------------------------------------------
-- 5.4.2 CASE 分支
-- -----------------------------------------------------------------------------
/*
【语法1】简单 CASE
CASE 表达式
    WHEN 值1 THEN 语句1;
    WHEN 值2 THEN 语句2;
    ELSE 语句3;
END CASE;

【语法2】搜索 CASE
CASE
    WHEN 条件1 THEN 语句1;
    WHEN 条件2 THEN 语句2;
    ELSE 语句3;
END CASE;
*/

DROP PROCEDURE IF EXISTS proc_case_demo;

DELIMITER //
CREATE PROCEDURE proc_case_demo(
    IN p_day INT,
    OUT p_name VARCHAR(10)
)
BEGIN
    CASE p_day
        WHEN 1 THEN SET p_name = '星期一';
        WHEN 2 THEN SET p_name = '星期二';
        WHEN 3 THEN SET p_name = '星期三';
        WHEN 4 THEN SET p_name = '星期四';
        WHEN 5 THEN SET p_name = '星期五';
        WHEN 6 THEN SET p_name = '星期六';
        WHEN 7 THEN SET p_name = '星期日';
        ELSE SET p_name = '无效';
    END CASE;
END //
DELIMITER ;

CALL proc_case_demo(3, @day_name);
SELECT @day_name;

-- -----------------------------------------------------------------------------
-- 5.4.3 WHILE 循环
-- -----------------------------------------------------------------------------
/*
【语法】
WHILE 条件 DO
    语句;
END WHILE;

📌 特点：先判断后执行（可能一次都不执行）
*/

DROP PROCEDURE IF EXISTS proc_while_demo;

DELIMITER //
CREATE PROCEDURE proc_while_demo(
    IN p_n INT,
    OUT p_sum INT
)
BEGIN
    DECLARE i INT DEFAULT 1;
    SET p_sum = 0;
    
    WHILE i <= p_n DO
        SET p_sum = p_sum + i;
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- 计算 1+2+... +100
CALL proc_while_demo(100, @sum);
SELECT @sum AS '1到100的和';

-- -----------------------------------------------------------------------------
-- 5.4.4 LOOP 循环
-- -----------------------------------------------------------------------------
/*
【语法】
[标签: ] LOOP
    语句;
    IF 退出条件 THEN
        LEAVE 标签;      -- 退出循环
    END IF;
END LOOP [标签];

📌 LEAVE：退出循环（类似 break）
📌 ITERATE：跳过本次，进入下一次（类似 continue）
*/

DROP PROCEDURE IF EXISTS proc_loop_demo;

DELIMITER //
CREATE PROCEDURE proc_loop_demo(
    IN p_n INT,
    OUT p_sum INT
)
BEGIN
    DECLARE i INT DEFAULT 0;
    SET p_sum = 0;
    
    sum_loop: LOOP
        SET i = i + 1;
        
        IF i > p_n THEN
            LEAVE sum_loop;           -- 退出循环
        END IF;
        
        SET p_sum = p_sum + i;
    END LOOP sum_loop;
END //
DELIMITER ;

CALL proc_loop_demo(100, @sum);
SELECT @sum;

-- -----------------------------------------------------------------------------
-- 5.4.5 REPEAT 循环
-- -----------------------------------------------------------------------------
/*
【语法】
REPEAT
    语句;
UNTIL 退出条件
END REPEAT;

📌 特点：先执行后判断（至少执行一次）
📌 类似其他语言的 do... while
*/

DROP PROCEDURE IF EXISTS proc_repeat_demo;

DELIMITER //
CREATE PROCEDURE proc_repeat_demo(
    IN p_n INT,
    OUT p_sum INT
)
BEGIN
    DECLARE i INT DEFAULT 0;
    SET p_sum = 0;
    
    REPEAT
        SET i = i + 1;
        SET p_sum = p_sum + i;
    UNTIL i >= p_n                    -- 注意：没有分号！
    END REPEAT;
END //
DELIMITER ;

CALL proc_repeat_demo(100, @sum);
SELECT @sum;

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        三种循环对比                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  循环类型  │  先判断/先执行  │  至少执行次数  │  退出方式                    │
│─────────────────────────────────────────────────────────────────────────────│
│  WHILE     │  先判断后执行   │  0次           │  条件为假时退出              │
│  LOOP      │  无条件执行     │  1次           │  LEAVE 退出                  │
│  REPEAT    │  先执行后判断   │  1次           │  UNTIL 条件为真时退出        │
└─────────────────────────────────────────────────────────────────────────────┘
*/


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第六部分：存储函数（Stored Function）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 6.1 存储函数基础语法
-- =============================================================================

/*
【语法结构】
DELIMITER //
CREATE FUNCTION 函数名(参数名 数据类型)
RETURNS 返回类型                   -- 必须指定
DETERMINISTIC                      -- 相同输入返回相同结果（推荐）
BEGIN
    DECLARE 变量名 数据类型;
    -- 计算逻辑
    RETURN 返回值;                 -- 必须有 RETURN
END //
DELIMITER ;

【调用】SELECT 函数名(参数); 或嵌入其他 SQL 语句
【删除】DROP FUNCTION IF EXISTS 函数名;
*/

-- 📌 DETERMINISTIC 说明：
-- - DETERMINISTIC：相同输入返回相同结果（如数学计算）
-- - NOT DETERMINISTIC：相同输入可能返回不同结果（如涉及时间）
-- - READS SQL DATA：函数只读取数据，不修改
-- - MODIFIES SQL DATA：函数会修改数据


-- =============================================================================
-- 6.2 存储函数示例
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 6.2.1 简单函数：计算两数之和
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS func_add;

DELIMITER //
CREATE FUNCTION func_add(a INT, b INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN a + b;
END //
DELIMITER ;

-- 调用
SELECT func_add(10, 20) AS 结果;

-- -----------------------------------------------------------------------------
-- 6.2.2 业务函数：根据账户名查询余额
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS func_get_money;

DELIMITER //
CREATE FUNCTION func_get_money(p_name VARCHAR(20))
RETURNS DECIMAL(10, 2)
READS SQL DATA                            -- 只读数据
BEGIN
    DECLARE v_money DECIMAL(10, 2);
    
    SELECT money INTO v_money FROM account WHERE name = p_name;
    
    RETURN IFNULL(v_money, 0);            -- 处理 NULL
END //
DELIMITER ;

-- 调用（嵌入 SELECT）
SELECT name, func_get_money(name) AS 余额 FROM account;

-- -----------------------------------------------------------------------------
-- 6.2.3 复杂函数：计算阶乘
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS func_factorial;

DELIMITER //
CREATE FUNCTION func_factorial(n INT)
RETURNS BIGINT
DETERMINISTIC
BEGIN
    DECLARE result BIGINT DEFAULT 1;
    DECLARE i INT DEFAULT 1;
    
    IF n < 0 THEN
        RETURN -1;                        -- 负数返回-1表示错误
    END IF;
    
    WHILE i <= n DO
        SET result = result * i;
        SET i = i + 1;
    END WHILE;
    
    RETURN result;
END //
DELIMITER ;

-- 调用
SELECT func_factorial(5) AS '5的阶乘';    -- 结果：120
SELECT func_factorial(10) AS '10的阶乘';  -- 结果：3628800


-- =============================================================================
-- 6.3 存储过程 vs 存储函数 对比
-- =============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                   存储过程 vs 存储函数 对比                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  特性          │  存储过程 (Procedure)    │  存储函数 (Function)            │
│─────────────────────────────────────────────────────────────────────────────│
│  返回值        │  通过 OUT 参数返回       │  必须用 RETURN 返回一个值       │
│                │  可返回多个              │  只能返回一个                   │
│─────────────────────────────────────────────────────────────────────────────│
│  调用方式      │  CALL 过程名()           │  SELECT 函数名() 或嵌入SQL      │
│─────────────────────────────────────────────────────────────────────────────│
│  参数类型      │  IN / OUT / INOUT        │  只有 IN（输入参数）            │
│─────────────────────────────────────────────────────────────────────────────│
│  在SQL中使用   │  ❌ 不能                 │  ✅ 可以                        │
│─────────────────────────────────────────────────────────────────────────────│
│  典型用途      │  复杂业务逻辑            │  计算并返回单一结果             │
│                │  批量操作、事务处理      │  作为字段值使用                 │
└─────────────────────────────────────────────────────────────────────────────┘

📌 选择建议：
   - 需要返回多个结果 → 存储过程
   - 需要在 SELECT 中使用 → 存储函数
   - 需要事务控制 → 存储过程
   - 简单计算返回单值 → 存储函数
*/


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第七部分：游标（Cursor）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 7.1 游标概述
-- =============================================================================

/*
【什么是游标】
游标是一种数据访问机制，用于逐行处理查询结果集。
普通 SELECT 返回整个结果集，游标允许逐行遍历处理每一条记录。

【使用场景】
- 需要逐行处理数据（如批量更新、复杂计算）
- 需要在遍历过程中做判断和操作

【游标使用五步曲】
1. 声明变量（存储每行数据）
2. 声明游标（绑定查询语句）
3. 声明异常处理器（处理遍历结束）
4. 打开游标
5. 循环读取数据
6. 关闭游标

⚠️ 声明顺序必须是：变量 → 游标 → 异常处理器
*/


-- =============================================================================
-- 7.2 游标基础语法
-- =============================================================================

/*
【语法】

-- 1. 声明游标
DECLARE 游标名 CURSOR FOR SELECT语句;

-- 2. 声明异常处理器（游标结束时触发）
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

-- 3. 打开游标
OPEN 游标名;

-- 4. 读取数据（每次读取一行）
FETCH 游标名 INTO 变量1, 变量2, ... ;

-- 5. 关闭游标
CLOSE 游标名;
*/


-- =============================================================================
-- 7.3 游标示例
-- =============================================================================

-- 准备测试数据
DROP TABLE IF EXISTS student_cursor;
CREATE TABLE student_cursor (
    sno CHAR(9) PRIMARY KEY,
    sname VARCHAR(20),
    sage INT
);

INSERT INTO student_cursor VALUES 
    ('001', '张三', 20),
    ('002', '李四', 21),
    ('003', '王五', 19),
    ('004', '赵六', 22);

-- -----------------------------------------------------------------------------
-- 7.3.1 基础游标示例：遍历并拼接结果
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS proc_cursor_demo;

DELIMITER //
CREATE PROCEDURE proc_cursor_demo()
BEGIN
    -- 1️⃣ 声明变量（必须最先声明）
    DECLARE v_sno CHAR(9);
    DECLARE v_sname VARCHAR(20);
    DECLARE v_sage INT;
    DECLARE done INT DEFAULT 0;              -- 游标结束标记
    DECLARE result VARCHAR(1000) DEFAULT ''; -- 结果字符串
    
    -- 2️⃣ 声明游标
    DECLARE student_cur CURSOR FOR 
        SELECT sno, sname, sage FROM student_cursor;
    
    -- 3️⃣ 声明异常处理器（NOT FOUND 时设置 done = 1）
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- 4️⃣ 打开游标
    OPEN student_cur;
    
    -- 5️⃣ 循环读取数据
    read_loop:  LOOP
        -- 读取一行数据
        FETCH student_cur INTO v_sno, v_sname, v_sage;
        
        -- 判断是否结束
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;
        
        -- 处理数据：拼接到结果字符串
        SET result = CONCAT(result, '学号:', v_sno, ' 姓名:', v_sname, ' 年龄:', v_sage, '; ');
    END LOOP read_loop;
    
    -- 6️⃣ 关闭游标
    CLOSE student_cur;
    
    -- 输出结果
    SELECT result AS 学生信息;
END //
DELIMITER ;

-- 调用
CALL proc_cursor_demo();

-- -----------------------------------------------------------------------------
-- 7.3.2 实用游标示例：批量更新年龄
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS proc_update_age;

DELIMITER //
CREATE PROCEDURE proc_update_age()
BEGIN
    DECLARE v_sno CHAR(9);
    DECLARE v_sage INT;
    DECLARE done INT DEFAULT 0;
    DECLARE update_count INT DEFAULT 0;
    
    DECLARE age_cur CURSOR FOR 
        SELECT sno, sage FROM student_cursor;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN age_cur;
    
    update_loop: LOOP
        FETCH age_cur INTO v_sno, v_sage;
        
        IF done THEN
            LEAVE update_loop;
        END IF;
        
        -- 年龄 +1
        UPDATE student_cursor SET sage = sage + 1 WHERE sno = v_sno;
        SET update_count = update_count + 1;
    END LOOP update_loop;
    
    CLOSE age_cur;
    
    SELECT CONCAT('更新了 ', update_count, ' 条记录') AS 结果;
END //
DELIMITER ;

-- 调用
CALL proc_update_age();
SELECT * FROM student_cursor;


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第八部分：触发器（Trigger）
-- ═══════════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- 8.1 触发器概述
-- =============================================================================

/*
【什么是触发器】
触发器是在表上执行 INSERT、UPDATE、DELETE 操作时自动触发执行的程序。
无需手动调用，由数据库系统自动执行。

【语法】
CREATE TRIGGER 触发器名
{BEFORE | AFTER}                   -- 触发时机
{INSERT | UPDATE | DELETE}         -- 触发事件
ON 表名
FOR EACH ROW                       -- 行级触发器（每行触发一次）
BEGIN
    -- 触发器逻辑
END;

【删除】DROP TRIGGER IF EXISTS 触发器名;
【查看】SHOW TRIGGERS;
*/


-- =============================================================================
-- 8.2 NEW 和 OLD 关键字
-- =============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        NEW 和 OLD 关键字                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│  触发事件    │  NEW                      │  OLD                             │
│─────────────────────────────────────────────────────────────────────────────│
│  INSERT      │  ✅ 新插入的数据          │  ❌ 不可用                       │
│  UPDATE      │  ✅ 更新后的数据          │  ✅ 更新前的数据                 │
│  DELETE      │  ❌ 不可用                │  ✅ 被删除的数据                 │
└─────────────────────────────────────────────────────────────────────────────┘

📌 用法示例：
   INSERT 触发器：NEW.字段名 获取新插入的值
   UPDATE 触发器：OLD.字段名 获取旧值，NEW.字段名 获取新值
   DELETE 触发器：OLD. 字段名 获取被删除的值
*/


-- =============================================================================
-- 8.3 BEFORE vs AFTER
-- =============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                        BEFORE vs AFTER                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  时机      │  特点                        │  使用场景                        │
│─────────────────────────────────────────────────────────────────────────────│
│  BEFORE    │  操作执行前触发              │  数据校验、自动填充              │
│            │  可以修改 NEW 的值           │  修正即将插入/更新的数据         │
│─────────────────────────────────────────────────────────────────────────────│
│  AFTER     │  操作执行后触发              │  日志记录、统计更新              │
│            │  不能修改数据                │  同步更新其他表                  │
└─────────────────────────────────────────────────────────────────────────────┘
*/


-- =============================================================================
-- 8.4 触发器示例
-- =============================================================================

-- 准备测试表
DROP TABLE IF EXISTS employee_log;
DROP TABLE IF EXISTS employee_trigger;

-- 员工表
CREATE TABLE employee_trigger (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    salary DECIMAL(10, 2),
    create_time DATETIME
);

-- 日志表
CREATE TABLE employee_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    operation VARCHAR(20),            -- 操作类型
    emp_id INT,                       -- 员工ID
    old_data VARCHAR(200),            -- 旧数据
    new_data VARCHAR(200),            -- 新数据
    log_time DATETIME                 -- 日志时间
);

-- -----------------------------------------------------------------------------
-- 8.4.1 INSERT 触发器：自动填充创建时间 + 记录日志
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_emp_insert;

DELIMITER //
CREATE TRIGGER tr_emp_insert
BEFORE INSERT ON employee_trigger
FOR EACH ROW
BEGIN
    -- 自动填充创建时间（BEFORE 可以修改 NEW）
    IF NEW.create_time IS NULL THEN
        SET NEW.create_time = NOW();
    END IF;
END //
DELIMITER ;

-- 插入后记录日志的触发器
DROP TRIGGER IF EXISTS tr_emp_insert_log;

DELIMITER //
CREATE TRIGGER tr_emp_insert_log
AFTER INSERT ON employee_trigger
FOR EACH ROW
BEGIN
    INSERT INTO employee_log (operation, emp_id, new_data, log_time)
    VALUES ('INSERT', NEW. id, 
            CONCAT('name=', NEW.name, ', salary=', NEW.salary), 
            NOW());
END //
DELIMITER ;

-- 测试
INSERT INTO employee_trigger (name, salary) VALUES ('张三', 10000);
INSERT INTO employee_trigger (name, salary) VALUES ('李四', 12000);

SELECT * FROM employee_trigger;
SELECT * FROM employee_log;

-- -----------------------------------------------------------------------------
-- 8.4.2 UPDATE 触发器：记录修改日志
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_emp_update_log;

DELIMITER //
CREATE TRIGGER tr_emp_update_log
AFTER UPDATE ON employee_trigger
FOR EACH ROW
BEGIN
    -- 只有数据真正变化时才记录日志
    IF OLD.name != NEW.name OR OLD.salary != NEW.salary THEN
        INSERT INTO employee_log (operation, emp_id, old_data, new_data, log_time)
        VALUES ('UPDATE', NEW.id,
                CONCAT('name=', OLD.name, ', salary=', OLD.salary),
                CONCAT('name=', NEW.name, ', salary=', NEW.salary),
                NOW());
    END IF;
END //
DELIMITER ;

-- 测试
UPDATE employee_trigger SET salary = 15000 WHERE name = '张三';
SELECT * FROM employee_log;

-- -----------------------------------------------------------------------------
-- 8.4.3 DELETE 触发器：记录删除日志
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_emp_delete_log;

DELIMITER //
CREATE TRIGGER tr_emp_delete_log
AFTER DELETE ON employee_trigger
FOR EACH ROW
BEGIN
    INSERT INTO employee_log (operation, emp_id, old_data, log_time)
    VALUES ('DELETE', OLD.id,
            CONCAT('name=', OLD. name, ', salary=', OLD.salary),
            NOW());
END //
DELIMITER ;

-- 测试
DELETE FROM employee_trigger WHERE name = '李四';
SELECT * FROM employee_log;

-- -----------------------------------------------------------------------------
-- 8.4.4 BEFORE UPDATE 触发器：数据校验
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_emp_check_salary;

DELIMITER //
CREATE TRIGGER tr_emp_check_salary
BEFORE UPDATE ON employee_trigger
FOR EACH ROW
BEGIN
    -- 工资不能为负数
    IF NEW.salary < 0 THEN
        SET NEW.salary = 0;
    END IF;
    
    -- 工资涨幅不能超过50%
    IF NEW.salary > OLD.salary * 1.5 THEN
        SET NEW. salary = OLD.salary * 1.5;
    END IF;
END //
DELIMITER ;

-- 测试
UPDATE employee_trigger SET salary = -1000 WHERE name = '张三';
SELECT * FROM employee_trigger;  -- salary 被修正为 0

UPDATE employee_trigger SET salary = 10000 WHERE name = '张三';  -- 先恢复
UPDATE employee_trigger SET salary = 50000 WHERE name = '张三';  -- 涨幅过大
SELECT * FROM employee_trigger;  -- salary 被限制为 15000


-- ═══════════════════════════════════════════════════════════════════════════════
-- 第九部分：综合练习
-- ═══════════════════════════════════════════════════════════════════════════════

-- 准备完整测试数据
DROP TABLE IF EXISTS sc_practice;
DROP TABLE IF EXISTS course_practice;
DROP TABLE IF EXISTS student_practice;

CREATE TABLE student_practice (
    sno CHAR(9) PRIMARY KEY,
    sname VARCHAR(20) NOT NULL,
    sage INT CHECK (sage > 0 AND sage < 100)
);

CREATE TABLE course_practice (
    cno CHAR(4) PRIMARY KEY,
    cname VARCHAR(40) NOT NULL,
    ccredit INT DEFAULT 2
);

CREATE TABLE sc_practice (
    sno CHAR(9),
    cno CHAR(4),
    grade INT CHECK (grade BETWEEN 0 AND 100),
    PRIMARY KEY (sno, cno),
    FOREIGN KEY (sno) REFERENCES student_practice(sno) ON DELETE CASCADE,
    FOREIGN KEY (cno) REFERENCES course_practice(cno) ON DELETE CASCADE
);

INSERT INTO student_practice VALUES 
    ('001', '张三', 20), ('002', '李四', 21), ('003', '王五', 19);
INSERT INTO course_practice VALUES 
    ('C1', '数据库', 4), ('C2', '数学', 3), ('C3', '英语', 2);
INSERT INTO sc_practice VALUES 
    ('001', 'C1', 85), ('001', 'C2', 90), ('002', 'C1', 78), ('003', 'C1', 92);

-- -----------------------------------------------------------------------------
-- 综合练习1：存储过程 - 统计学生成绩
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS proc_student_score;

DELIMITER //
CREATE PROCEDURE proc_student_score(
    IN p_sno CHAR(9),
    OUT p_avg DECIMAL(5, 2),
    OUT p_count INT
)
BEGIN
    SELECT AVG(grade), COUNT(*) 
    INTO p_avg, p_count
    FROM sc_practice 
    WHERE sno = p_sno;
END //
DELIMITER ;