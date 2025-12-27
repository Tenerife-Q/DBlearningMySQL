题目0
delimiter //

in 代表输入参数  out 代表输出参数 
create procedure transfer_money(
    in p_from int,
    in p_to int,
    in p_amount decimal(10,2),
    out p_result varchar(50) -- 返回 'success' 或 'fail'
)
begin
    -- [填空1] 定义一个标志变量，用来标记是否有错误发生，默认 0 (无错)
    declare v_error int default 0;

    -- [填空2] 声明异常处理器：如果发生 sqlexception，将 v_error 设为 1 这里处理
    declare continue handler for sqlexception set v_error = 1;
--     declare exit handler for sqlexception 
--     begin
--       rollback;
--       set 
    -- [填空3] 开启事务
    start transaction;

    -- 扣款
    update accounts set balance = balance - p_amount where id = p_from;

    -- 加款
    update accounts set balance = balance + p_amount where id = p_to;

    -- [填空4] 检查是否有错：如果 v_error = 1，回滚；否则提交
    if v_error = 1 then
        rollback; -- 回滚
        set p_result = 'fail';
    else
       commit; -- 提交
        set p_result = 'success';
    end if;

end//
delimiter ;




题目一
会员积分兑换系统（涉及：事务、row_count、not found）
业务场景： 用户用积分兑换商品。需要检查：

用户是否存在
积分是否足够
商品库存是否足够
任何一步失败都要回滚，并返回具体的失败原因。

表结构：

users ( user_id int, points int )
products ( product_id int, stock int, point_price int )
delimiter //

delimiter //

create procedure exchange_product(
    in  p_user_id    int,
    in  p_product_id int,
    out p_status     int,        -- 0成功, -1用户不存在, -2积分不足, -3库存不足, -99系统错误
    out p_message    varchar(100)
)
begin
    -- [填空1] 声明3个局部变量：用户积分、商品价格、商品库存
    declare v_user_points   int default 0;
    declare v_product_price _______________; -- 商品所需积分
    declare v_product_stock _______________; -- 商品库存

    -- [填空2] 声明一个标志变量，用来捕获"查不到数据"的情况
    declare v_not_found int default 0;

    -- [填空3] 声明 not found 异常处理器（当 select into 查不到时触发）
    declare _______________ handler for _______________ 
        set v_not_found = 1;

    -- [填空4] 声明 sqlexception 异常处理器（遇到数据库错误立刻退出）
    declare _______________ handler for _______________
    begin
        rollback;
        set p_status = -99;
        set p_message = '系统异常，操作已回滚';
    end;

    -- [填空5] 开启事务
    _______________;

    -- 第一步：查询用户积分
    select points into v_user_points from users where user_id = p_user_id;
    
    -- [填空6] 检查用户是否存在（如果上面 select into 没查到，v_not_found 会被设为 1）
    if v_not_found = 1 then
        _______________;  -- 回滚
        set p_status = -1;
        set p_message = '用户不存在';
        leave proc_label; -- 退出存储过程
    end if;

    -- 重置标志（因为 continue handler 会继续执行）
    set v_not_found = 0;

    -- 第二步：查询商品价格和库存
    select point_price, stock into v_product_price, v_product_stock
    from products where product_id = p_product_id;

    -- [填空7] 检查商品是否存在
    if _______________ then
        rollback;
        set p_status = -3;
        set p_message = '商品不存在';
        leave proc_label;
    end if;

    -- 第三步：检查积分是否充足
    -- [填空8] 逻辑判断：用户积分 < 商品价格
    if v_user_points < _______________ then
        rollback;
        set p_status = -2;
        set p_message = '积分不足';
        leave proc_label;
    end if;

    -- 第四步：检查库存是否充足
    if v_product_stock < 1 then
        rollback;
        set p_status = -3;
        set p_message = '商品库存不足';
        leave proc_label;
    end if;

    -- 第五步：扣减积分
    -- [填空9] 更新用户积分（减去商品价格）
    update users 
    set points = points - _______________
    where user_id = p_user_id;

    -- 第六步：扣减库存
    update products 
    set stock = stock - 1
    where product_id = p_product_id;

    -- [填空10] 提交事务
    _______________;
    set p_status = 0;
    set p_message = '兑换成功';

    proc_label:  end; -- 标签：用于 leave 跳出

end//
delimiter ;





-- 去掉leave跳出 使用简单的if嵌套语句
delimiter //

create procedure exchange_product(
    in  p_user_id    int,
    in  p_product_id int,
    out p_status     int,
    out p_message    varchar(100)
)
begin
    -- 声明变量
    declare v_user_points   int default 0;
    declare v_product_price int default 0;
    declare v_product_stock int default 0;
    declare v_not_found     int default 0;

    -- 异常处理器
    declare continue handler for not found 
        set v_not_found = 1;

    declare exit handler for sqlexception
    begin
        rollback;
        set p_status = -99;
        set p_message = '系统异常，操作已回滚';
    end;

    -- 开启事务
    start transaction;

    -- 1. 查询用户积分
    select points into v_user_points from users where user_id = p_user_id;
    
    -- 2. 检查用户是否存在（无 leave！用 if-else 处理）
    if v_not_found = 1 then
        -- 用户不存在：回滚并设置错误
        rollback;
        set p_status = -1;
        set p_message = '用户不存在';
    else
        -- 重置标志，准备查商品
        set v_not_found = 0;
        
        -- 3. 查询商品价格和库存
        select point_price, stock into v_product_price, v_product_stock
        from products where product_id = p_product_id;
        
        -- 4. 检查商品是否存在
        if v_not_found = 1 then
            rollback;
            set p_status = -3;
            set p_message = '商品不存在';
        else
            -- 5. 检查积分是否充足
            if v_user_points < v_product_price then
                rollback;
                set p_status = -2;
                set p_message = '积分不足';
            else
                -- 6. 检查库存是否充足
                if v_product_stock < 1 then
                    rollback;
                    set p_status = -3;
                    set p_message = '商品库存不足';
                else
                    -- 7. 执行兑换（所有检查通过）
                    update users set points = points - v_product_price where user_id = p_user_id;
                    update products set stock = stock - 1 where product_id = p_product_id;
                    commit;
                    set p_status = 0;
                    set p_message = '兑换成功';
                end if;
            end if;
        end if;
    end if;

end//

delimiter ;

-- 详细重难点以及注意事项 根据上面那道题
-- 1. 事务控制（acid原则）
start transaction; -- 开启事务，确保操作原子性
rollback;          -- 立即回滚：撤销事务中所有数据库操作（如update/select into）
commit;            -- 提交事务：确认操作生效

-- 2. 异常处理器选择
declare continue handler for not found 
    set v_not_found = 1; -- 业务错误（如用户不存在）用continue
                         -- ✅ 保证继续执行后续逻辑（如回滚+设置状态）
                         
declare exit handler for sqlexception
begin
    rollback;           -- 系统错误（如数据库崩溃）用exit
    set p_status = -99; -- ✅ 立即退出，防止脏数据
end;

-- 3. 变量重置机制
set v_not_found = 0; -- 关键！每次查询前必须重置
                     -- ❗ 否则上次查询的not found会污染当前查询判断

-- 4. 两次独立存在性检查
select ... from users where user_id = p_user_id; -- 第一次检查用户存在
if v_not_found = 1 then rollback; end if;        -- 用户不存在立即回滚

set v_not_found = 0; -- 重置标志
select ... from products where product_id = p_product_id; -- 第二次检查商品存在
if v_not_found = 1 then rollback; end if;                 -- 商品不存在立即回滚

-- 5. 回滚后set语句仍执行的原理
-- ✅ 事务回滚只撤销数据库操作（如update/insert），不影响存储过程内部逻辑
-- 例如：rollback后，set p_status = -1 仍会执行（用于反馈错误）

-- 6. 状态码设计（考试加分项）
-- p_status: 0=成功, -1=用户不存在, -2=积分不足, -3=库存不足, -99=系统错误




题目二
业务场景： hr 提交薪资调整申请，系统自动审批：

涨幅 ≤ 10%：自动通过
10% < 涨幅 ≤ 30%：需要部门经理审批
涨幅 > 30%：需要 ceo 审批
同时记录审批日志到 approval_logs 表。如果员工不存在或新薪资违反约束（如低于最低工资），要回滚。

表结构：

employees ( emp_id int, salary decimal, dept_id int )
approval_logs ( log_id int auto_increment, emp_id int, old_salary decimal, new_salary decimal, status varchar, created_at timestamp )

delimiter //

create procedure submit_salary_adjustment(
    in  p_emp_id     int,
    in  p_new_salary decimal(10,2),
    out p_approval_status varchar(50)
)
begin
    declare v_old_salary decimal(10,2);
    declare v_raise_percent decimal(5,2);
    declare v_final_status varchar(50);

    -- [填空1] 声明变量捕获"违反约束"错误（sqlstate '23000' 表示完整性约束违反）
    declare v_constraint_error int default 0;
    declare continue handler for sqlstate '_______________' 
        set v_constraint_error = 1;

    -- [填空2] 声明 exit 类型的 sqlexception 处理器
    declare _______________ handler for sqlexception
    begin
        rollback;
        set p_approval_status = '系统错误';
    end;

    start transaction;

    -- 查询员工当前薪资
    select salary into v_old_salary from employees where emp_id = p_emp_id;

    -- [填空3] 计算涨幅百分比：(新薪资 - 旧薪资) / 旧薪资 * 100
    set v_raise_percent = (_______________ - v_old_salary) / v_old_salary * 100;

    -- [填空4] 使用 case 判断审批流程
    set v_final_status = case
        when v_raise_percent <= 10 then '_______________'  -- 自动通过
        when v_raise_percent <= 30 then '等待经理审批'
        else '_______________'  -- 等待ceo审批
    end;

    -- [填空5] 如果自动通过，更新薪资；否则不更新
    if v_final_status = '自动通过' then
        update employees 
        set salary = _______________
        where emp_id = p_emp_id;
    end if;

    -- [填空6] 检查是否违反约束（如最低工资约束）
    if v_constraint_error = 1 then
        _______________;
        set p_approval_status = '薪资违反约束条件';
        leave proc_end;
    end if;

    -- [填空7] 插入审批日志（记录旧薪资、新薪资、状态）
    insert into approval_logs (emp_id, old_salary, new_salary, status, created_at)
    values (p_emp_id, v_old_salary, _______________, v_final_status, now());

    commit;
    set p_approval_status = v_final_status;

    proc_end: end;

end//
delimiter ;



替换成更基础的ifelse语句
delimiter //

create procedure submit_salary_adjustment(
    in  p_emp_id     int,
    in  p_new_salary decimal(10,2),
    out p_approval_status varchar(50)
)
begin
    -- ========================================================================
    -- 第一部分：变量声明区（必须在begin后最前面，这是mysql语法强制要求）
    -- ========================================================================
    
    -- 业务核心变量：用于存储查询结果和计算中间值
    declare v_old_salary decimal(10,2);      -- 存储员工当前薪资（从数据库查询得到）
    declare v_raise_percent decimal(5,2);    -- 存储计算出的涨幅百分比（业务规则判断依据）
    declare v_final_status varchar(50);      -- 存储最终审批状态（返回给调用方的核心信息）
    
    -- 【原填空1位置】错误标志变量：用于在异常处理器和主逻辑之间传递信号
    declare v_constraint_error int default 0; 
    -- 解释：当update违反数据库约束（如check约束：salary >= 3000）时，
    --      异常处理器会将此变量设为1，主逻辑通过检查此变量来判断是否发生错误
    
    -- 【原填空1位置】精确异常处理器：捕获完整性约束违反错误
    -- sqlstate '23000' 是sql标准错误码，专门表示约束违反（主键重复/外键冲突/check失败）
    declare continue handler for sqlstate '23000' 
        set v_constraint_error = 1;
    -- 关键点1：使用continue而非exit，因为需要继续执行后续的if判断和日志记录
    -- 关键点2：为什么不直接rollback？因为需要在主逻辑中统一处理错误（插入错误日志）
    
    -- 【原填空2位置】系统级异常处理器：捕获所有严重的sql错误
    -- sqlexception包含：语法错误、类型不匹配、表不存在等所有严重错误
    declare exit handler for sqlexception
    begin
        rollback;  -- 立即回滚事务（撤销所有已执行的update/insert）
        set p_approval_status = '系统错误';  -- 设置out参数，告知调用方失败原因
    end;
    -- 关键点1：必须用exit，因为系统错误无法恢复，不应继续执行
    -- 关键点2：exit handler执行后会立即退出存储过程，后续代码不再执行

    -- ========================================================================
    -- 第二部分：事务开启（从这里开始的所有dml操作都在事务保护下）
    -- ========================================================================
    start transaction;
    -- 作用：确保后续所有操作（update/insert）要么全部成功，要么全部失败
    -- 业务意义：防止出现"薪资更新了但日志没记录"的数据不一致情况

    -- ========================================================================
    -- 第三部分：业务逻辑执行（核心流程）
    -- ========================================================================
    
    -- 【原填空3位置】步骤1：查询员工当前薪资
    select salary into v_old_salary 
    from employees 
    where emp_id = p_emp_id;
    -- 注意点1：select ...  into 是存储过程特有语法，将查询结果赋值给变量
    -- 注意点2：如果查不到员工（emp_id不存在），会触发not found异常
    --         （本题未处理此情况，实际项目中应添加对应的handler）

    -- 【原填空4位置】步骤2：计算薪资涨幅百分比
    set v_raise_percent = (p_new_salary - v_old_salary) / v_old_salary * 100;
    -- 公式解释：
    --   假设 旧薪资=10000，新薪资=11500
    --   计算：(11500 - 10000) / 10000 * 100 = 15%
    -- 业务意义：涨幅是审批流程的核心判断依据

    -- 【原填空5位置】步骤3：根据涨幅决定审批流程
    set v_final_status = case
        when v_raise_percent <= 10 then '自动通过'      -- 涨幅小，系统直接批准
        when v_raise_percent <= 30 then '等待经理审批'  -- 涨幅中等，需要经理审批
        else '等待ceo审批'                              -- 涨幅过大，需要最高层审批
    end;
    -- case表达式说明：
    --   这是sql标准的多路分支语法（类似编程语言的switch-case）
    --   从上到下依次判断条件，匹配到第一个为真的条件就返回对应值
    --   注意：case后面没有冒号，结尾是end（不是end case）

    -- 【原填空6位置】步骤4：执行薪资更新（有条件执行）
    if v_final_status = '自动通过' then
        update employees 
        set salary = p_new_salary
        where emp_id = p_emp_id;
        -- 业务逻辑：只有自动通过的情况才立即更新薪资
        -- 其他情况（等待审批）不更新，只记录日志
    end if;

    -- ========================================================================
    -- 第四部分：错误检查与事务决策（决定是提交还是回滚）
    -- ========================================================================
    
    -- 【原填空7位置】检查是否触发了约束错误
    if v_constraint_error = 1 then
        -- 错误分支：发生了约束违反（如新薪资低于公司最低标准3000元）
        rollback;  -- 回滚事务，撤销之前的update操作
        set p_approval_status = '薪资违反约束条件';  -- 设置错误信息
        -- 注意：这里不使用leave退出，而是通过if-else结构控制流程
        --      原因：避免标签管理复杂度，符合基础语法规范
    else
        -- 【原填空8位置】正常分支：插入审批日志
        insert into approval_logs (emp_id, old_salary, new_salary, status, created_at)
        values (p_emp_id, v_old_salary, p_new_salary, v_final_status, now());
        -- 业务意义：无论是否自动通过，都要记录这次操作（审计需求）
        
        commit;  -- 提交事务，使所有操作永久生效
        set p_approval_status = v_final_status;  -- 返回审批状态
    end if;

    -- ========================================================================
    -- 第五部分：存储过程结束（事务已经提交或回滚，无需额外操作）
    -- ========================================================================

end//
delimiter ;




题目三
业务场景： 批量处理逾期未还的图书：遍历所有逾期记录，计算罚款并更新到用户账户，同时标记图书为"逾期"状态。

表结构：

borrows ( borrow_id int, user_id int, book_id int, due_date date, status varchar )
users ( user_id int, balance decimal )
books ( book_id int, status varchar )

delimiter //

create procedure process_overdue_books(
    out p_processed_count int  -- 返回处理了多少条记录
)
begin
    -- [填空1] 声明游标需要的变量（用来存储游标读出的每一行数据）
    declare v_borrow_id int;
    declare v_user_id   int;
    declare v_book_id   _______________; 
    declare v_days_overdue int;

    -- [填空2] 声明标志变量：游标是否读到末尾
    declare v_done int default 0;

    -- [填空3] 声明游标（查询所有逾期且未处理的借阅记录）
    declare cur_overdue _______________ for
        select borrow_id, user_id, book_id, datediff(now(), due_date) as days_overdue
        from borrows
        where due_date < now() and status = 'borrowed';

    -- [填空4] 声明 not found 处理器（游标读完时触发）
    declare continue handler for _______________
        set v_done = 1;

    -- 声明异常处理器
    declare exit handler for sqlexception
    begin
        rollback;
        set p_processed_count = -1; -- 用负数表示失败
    end;

    set p_processed_count = 0;
    start transaction;

    -- [填空5] 打开游标
    _______________ cur_overdue;

    -- [填空6] 开始循环读取游标
    read_loop: _______________
        -- [填空7] 从游标中取一行数据到变量
        _______________ cur_overdue into v_borrow_id, v_user_id, v_book_id, v_days_overdue;

        -- [填空8] 如果读完了，退出循环
        if v_done = 1 then
            _______________;  -- 退出循环
        end if;

        -- 计算罚款：每天 0.5 元
        update users 
        set balance = balance - (v_days_overdue * 0.5)
        where user_id = v_user_id;

        -- 标记图书为逾期状态
        update books set status = 'overdue' where book_id = v_book_id;

        -- 标记借阅记录为已处理
        update borrows set status = 'overdue_processed' where borrow_id = v_borrow_id;

        -- 计数器加1
        set p_processed_count = p_processed_count + 1;

    -- [填空9] 结束循环
    end loop;

    -- [填空10] 关闭游标
    _______________ cur_overdue;

    commit;

end//
delimiter ;



delimiter //

create procedure process_overdue_books(
    out p_processed_count int  -- 返回值：成功处理的逾期记录数量
)
begin
    -- ========================================================================
    -- 第一部分：变量声明区（游标相关变量必须在这里声明）
    -- ========================================================================
    
    -- 【原填空1位置】游标读取数据的接收变量
    -- 这些变量用于存储游标每次fetch出来的一行数据
    declare v_borrow_id int;            -- 借阅记录id（用于更新具体记录）
    declare v_user_id   int;            -- 用户id（用于扣除罚款）
    declare v_book_id   int;            -- 图书id（用于标记图书状态）【原填空位置】
    declare v_days_overdue int;         -- 逾期天数（用于计算罚款金额）
    
    -- 【原填空2位置】游标结束标志变量（核心控制变量）
    declare v_done int default 0;
    -- 作用：当游标读到最后一行后，not found异常处理器会将它设为1
    -- 主循环通过检查这个变量来判断是否应该退出循环

    -- ========================================================================
    -- 第二部分：游标声明（定义要遍历的数据集）
    -- ========================================================================
    
    -- 【原填空3位置】声明游标（关键字是cursor）
    declare cur_overdue cursor for  -- 游标名称：cur_overdue【原填空：cursor关键字】
        select borrow_id, user_id, book_id, 
               datediff(now(), due_date) as days_overdue
        from borrows
        where due_date < now() and status = 'borrowed';
    -- 游标工作原理解释：
    --   1. 游标是一个"数据集合的指针"，类似于c语言的文件指针
    --   2. 这个select查询不会立即执行，只是定义了"要遍历什么数据"
    --   3. 只有open游标后，查询才会执行，并将结果集缓存起来
    -- 业务逻辑：查找所有已逾期且尚未处理的借阅记录
    --   条件1：due_date < now() 表示已过期
    --   条件2：status = 'borrowed' 表示尚未处理（排除已处理的记录）

    -- ========================================================================
    -- 第三部分：异常处理器声明（必须在游标声明之后）
    -- ========================================================================
    
    -- 【原填空4位置】声明not found异常处理器
    declare continue handler for not found  -- 【原填空：not found关键字】
        set v_done = 1;
    -- 触发时机：当fetch语句尝试读取下一行，但游标已经到达末尾时
    -- 处理动作：将v_done设为1，告诉主循环"数据已经读完了"
    -- 为什么用continue？
    --   因为需要继续执行循环内的if v_done = 1判断和leave语句
    --   如果用exit，会直接退出存储过程，导致游标无法关闭，事务无法提交
    
    -- 系统级异常处理器（处理数据库错误）
    declare exit handler for sqlexception
    begin
        rollback;  -- 撤销所有已处理的记录（确保数据一致性）
        set p_processed_count = -1;  -- 用负数表示处理失败
    end;
    -- 业务意义：如果中途发生错误（如网络断开、表被锁定），
    --          确保已扣除的罚款能够回滚，不会出现"扣了钱但状态没更新"

    -- ========================================================================
    -- 第四部分：初始化与事务开启
    -- ========================================================================
    
    set p_processed_count = 0;  -- 计数器初始化（记录成功处理的记录数）
    start transaction;          -- 开启事务（保证批量操作的原子性）

    -- ========================================================================
    -- 第五部分：游标操作（核心循环逻辑）
    -- ========================================================================
    
    -- 【原填空5位置】打开游标（关键字open）
    open cur_overdue;  -- 【原填空：open关键字】
    -- 执行时机：这一步会真正执行游标定义中的select语句
    -- 执行结果：查询结果集被加载到内存，游标指针指向第一行之前
    
    -- 【原填空6位置】开始循环（关键字loop）
    read_loop: loop  -- 【原填空：loop关键字】循环标签名：read_loop
        -- 循环标签作用：配合leave语句使用，指定要退出的是哪个循环
        --              （当有嵌套循环时，标签非常重要）
        
        -- 【原填空7位置】从游标中读取一行数据（关键字fetch）
        fetch cur_overdue into v_borrow_id, v_user_id, v_book_id, v_days_overdue;
        -- 【原填空：fetch关键字】
        -- fetch工作原理：
        --   1. 将游标当前指向的那一行数据，按列顺序赋值给变量
        --   2. 变量顺序必须与select子句的列顺序一一对应
        --   3. 读取完成后，游标自动向下移动一行
        --   4. 如果已经是最后一行，再fetch会触发not found异常
        
        -- 【原填空8位置】检查游标是否已读完（退出循环的条件）
        if v_done = 1 then
            leave read_loop;  -- 【原填空：leave语句】退出read_loop循环
        end if;
        -- 逻辑解释：
        --   当fetch读到最后一行后，not found处理器会将v_done设为1
        --   下一次循环时，这个if判断会生效，执行leave退出循环

        -- --------------------------------------------------------------------
        -- 业务逻辑处理：对当前读取的记录进行操作
        -- --------------------------------------------------------------------
        
        -- 操作1：扣除用户罚款（罚款规则：每天0.5元）
        update users 
        set balance = balance - (v_days_overdue * 0.5)
        where user_id = v_user_id;
        -- 注意：这里使用的是变量v_user_id（从游标读出来的值）
        
        -- 操作2：标记图书为逾期状态
        update books 
        set status = 'overdue' 
        where book_id = v_book_id;
        -- 业务意义：防止其他用户借阅这本逾期未还的图书
        
        -- 操作3：标记借阅记录为已处理
        update borrows 
        set status = 'overdue_processed' 
        where borrow_id = v_borrow_id;
        -- 业务意义：防止下次运行存储过程时重复处理同一条记录
        
        -- 操作4：计数器加1
        set p_processed_count = p_processed_count + 1;
        -- 业务意义：告知调用方本次处理了多少条记录（审计需求）

    -- 【原填空9位置】结束循环（关键字end loop）
    end loop;  -- 【原填空：end loop关键字】（注意有分号）

    -- ========================================================================
    -- 第六部分：游标关闭与事务提交
    -- ========================================================================
    
    -- 【原填空10位置】关闭游标（关键字close）
    close cur_overdue;  -- 【原填空：close关键字】
    -- 为什么必须关闭？
    --   1. 释放游标占用的内存（结果集可能很大）
    --   2. 释放数据库锁（游标可能持有表的共享锁）
    --   3. 虽然存储过程结束时会自动关闭，但显式关闭是规范写法
    
    commit;  -- 提交事务，使所有update操作永久生效

end//
delimiter ;


游标的生命周期 五步走
-- 步骤1：声明接收变量（在游标声明之前）
declare v_id int;
declare v_name varchar(50);

-- 步骤2：声明游标（定义要遍历什么数据）
declare cur_name cursor for select id, name from table_name;

-- 步骤3：声明not found处理器（在游标声明之后）
declare continue handler for not found set v_done = 1;

-- 步骤4：打开游标（真正执行查询）
open cur_name;

-- 步骤5：循环读取
loop
    fetch cur_name into v_id, v_name;  -- 读取一行
    if v_done = 1 then leave loop_label; end if;  -- 检查是否读完
    -- 处理数据
end loop;

-- 步骤6：关闭游标（释放资源）
close cur_name;



声名顺序关于： 普通变量 游标 异常处理器 可执行语句
begin
    -- 顺序1：普通变量
    declare v_var1 int;
    
    -- 顺序2：游标
    declare cur_name cursor for ... ;
    
    -- 顺序3：异常处理器
    declare continue handler for not found ...;
    
    -- 顺序4：可执行语句
    open cur_name;
end

