题目0
DELIMITER //

in 代表输入参数  out 代表输出参数 
CREATE PROCEDURE transfer_money(
    IN p_from INT,
    IN p_to INT,
    IN p_amount DECIMAL(10,2),
    OUT p_result VARCHAR(50) -- 返回 'Success' 或 'Fail'
)
BEGIN
    -- [填空1] 定义一个标志变量，用来标记是否有错误发生，默认 0 (无错)
    DECLARE v_error INT DEFAULT 0;

    -- [填空2] 声明异常处理器：如果发生 SQLEXCEPTION，将 v_error 设为 1 这里处理
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_error = 1;
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION 
--     BEGIN
--       ROLLBACK;
--       SET 
    -- [填空3] 开启事务
    start TRANSACTION;

    -- 扣款
    UPDATE accounts SET balance = balance - p_amount WHERE id = p_from;

    -- 加款
    UPDATE accounts SET balance = balance + p_amount WHERE id = p_to;

    -- [填空4] 检查是否有错：如果 v_error = 1，回滚；否则提交
    IF v_error = 1 THEN
        ROLLBACK; -- 回滚
        SET p_result = 'Fail';
    ELSE
       COMMIT; -- 提交
        SET p_result = 'Success';
    END IF;

END//
DELIMITER ;




题目一
会员积分兑换系统（涉及：事务、ROW_COUNT、NOT FOUND）
业务场景： 用户用积分兑换商品。需要检查：

用户是否存在
积分是否足够
商品库存是否足够
任何一步失败都要回滚，并返回具体的失败原因。

表结构：

users ( user_id INT, points INT )
products ( product_id INT, stock INT, point_price INT )
DELIMITER //

DELIMITER //

CREATE PROCEDURE exchange_product(
    IN  p_user_id    INT,
    IN  p_product_id INT,
    OUT p_status     INT,        -- 0成功, -1用户不存在, -2积分不足, -3库存不足, -99系统错误
    OUT p_message    VARCHAR(100)
)
BEGIN
    -- [填空1] 声明3个局部变量：用户积分、商品价格、商品库存
    DECLARE v_user_points   INT DEFAULT 0;
    DECLARE v_product_price _______________; -- 商品所需积分
    DECLARE v_product_stock _______________; -- 商品库存

    -- [填空2] 声明一个标志变量，用来捕获"查不到数据"的情况
    DECLARE v_not_found INT DEFAULT 0;

    -- [填空3] 声明 NOT FOUND 异常处理器（当 SELECT INTO 查不到时触发）
    DECLARE _______________ HANDLER FOR _______________ 
        SET v_not_found = 1;

    -- [填空4] 声明 SQLEXCEPTION 异常处理器（遇到数据库错误立刻退出）
    DECLARE _______________ HANDLER FOR _______________
    BEGIN
        ROLLBACK;
        SET p_status = -99;
        SET p_message = '系统异常，操作已回滚';
    END;

    -- [填空5] 开启事务
    _______________;

    -- 第一步：查询用户积分
    SELECT points INTO v_user_points FROM users WHERE user_id = p_user_id;
    
    -- [填空6] 检查用户是否存在（如果上面 SELECT INTO 没查到，v_not_found 会被设为 1）
    IF v_not_found = 1 THEN
        _______________;  -- 回滚
        SET p_status = -1;
        SET p_message = '用户不存在';
        LEAVE proc_label; -- 退出存储过程
    END IF;

    -- 重置标志（因为 CONTINUE HANDLER 会继续执行）
    SET v_not_found = 0;

    -- 第二步：查询商品价格和库存
    SELECT point_price, stock INTO v_product_price, v_product_stock
    FROM products WHERE product_id = p_product_id;

    -- [填空7] 检查商品是否存在
    IF _______________ THEN
        ROLLBACK;
        SET p_status = -3;
        SET p_message = '商品不存在';
        LEAVE proc_label;
    END IF;

    -- 第三步：检查积分是否充足
    -- [填空8] 逻辑判断：用户积分 < 商品价格
    IF v_user_points < _______________ THEN
        ROLLBACK;
        SET p_status = -2;
        SET p_message = '积分不足';
        LEAVE proc_label;
    END IF;

    -- 第四步：检查库存是否充足
    IF v_product_stock < 1 THEN
        ROLLBACK;
        SET p_status = -3;
        SET p_message = '商品库存不足';
        LEAVE proc_label;
    END IF;

    -- 第五步：扣减积分
    -- [填空9] 更新用户积分（减去商品价格）
    UPDATE users 
    SET points = points - _______________
    WHERE user_id = p_user_id;

    -- 第六步：扣减库存
    UPDATE products 
    SET stock = stock - 1
    WHERE product_id = p_product_id;

    -- [填空10] 提交事务
    _______________;
    SET p_status = 0;
    SET p_message = '兑换成功';

    proc_label:  END; -- 标签：用于 LEAVE 跳出

END//
DELIMITER ;





-- 去掉leave跳出 使用简单的if嵌套语句
DELIMITER //

CREATE PROCEDURE exchange_product(
    IN  p_user_id    INT,
    IN  p_product_id INT,
    OUT p_status     INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    -- 声明变量
    DECLARE v_user_points   INT DEFAULT 0;
    DECLARE v_product_price INT DEFAULT 0;
    DECLARE v_product_stock INT DEFAULT 0;
    DECLARE v_not_found     INT DEFAULT 0;

    -- 异常处理器
    DECLARE CONTINUE HANDLER FOR NOT FOUND 
        SET v_not_found = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = -99;
        SET p_message = '系统异常，操作已回滚';
    END;

    -- 开启事务
    START TRANSACTION;

    -- 1. 查询用户积分
    SELECT points INTO v_user_points FROM users WHERE user_id = p_user_id;
    
    -- 2. 检查用户是否存在（无 LEAVE！用 IF-ELSE 处理）
    IF v_not_found = 1 THEN
        -- 用户不存在：回滚并设置错误
        ROLLBACK;
        SET p_status = -1;
        SET p_message = '用户不存在';
    ELSE
        -- 重置标志，准备查商品
        SET v_not_found = 0;
        
        -- 3. 查询商品价格和库存
        SELECT point_price, stock INTO v_product_price, v_product_stock
        FROM products WHERE product_id = p_product_id;
        
        -- 4. 检查商品是否存在
        IF v_not_found = 1 THEN
            ROLLBACK;
            SET p_status = -3;
            SET p_message = '商品不存在';
        ELSE
            -- 5. 检查积分是否充足
            IF v_user_points < v_product_price THEN
                ROLLBACK;
                SET p_status = -2;
                SET p_message = '积分不足';
            ELSE
                -- 6. 检查库存是否充足
                IF v_product_stock < 1 THEN
                    ROLLBACK;
                    SET p_status = -3;
                    SET p_message = '商品库存不足';
                ELSE
                    -- 7. 执行兑换（所有检查通过）
                    UPDATE users SET points = points - v_product_price WHERE user_id = p_user_id;
                    UPDATE products SET stock = stock - 1 WHERE product_id = p_product_id;
                    COMMIT;
                    SET p_status = 0;
                    SET p_message = '兑换成功';
                END IF;
            END IF;
        END IF;
    END IF;

END//

DELIMITER ;

-- 详细重难点以及注意事项 根据上面那道题
-- 1. 事务控制（ACID原则）
START TRANSACTION; -- 开启事务，确保操作原子性
ROLLBACK;          -- 立即回滚：撤销事务中所有数据库操作（如UPDATE/SELECT INTO）
COMMIT;            -- 提交事务：确认操作生效

-- 2. 异常处理器选择
DECLARE CONTINUE HANDLER FOR NOT FOUND 
    SET v_not_found = 1; -- 业务错误（如用户不存在）用CONTINUE
                         -- ✅ 保证继续执行后续逻辑（如回滚+设置状态）
                         
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;           -- 系统错误（如数据库崩溃）用EXIT
    SET p_status = -99; -- ✅ 立即退出，防止脏数据
END;

-- 3. 变量重置机制
SET v_not_found = 0; -- 关键！每次查询前必须重置
                     -- ❗ 否则上次查询的NOT FOUND会污染当前查询判断

-- 4. 两次独立存在性检查
SELECT ... FROM users WHERE user_id = p_user_id; -- 第一次检查用户存在
IF v_not_found = 1 THEN ROLLBACK; END IF;        -- 用户不存在立即回滚

SET v_not_found = 0; -- 重置标志
SELECT ... FROM products WHERE product_id = p_product_id; -- 第二次检查商品存在
IF v_not_found = 1 THEN ROLLBACK; END IF;                 -- 商品不存在立即回滚

-- 5. 回滚后SET语句仍执行的原理
-- ✅ 事务回滚只撤销数据库操作（如UPDATE/INSERT），不影响存储过程内部逻辑
-- 例如：ROLLBACK后，SET p_status = -1 仍会执行（用于反馈错误）

-- 6. 状态码设计（考试加分项）
-- p_status: 0=成功, -1=用户不存在, -2=积分不足, -3=库存不足, -99=系统错误




题目二
业务场景： HR 提交薪资调整申请，系统自动审批：

涨幅 ≤ 10%：自动通过
10% < 涨幅 ≤ 30%：需要部门经理审批
涨幅 > 30%：需要 CEO 审批
同时记录审批日志到 approval_logs 表。如果员工不存在或新薪资违反约束（如低于最低工资），要回滚。

表结构：

employees ( emp_id INT, salary DECIMAL, dept_id INT )
approval_logs ( log_id INT AUTO_INCREMENT, emp_id INT, old_salary DECIMAL, new_salary DECIMAL, status VARCHAR, created_at TIMESTAMP )

DELIMITER //

CREATE PROCEDURE submit_salary_adjustment(
    IN  p_emp_id     INT,
    IN  p_new_salary DECIMAL(10,2),
    OUT p_approval_status VARCHAR(50)
)
BEGIN
    DECLARE v_old_salary DECIMAL(10,2);
    DECLARE v_raise_percent DECIMAL(5,2);
    DECLARE v_final_status VARCHAR(50);

    -- [填空1] 声明变量捕获"违反约束"错误（SQLSTATE '23000' 表示完整性约束违反）
    DECLARE v_constraint_error INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '_______________' 
        SET v_constraint_error = 1;

    -- [填空2] 声明 EXIT 类型的 SQLEXCEPTION 处理器
    DECLARE _______________ HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_approval_status = '系统错误';
    END;

    START TRANSACTION;

    -- 查询员工当前薪资
    SELECT salary INTO v_old_salary FROM employees WHERE emp_id = p_emp_id;

    -- [填空3] 计算涨幅百分比：(新薪资 - 旧薪资) / 旧薪资 * 100
    SET v_raise_percent = (_______________ - v_old_salary) / v_old_salary * 100;

    -- [填空4] 使用 CASE 判断审批流程
    SET v_final_status = CASE
        WHEN v_raise_percent <= 10 THEN '_______________'  -- 自动通过
        WHEN v_raise_percent <= 30 THEN '等待经理审批'
        ELSE '_______________'  -- 等待CEO审批
    END;

    -- [填空5] 如果自动通过，更新薪资；否则不更新
    IF v_final_status = '自动通过' THEN
        UPDATE employees 
        SET salary = _______________
        WHERE emp_id = p_emp_id;
    END IF;

    -- [填空6] 检查是否违反约束（如最低工资约束）
    IF v_constraint_error = 1 THEN
        _______________;
        SET p_approval_status = '薪资违反约束条件';
        LEAVE proc_end;
    END IF;

    -- [填空7] 插入审批日志（记录旧薪资、新薪资、状态）
    INSERT INTO approval_logs (emp_id, old_salary, new_salary, status, created_at)
    VALUES (p_emp_id, v_old_salary, _______________, v_final_status, NOW());

    COMMIT;
    SET p_approval_status = v_final_status;

    proc_end: END;

END//
DELIMITER ;



替换成更基础的ifelse语句
DELIMITER //

CREATE PROCEDURE submit_salary_adjustment(
    IN  p_emp_id     INT,
    IN  p_new_salary DECIMAL(10,2),
    OUT p_approval_status VARCHAR(50)
)
BEGIN
    -- ========================================================================
    -- 第一部分：变量声明区（必须在BEGIN后最前面，这是MySQL语法强制要求）
    -- ========================================================================
    
    -- 业务核心变量：用于存储查询结果和计算中间值
    DECLARE v_old_salary DECIMAL(10,2);      -- 存储员工当前薪资（从数据库查询得到）
    DECLARE v_raise_percent DECIMAL(5,2);    -- 存储计算出的涨幅百分比（业务规则判断依据）
    DECLARE v_final_status VARCHAR(50);      -- 存储最终审批状态（返回给调用方的核心信息）
    
    -- 【原填空1位置】错误标志变量：用于在异常处理器和主逻辑之间传递信号
    DECLARE v_constraint_error INT DEFAULT 0; 
    -- 解释：当UPDATE违反数据库约束（如CHECK约束：salary >= 3000）时，
    --      异常处理器会将此变量设为1，主逻辑通过检查此变量来判断是否发生错误
    
    -- 【原填空1位置】精确异常处理器：捕获完整性约束违反错误
    -- SQLSTATE '23000' 是SQL标准错误码，专门表示约束违反（主键重复/外键冲突/CHECK失败）
    DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' 
        SET v_constraint_error = 1;
    -- 关键点1：使用CONTINUE而非EXIT，因为需要继续执行后续的IF判断和日志记录
    -- 关键点2：为什么不直接ROLLBACK？因为需要在主逻辑中统一处理错误（插入错误日志）
    
    -- 【原填空2位置】系统级异常处理器：捕获所有严重的SQL错误
    -- SQLEXCEPTION包含：语法错误、类型不匹配、表不存在等所有严重错误
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- 立即回滚事务（撤销所有已执行的UPDATE/INSERT）
        SET p_approval_status = '系统错误';  -- 设置OUT参数，告知调用方失败原因
    END;
    -- 关键点1：必须用EXIT，因为系统错误无法恢复，不应继续执行
    -- 关键点2：EXIT HANDLER执行后会立即退出存储过程，后续代码不再执行

    -- ========================================================================
    -- 第二部分：事务开启（从这里开始的所有DML操作都在事务保护下）
    -- ========================================================================
    START TRANSACTION;
    -- 作用：确保后续所有操作（UPDATE/INSERT）要么全部成功，要么全部失败
    -- 业务意义：防止出现"薪资更新了但日志没记录"的数据不一致情况

    -- ========================================================================
    -- 第三部分：业务逻辑执行（核心流程）
    -- ========================================================================
    
    -- 【原填空3位置】步骤1：查询员工当前薪资
    SELECT salary INTO v_old_salary 
    FROM employees 
    WHERE emp_id = p_emp_id;
    -- 注意点1：SELECT ...  INTO 是存储过程特有语法，将查询结果赋值给变量
    -- 注意点2：如果查不到员工（emp_id不存在），会触发NOT FOUND异常
    --         （本题未处理此情况，实际项目中应添加对应的HANDLER）

    -- 【原填空4位置】步骤2：计算薪资涨幅百分比
    SET v_raise_percent = (p_new_salary - v_old_salary) / v_old_salary * 100;
    -- 公式解释：
    --   假设 旧薪资=10000，新薪资=11500
    --   计算：(11500 - 10000) / 10000 * 100 = 15%
    -- 业务意义：涨幅是审批流程的核心判断依据

    -- 【原填空5位置】步骤3：根据涨幅决定审批流程
    SET v_final_status = CASE
        WHEN v_raise_percent <= 10 THEN '自动通过'      -- 涨幅小，系统直接批准
        WHEN v_raise_percent <= 30 THEN '等待经理审批'  -- 涨幅中等，需要经理审批
        ELSE '等待CEO审批'                              -- 涨幅过大，需要最高层审批
    END;
    -- CASE表达式说明：
    --   这是SQL标准的多路分支语法（类似编程语言的switch-case）
    --   从上到下依次判断条件，匹配到第一个为真的条件就返回对应值
    --   注意：CASE后面没有冒号，结尾是END（不是END CASE）

    -- 【原填空6位置】步骤4：执行薪资更新（有条件执行）
    IF v_final_status = '自动通过' THEN
        UPDATE employees 
        SET salary = p_new_salary
        WHERE emp_id = p_emp_id;
        -- 业务逻辑：只有自动通过的情况才立即更新薪资
        -- 其他情况（等待审批）不更新，只记录日志
    END IF;

    -- ========================================================================
    -- 第四部分：错误检查与事务决策（决定是提交还是回滚）
    -- ========================================================================
    
    -- 【原填空7位置】检查是否触发了约束错误
    IF v_constraint_error = 1 THEN
        -- 错误分支：发生了约束违反（如新薪资低于公司最低标准3000元）
        ROLLBACK;  -- 回滚事务，撤销之前的UPDATE操作
        SET p_approval_status = '薪资违反约束条件';  -- 设置错误信息
        -- 注意：这里不使用LEAVE退出，而是通过IF-ELSE结构控制流程
        --      原因：避免标签管理复杂度，符合基础语法规范
    ELSE
        -- 【原填空8位置】正常分支：插入审批日志
        INSERT INTO approval_logs (emp_id, old_salary, new_salary, status, created_at)
        VALUES (p_emp_id, v_old_salary, p_new_salary, v_final_status, NOW());
        -- 业务意义：无论是否自动通过，都要记录这次操作（审计需求）
        
        COMMIT;  -- 提交事务，使所有操作永久生效
        SET p_approval_status = v_final_status;  -- 返回审批状态
    END IF;

    -- ========================================================================
    -- 第五部分：存储过程结束（事务已经提交或回滚，无需额外操作）
    -- ========================================================================

END//
DELIMITER ;




题目三
业务场景： 批量处理逾期未还的图书：遍历所有逾期记录，计算罚款并更新到用户账户，同时标记图书为"逾期"状态。

表结构：

borrows ( borrow_id INT, user_id INT, book_id INT, due_date DATE, status VARCHAR )
users ( user_id INT, balance DECIMAL )
books ( book_id INT, status VARCHAR )

DELIMITER //

CREATE PROCEDURE process_overdue_books(
    OUT p_processed_count INT  -- 返回处理了多少条记录
)
BEGIN
    -- [填空1] 声明游标需要的变量（用来存储游标读出的每一行数据）
    DECLARE v_borrow_id INT;
    DECLARE v_user_id   INT;
    DECLARE v_book_id   _______________; 
    DECLARE v_days_overdue INT;

    -- [填空2] 声明标志变量：游标是否读到末尾
    DECLARE v_done INT DEFAULT 0;

    -- [填空3] 声明游标（查询所有逾期且未处理的借阅记录）
    DECLARE cur_overdue _______________ FOR
        SELECT borrow_id, user_id, book_id, DATEDIFF(NOW(), due_date) AS days_overdue
        FROM borrows
        WHERE due_date < NOW() AND status = 'borrowed';

    -- [填空4] 声明 NOT FOUND 处理器（游标读完时触发）
    DECLARE CONTINUE HANDLER FOR _______________
        SET v_done = 1;

    -- 声明异常处理器
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_processed_count = -1; -- 用负数表示失败
    END;

    SET p_processed_count = 0;
    START TRANSACTION;

    -- [填空5] 打开游标
    _______________ cur_overdue;

    -- [填空6] 开始循环读取游标
    read_loop: _______________
        -- [填空7] 从游标中取一行数据到变量
        _______________ cur_overdue INTO v_borrow_id, v_user_id, v_book_id, v_days_overdue;

        -- [填空8] 如果读完了，退出循环
        IF v_done = 1 THEN
            _______________;  -- 退出循环
        END IF;

        -- 计算罚款：每天 0.5 元
        UPDATE users 
        SET balance = balance - (v_days_overdue * 0.5)
        WHERE user_id = v_user_id;

        -- 标记图书为逾期状态
        UPDATE books SET status = 'overdue' WHERE book_id = v_book_id;

        -- 标记借阅记录为已处理
        UPDATE borrows SET status = 'overdue_processed' WHERE borrow_id = v_borrow_id;

        -- 计数器加1
        SET p_processed_count = p_processed_count + 1;

    -- [填空9] 结束循环
    END LOOP;

    -- [填空10] 关闭游标
    _______________ cur_overdue;

    COMMIT;

END//
DELIMITER ;



DELIMITER //

CREATE PROCEDURE process_overdue_books(
    OUT p_processed_count INT  -- 返回值：成功处理的逾期记录数量
)
BEGIN
    -- ========================================================================
    -- 第一部分：变量声明区（游标相关变量必须在这里声明）
    -- ========================================================================
    
    -- 【原填空1位置】游标读取数据的接收变量
    -- 这些变量用于存储游标每次FETCH出来的一行数据
    DECLARE v_borrow_id INT;            -- 借阅记录ID（用于更新具体记录）
    DECLARE v_user_id   INT;            -- 用户ID（用于扣除罚款）
    DECLARE v_book_id   INT;            -- 图书ID（用于标记图书状态）【原填空位置】
    DECLARE v_days_overdue INT;         -- 逾期天数（用于计算罚款金额）
    
    -- 【原填空2位置】游标结束标志变量（核心控制变量）
    DECLARE v_done INT DEFAULT 0;
    -- 作用：当游标读到最后一行后，NOT FOUND异常处理器会将它设为1
    -- 主循环通过检查这个变量来判断是否应该退出循环

    -- ========================================================================
    -- 第二部分：游标声明（定义要遍历的数据集）
    -- ========================================================================
    
    -- 【原填空3位置】声明游标（关键字是CURSOR）
    DECLARE cur_overdue CURSOR FOR  -- 游标名称：cur_overdue【原填空：CURSOR关键字】
        SELECT borrow_id, user_id, book_id, 
               DATEDIFF(NOW(), due_date) AS days_overdue
        FROM borrows
        WHERE due_date < NOW() AND status = 'borrowed';
    -- 游标工作原理解释：
    --   1. 游标是一个"数据集合的指针"，类似于C语言的文件指针
    --   2. 这个SELECT查询不会立即执行，只是定义了"要遍历什么数据"
    --   3. 只有OPEN游标后，查询才会执行，并将结果集缓存起来
    -- 业务逻辑：查找所有已逾期且尚未处理的借阅记录
    --   条件1：due_date < NOW() 表示已过期
    --   条件2：status = 'borrowed' 表示尚未处理（排除已处理的记录）

    -- ========================================================================
    -- 第三部分：异常处理器声明（必须在游标声明之后）
    -- ========================================================================
    
    -- 【原填空4位置】声明NOT FOUND异常处理器
    DECLARE CONTINUE HANDLER FOR NOT FOUND  -- 【原填空：NOT FOUND关键字】
        SET v_done = 1;
    -- 触发时机：当FETCH语句尝试读取下一行，但游标已经到达末尾时
    -- 处理动作：将v_done设为1，告诉主循环"数据已经读完了"
    -- 为什么用CONTINUE？
    --   因为需要继续执行循环内的IF v_done = 1判断和LEAVE语句
    --   如果用EXIT，会直接退出存储过程，导致游标无法关闭，事务无法提交
    
    -- 系统级异常处理器（处理数据库错误）
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- 撤销所有已处理的记录（确保数据一致性）
        SET p_processed_count = -1;  -- 用负数表示处理失败
    END;
    -- 业务意义：如果中途发生错误（如网络断开、表被锁定），
    --          确保已扣除的罚款能够回滚，不会出现"扣了钱但状态没更新"

    -- ========================================================================
    -- 第四部分：初始化与事务开启
    -- ========================================================================
    
    SET p_processed_count = 0;  -- 计数器初始化（记录成功处理的记录数）
    START TRANSACTION;          -- 开启事务（保证批量操作的原子性）

    -- ========================================================================
    -- 第五部分：游标操作（核心循环逻辑）
    -- ========================================================================
    
    -- 【原填空5位置】打开游标（关键字OPEN）
    OPEN cur_overdue;  -- 【原填空：OPEN关键字】
    -- 执行时机：这一步会真正执行游标定义中的SELECT语句
    -- 执行结果：查询结果集被加载到内存，游标指针指向第一行之前
    
    -- 【原填空6位置】开始循环（关键字LOOP）
    read_loop: LOOP  -- 【原填空：LOOP关键字】循环标签名：read_loop
        -- 循环标签作用：配合LEAVE语句使用，指定要退出的是哪个循环
        --              （当有嵌套循环时，标签非常重要）
        
        -- 【原填空7位置】从游标中读取一行数据（关键字FETCH）
        FETCH cur_overdue INTO v_borrow_id, v_user_id, v_book_id, v_days_overdue;
        -- 【原填空：FETCH关键字】
        -- FETCH工作原理：
        --   1. 将游标当前指向的那一行数据，按列顺序赋值给变量
        --   2. 变量顺序必须与SELECT子句的列顺序一一对应
        --   3. 读取完成后，游标自动向下移动一行
        --   4. 如果已经是最后一行，再FETCH会触发NOT FOUND异常
        
        -- 【原填空8位置】检查游标是否已读完（退出循环的条件）
        IF v_done = 1 THEN
            LEAVE read_loop;  -- 【原填空：LEAVE语句】退出read_loop循环
        END IF;
        -- 逻辑解释：
        --   当FETCH读到最后一行后，NOT FOUND处理器会将v_done设为1
        --   下一次循环时，这个IF判断会生效，执行LEAVE退出循环

        -- --------------------------------------------------------------------
        -- 业务逻辑处理：对当前读取的记录进行操作
        -- --------------------------------------------------------------------
        
        -- 操作1：扣除用户罚款（罚款规则：每天0.5元）
        UPDATE users 
        SET balance = balance - (v_days_overdue * 0.5)
        WHERE user_id = v_user_id;
        -- 注意：这里使用的是变量v_user_id（从游标读出来的值）
        
        -- 操作2：标记图书为逾期状态
        UPDATE books 
        SET status = 'overdue' 
        WHERE book_id = v_book_id;
        -- 业务意义：防止其他用户借阅这本逾期未还的图书
        
        -- 操作3：标记借阅记录为已处理
        UPDATE borrows 
        SET status = 'overdue_processed' 
        WHERE borrow_id = v_borrow_id;
        -- 业务意义：防止下次运行存储过程时重复处理同一条记录
        
        -- 操作4：计数器加1
        SET p_processed_count = p_processed_count + 1;
        -- 业务意义：告知调用方本次处理了多少条记录（审计需求）

    -- 【原填空9位置】结束循环（关键字END LOOP）
    END LOOP;  -- 【原填空：END LOOP关键字】（注意有分号）

    -- ========================================================================
    -- 第六部分：游标关闭与事务提交
    -- ========================================================================
    
    -- 【原填空10位置】关闭游标（关键字CLOSE）
    CLOSE cur_overdue;  -- 【原填空：CLOSE关键字】
    -- 为什么必须关闭？
    --   1. 释放游标占用的内存（结果集可能很大）
    --   2. 释放数据库锁（游标可能持有表的共享锁）
    --   3. 虽然存储过程结束时会自动关闭，但显式关闭是规范写法
    
    COMMIT;  -- 提交事务，使所有UPDATE操作永久生效

END//
DELIMITER ;


游标的生命周期 五步走
-- 步骤1：声明接收变量（在游标声明之前）
DECLARE v_id INT;
DECLARE v_name VARCHAR(50);

-- 步骤2：声明游标（定义要遍历什么数据）
DECLARE cur_name CURSOR FOR SELECT id, name FROM table_name;

-- 步骤3：声明NOT FOUND处理器（在游标声明之后）
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

-- 步骤4：打开游标（真正执行查询）
OPEN cur_name;

-- 步骤5：循环读取
LOOP
    FETCH cur_name INTO v_id, v_name;  -- 读取一行
    IF v_done = 1 THEN LEAVE loop_label; END IF;  -- 检查是否读完
    -- 处理数据
END LOOP;

-- 步骤6：关闭游标（释放资源）
CLOSE cur_name;



声名顺序关于： 普通变量 游标 异常处理器 可执行语句
BEGIN
    -- 顺序1：普通变量
    DECLARE v_var1 INT;
    
    -- 顺序2：游标
    DECLARE cur_name CURSOR FOR ... ;
    
    -- 顺序3：异常处理器
    DECLARE CONTINUE HANDLER FOR NOT FOUND ...;
    
    -- 顺序4：可执行语句
    OPEN cur_name;
END

