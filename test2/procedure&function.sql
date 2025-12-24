-- ============================================================================
-- 数据库期末复习：存储过程 + 存储函数 专项训练
-- 复习策略：先背模板 → 理解关键词 → 做填空题 → 看完整解析 → 总结易错点
-- 建议用时：3-4小时
-- ============================================================================
-- ============================================================================
-- 第一部分：模板语法速查（考前5分钟背诵）
-- ============================================================================
/*
【存储过程模板】
delimiter $$
create procedure 过程名(
    in 输入参数 类型,
    out 输出参数 类型,
    inout 输入输出参数 类型
)
begin
    -- 1. 声明变量
    declare 变量名 类型 default 默认值;
    
    -- 2. 声明异常处理器
    declare exit/continue handler for sqlexception/not found/sqlstate 'xxxxx'
    begin
        处理逻辑;
    end;
    
    -- 3. 事务控制
    start transaction;
    
    -- 4. 业务逻辑
    select ...  into 变量 from ... where ...;
    if 条件 then ...  end if;
    update/insert/delete ... ;
    
    -- 5. 提交/回滚
    commit / rollback;
end$$
delimiter ;

-- 调用方式
call 过程名(参数1, @输出变量, 参数3);
select @输出变量;
*/
/*
【存储函数模板】
delimiter $$
create function 函数名(参数名 类型)
returns 返回类型
[deterministic / not deterministic]
[reads sql data / modifies sql data / no sql]
begin
    -- 1. 声明变量
    declare 变量名 类型;
    
    -- 2. 业务逻辑
    select ... into 变量 from ...  where ...;
    
    -- 3. 返回值（必须）
    return 变量/表达式;
end$$
delimiter ;

-- 调用方式
select 函数名(参数);
select * from table where 函数名(字段) > 100;
*/
/*
【游标模板（在存储过程中使用）】
begin
    -- 1. 声明接收变量
    declare v_var1 类型;
    declare v_done int default 0;
    
    -- 2. 声明游标
    declare 游标名 cursor for select语句;
    
    -- 3. 声明not found处理器
    declare continue handler for not found set v_done = 1;
    
    -- 4. 打开游标
    open 游标名;
    
    -- 5. 循环读取
    read_loop:  loop
        fetch 游标名 into v_var1, ... ;
        if v_done = 1 then
            leave read_loop;
        end if;
        -- 处理数据
    end loop;
    
    -- 6. 关闭游标
    close 游标名;
end;
*/-- ============================================================================
-- 第二部分：关键词详解（易混淆点重点标注⚠️）
-- ============================================================================
/*
【一、存储过程参数类型】
+--------+----------+----------+----------------------------------------+
| 类型   | 能输入   | 能输出   | 使用场景                               |
+--------+----------+----------+----------------------------------------+
| in     | ✅       | ❌       | 只需要传入参数（如查询条件）           |
| out    | ❌       | ✅       | 只需要返回结果（如统计数量）           |
| inout  | ✅       | ✅       | 需要修改参数本身（如分数转等级）       |
+--------+----------+----------+----------------------------------------+

⚠️ 易错点1：out参数在过程内部可以直接赋值，不需要先传入初始值
⚠️ 易错点2：调用时out参数必须用@变量，不能用常量

示例：
call proc(100, @result, @status);  -- ✅ 正确
call proc(100, result, status);     -- ❌ 错误：out参数必须带@
*/
/*
【二、存储函数参数类型】
⚠️ 重要：存储函数只能有in参数（而且in可以省略不写）

错误示例：
create function func(out param int) ...  -- ❌ 函数不能有out参数

正确示例：
create function func(param int) ...     -- ✅ 默认就是in
create function func(in param int) ...  -- ✅ 显式写in也可以
*/
/*
【三、存储函数特性声明】
+--------------------+----------------------------------+------------------------+
| 特性               | 含义                             | 使用场景               |
+--------------------+----------------------------------+------------------------+
| deterministic      | 相同输入→相同输出                | 数学计算、等级判断     |
| not deterministic  | 相同输入→可能不同输出（默认）    | 涉及now()/rand()/查库  |
| reads sql data     | 包含select查询                   | 查询数据库并返回       |
| modifies sql data  | 包含update/insert/delete         | 不推荐在函数中用       |
| no sql             | 没有sql语句                      | 纯逻辑计算             |
+--------------------+----------------------------------+------------------------+

⚠️ 易错点3：returns（有s）是声明类型，return（无s）是返回值
⚠️ 易错点4：函数必须有return语句，过程可以没有返回值
⚠️ 易错点5：reads sql data和deterministic可以同时出现

正确组合示例：
create function get_avg(id int)
returns decimal
not deterministic  -- 因为数据可能变化
reads sql data     -- 因为有select查询
begin
    declare avg_val decimal;
    select avg(score) into avg_val from sc where student_id = id;
    return avg_val;
end;
*/
/*
【四、异常处理器类型】
+----------+------------------+----------------------------------+
| 类型     | 遇到异常后       | 使用场景                         |
+----------+------------------+----------------------------------+
| exit     | 立即退出过程/函数| 系统错误、无法恢复的错误         |
| continue | 继续执行后续代码 | 业务错误、需要记录日志的错误     |
+----------+------------------+----------------------------------+

⚠️ 易错点6：游标结束必须用continue handler，不能用exit
⚠️ 易错点7：多个handler可以共存，优先级：具体sqlstate > not found > sqlexception

正确示例：
declare continue handler for not found set v_not_found = 1;     -- 处理查询无结果
declare continue handler for sqlstate '23000' set v_error = 1;  -- 处理约束违反
declare exit handler for sqlexception begin rollback; end;      -- 处理其他所有错误
*/
/*
【五、异常类型】
+-------------------+-------------------------------+
| 异常类型          | 触发场景                      |
+-------------------+-------------------------------+
| sqlexception      | 所有sql错误（语法、权限等）   |
| not found         | select into无结果、游标读完   |
| sqlstate '23000'  | 约束违反（主键/外键/check）   |
| sqlstate '45000'  | 用户自定义错误（signal抛出）  |
+-------------------+-------------------------------+

⚠️ 易错点8：sqlstate后面的错误码必须用引号，是字符串不是数字
*/
/*
【六、事务控制】
start transaction; -- 开启事务
commit;            -- 提交事务（永久生效）
rollback;          -- 回滚事务（撤销所有操作）

⚠️ 易错点9：rollback只回滚数据库操作（update/insert/delete），不回滚变量赋值（set）
⚠️ 易错点10：触发器中不能显式调用start transaction/commit/rollback

示例：
start transaction;
update account set balance = 100 where id = 1;
set @msg = '已更新';
rollback;
-- 结果：balance恢复原值，但@msg仍然是'已更新'
*/
/*
【七、游标关键字】
declare 游标名 cursor for ...   -- 声明游标
open 游标名                    -- 打开游标（执行查询）
fetch 游标名 into 变量列表     -- 读取一行数据
close 游标名                   -- 关闭游标（释放资源）
leave 循环标签                 -- 退出循环

⚠️ 易错点11：fetch的变量顺序必须与select的列顺序一致
⚠️ 易错点12：游标声明必须在handler声明之前
*/
/*
【八、声明顺序（mysql强制要求）】
begin
    -- 顺序1：普通变量
    declare v_var int;
    
    -- 顺序2：游标
    declare cur_name cursor for ... ;
    
    -- 顺序3：异常处理器
    declare continue handler for ...;
    
    -- 顺序4：可执行语句（open/select/update等）
    open cur_name;
end;

⚠️ 易错点13：如果顺序错误，会报"syntax error"
*/-- ============================================================================
-- 第三部分：填空题训练（从易到难，共10题）
-- ============================================================================
-- ----------------------------------------------------------------------------
-- 【基础题1】存储过程参数类型（难度：⭐）
-- 考点：in/out/inout的基本用法
-- ----------------------------------------------------------------------------
/*
题目：创建一个存储过程，计算两个数的和与差
要求：传入两个数a和b，返回它们的和(sum)与差(diff)
*/

delimiter $$
CREATE PROCEDURE calc_sum_diff ( _____ p_a INT, -- [填空1] 输入参数a
  _____ p_b INT, -- [填空2] 输入参数b
  _____ p_sum INT, -- [填空3] 输出参数sum
  _____ p_diff INT -- [填空4] 输出参数diff
  ) BEGIN
  
  SET p_sum = p_a + p_b;
  
  SET p_diff = p_a - p_b;
  
END $$delimiter;-- 测试调用（请在完成填空后取消注释测试）
-- call calc_sum_diff(10, 3, @s, @d);
-- select @s as 和, @d as 差;
-- ----------------------------------------------------------------------------
-- 【基础题2】存储函数返回值（难度：⭐）
-- 考点：returns vs return，函数特性声明
-- ----------------------------------------------------------------------------
/*
题目：创建函数计算圆的面积
要求：传入半径，返回面积（π取3.14）
*/

delimiter $$
CREATE FUNCTION calc_circle_area (
radius DECIMAL ( 10, 2 )) _______ DECIMAL ( 10, 2 ) -- [填空5] 声明返回类型（有s）
_______ -- [填空6] 特性声明：相同半径→相同面积
BEGIN
    _______ 3.14 * radius * radius;-- [填空7] 返回值（无s）
  
END $$delimiter;-- 测试调用
-- select calc_circle_area(5) as 面积;
-- ----------------------------------------------------------------------------
-- 【基础题3】异常处理器类型（难度：⭐⭐）
-- 考点：exit vs continue，sqlexception vs not found
-- ----------------------------------------------------------------------------
/*
题目：创建存储过程查询用户余额
要求：如果用户不存在，返回0；如果发生系统错误，立即退出并返回-1
*/

delimiter $$
CREATE PROCEDURE get_balance ( IN p_user_id INT, OUT p_balance DECIMAL ( 10, 2 ) ) BEGIN-- [填空8] 声明not found处理器：用户不存在时设置余额为0
  DECLARE
    _______ HANDLER FOR _______ 
    SET p_balance = 0;-- [填空9] 声明sqlexception处理器：系统错误时立即退出
  DECLARE
    _______ HANDLER FOR _______ BEGIN
      
      SET p_balance = - 1;
    
  END;
  SELECT
    balance INTO p_balance 
  FROM
    users 
  WHERE
    user_id = p_user_id;
  
END $$delimiter;-- ----------------------------------------------------------------------------
-- 【中等题4】事务控制（难度：⭐⭐）
-- 考点：start transaction、commit、rollback
-- ----------------------------------------------------------------------------
/*
题目：转账操作
要求：从账户a转账到账户b，如果发生错误则回滚
*/

delimiter $$
CREATE PROCEDURE transfer_money ( IN p_from INT, IN p_to INT, IN p_amount DECIMAL ( 10, 2 ), OUT p_result VARCHAR ( 50 ) ) BEGIN
  DECLARE
    v_error INT DEFAULT 0;
  DECLARE
  CONTINUE HANDLER FOR SQLEXCEPTION 
    SET v_error = 1;-- [填空10] 开启事务
  _______ _______;-- 扣款
  UPDATE accounts 
  SET balance = balance - p_amount 
  WHERE
    id = p_from;-- 入账
  UPDATE accounts 
  SET balance = balance + p_amount 
  WHERE
    id = p_to;-- [填空11] 检查错误：如果有错则回滚，否则提交
  IF
    v_error = 1 THEN
      _______;-- 回滚
    
    SET p_result = 'fail';
    ELSE _______;-- 提交
    
    SET p_result = 'success';
    
  END IF;
  
END $$delimiter;-- ----------------------------------------------------------------------------
-- 【中等题5】函数特性声明（难度：⭐⭐）
-- 考点：reads sql data、not deterministic
-- ----------------------------------------------------------------------------
/*
题目：创建函数查询学生平均分
要求：传入学生id，返回平均分（如果没有成绩返回0）
*/

delimiter $$
CREATE FUNCTION get_student_avg ( stu_id INT ) RETURNS DECIMAL ( 5, 2 ) _______ -- [填空12] 特性声明：包含select查询
_______ -- [填空13] 特性声明：数据可能变化
BEGIN
  DECLARE
    avg_score DECIMAL ( 5, 2 );
  SELECT
    avg( score ) INTO avg_score 
  FROM
    sc 
  WHERE
    student_id = stu_id;
  RETURN ifnull( avg_score, 0 );
  
END $$delimiter;-- ----------------------------------------------------------------------------
-- 【中等题6】约束错误捕获（难度：⭐⭐⭐）
-- 考点：sqlstate '23000'，continue handler
-- ----------------------------------------------------------------------------
/*
题目：更新员工薪资
要求：如果新薪资违反约束（如低于最低工资3000），捕获错误并返回失败信息
*/

delimiter $$
CREATE PROCEDURE update_salary ( IN p_emp_id INT, IN p_new_salary DECIMAL ( 10, 2 ), OUT p_status VARCHAR ( 50 ) ) BEGIN
  DECLARE
    v_constraint_error INT DEFAULT 0;-- [填空14] 声明约束违反处理器（sqlstate '23000'）
  DECLARE
    CONTINUE HANDLER FOR SQLSTATE '_______' 
    SET v_constraint_error = 1;
  START TRANSACTION;
  UPDATE employees 
  SET salary = p_new_salary 
  WHERE
    emp_id = p_emp_id;-- [填空15] 检查是否违反约束
  IF
    _______ = 1 THEN
      ROLLBACK;
    
    SET p_status = '薪资违反约束';
    ELSE COMMIT;
    
    SET p_status = '更新成功';
    
  END IF;
  
END $$delimiter;-- -------------------------------------------- ============================================================================
-- 数据库期末复习：存储过程 + 存储函数 专项训练
-- 复习策略：先背模板 → 理解关键词 → 做填空题 → 看完整解析 → 总结易错点
-- 建议用时：3-4小时
-- ============================================================================

-- ============================================================================
-- 第一部分：模板语法速查（考前5分钟背诵）
-- ============================================================================

/*
【存储过程模板】
DELIMITER $$
CREATE PROCEDURE 过程名(
    IN 输入参数 类型,
    OUT 输出参数 类型,
    INOUT 输入输出参数 类型
)
BEGIN
    -- 1. 声明变量
    DECLARE 变量名 类型 DEFAULT 默认值;
    
    -- 2. 声明异常处理器
    DECLARE EXIT/CONTINUE HANDLER FOR SQLEXCEPTION/NOT FOUND/SQLSTATE 'xxxxx'
    BEGIN
        处理逻辑;
    END;
    
    -- 3. 事务控制
    START TRANSACTION;
    
    -- 4. 业务逻辑
    SELECT ...  INTO 变量 FROM ... WHERE ...;
    IF 条件 THEN ...  END IF;
    UPDATE/INSERT/DELETE ... ;
    
    -- 5. 提交/回滚
    COMMIT / ROLLBACK;
END$$
DELIMITER ;

-- 调用方式
CALL 过程名(参数1, @输出变量, 参数3);
SELECT @输出变量;
*/

/*
【存储函数模板】
DELIMITER $$
CREATE FUNCTION 函数名(参数名 类型)
RETURNS 返回类型
[DETERMINISTIC / NOT DETERMINISTIC]
[READS SQL DATA / MODIFIES SQL DATA / NO SQL]
BEGIN
    -- 1. 声明变量
    DECLARE 变量名 类型;
    
    -- 2. 业务逻辑
    SELECT ... INTO 变量 FROM ...  WHERE ...;
    
    -- 3. 返回值（必须）
    RETURN 变量/表达式;
END$$
DELIMITER ;

-- 调用方式
SELECT 函数名(参数);
SELECT * FROM table WHERE 函数名(字段) > 100;
*/

/*
【游标模板（在存储过程中使用）】
BEGIN
    -- 1. 声明接收变量
    DECLARE v_var1 类型;
    DECLARE v_done INT DEFAULT 0;
    
    -- 2. 声明游标
    DECLARE 游标名 CURSOR FOR SELECT语句;
    
    -- 3. 声明NOT FOUND处理器
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    -- 4. 打开游标
    OPEN 游标名;
    
    -- 5. 循环读取
    read_loop:  LOOP
        FETCH 游标名 INTO v_var1, ... ;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;
        -- 处理数据
    END LOOP;
    
    -- 6. 关闭游标
    CLOSE 游标名;
END;
*/


-- ============================================================================
-- 第二部分：关键词详解（易混淆点重点标注⚠️）
-- ============================================================================

/*
【一、存储过程参数类型】
+--------+----------+----------+----------------------------------------+
| 类型   | 能输入   | 能输出   | 使用场景                               |
+--------+----------+----------+----------------------------------------+
| IN     | ✅       | ❌       | 只需要传入参数（如查询条件）           |
| OUT    | ❌       | ✅       | 只需要返回结果（如统计数量）           |
| INOUT  | ✅       | ✅       | 需要修改参数本身（如分数转等级）       |
+--------+----------+----------+----------------------------------------+

⚠️ 易错点1：OUT参数在过程内部可以直接赋值，不需要先传入初始值
⚠️ 易错点2：调用时OUT参数必须用@变量，不能用常量

示例：
CALL proc(100, @result, @status);  -- ✅ 正确
CALL proc(100, result, status);     -- ❌ 错误：OUT参数必须带@
*/

/*
【二、存储函数参数类型】
⚠️ 重要：存储函数只能有IN参数（而且IN可以省略不写）

错误示例：
CREATE FUNCTION func(OUT param INT) ...  -- ❌ 函数不能有OUT参数

正确示例：
CREATE FUNCTION func(param INT) ...     -- ✅ 默认就是IN
CREATE FUNCTION func(IN param INT) ...  -- ✅ 显式写IN也可以
*/

/*
【三、存储函数特性声明】
+--------------------+----------------------------------+------------------------+
| 特性               | 含义                             | 使用场景               |
+--------------------+----------------------------------+------------------------+
| DETERMINISTIC      | 相同输入→相同输出                | 数学计算、等级判断     |
| NOT DETERMINISTIC  | 相同输入→可能不同输出（默认）    | 涉及NOW()/RAND()/查库  |
| READS SQL DATA     | 包含SELECT查询                   | 查询数据库并返回       |
| MODIFIES SQL DATA  | 包含UPDATE/INSERT/DELETE         | 不推荐在函数中用       |
| NO SQL             | 没有SQL语句                      | 纯逻辑计算             |
+--------------------+----------------------------------+------------------------+

⚠️ 易错点3：RETURNS（有S）是声明类型，RETURN（无S）是返回值
⚠️ 易错点4：函数必须有RETURN语句，过程可以没有返回值
⚠️ 易错点5：READS SQL DATA和DETERMINISTIC可以同时出现

正确组合示例：
CREATE FUNCTION get_avg(id INT)
RETURNS DECIMAL
NOT DETERMINISTIC  -- 因为数据可能变化
READS SQL DATA     -- 因为有SELECT查询
BEGIN
    DECLARE avg_val DECIMAL;
    SELECT AVG(score) INTO avg_val FROM sc WHERE student_id = id;
    RETURN avg_val;
END;
*/

/*
【四、异常处理器类型】
+----------+------------------+----------------------------------+
| 类型     | 遇到异常后       | 使用场景                         |
+----------+------------------+----------------------------------+
| EXIT     | 立即退出过程/函数| 系统错误、无法恢复的错误         |
| CONTINUE | 继续执行后续代码 | 业务错误、需要记录日志的错误     |
+----------+------------------+----------------------------------+

⚠️ 易错点6：游标结束必须用CONTINUE HANDLER，不能用EXIT
⚠️ 易错点7：多个HANDLER可以共存，优先级：具体SQLSTATE > NOT FOUND > SQLEXCEPTION

正确示例：
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;     -- 处理查询无结果
DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' SET v_error = 1;  -- 处理约束违反
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;      -- 处理其他所有错误
*/

/*
【五、异常类型】
+-------------------+-------------------------------+
| 异常类型          | 触发场景                      |
+-------------------+-------------------------------+
| SQLEXCEPTION      | 所有SQL错误（语法、权限等）   |
| NOT FOUND         | SELECT INTO无结果、游标读完   |
| SQLSTATE '23000'  | 约束违反（主键/外键/CHECK）   |
| SQLSTATE '45000'  | 用户自定义错误（SIGNAL抛出）  |
+-------------------+-------------------------------+

⚠️ 易错点8：SQLSTATE后面的错误码必须用引号，是字符串不是数字
*/

/*
【六、事务控制】
START TRANSACTION; -- 开启事务
COMMIT;            -- 提交事务（永久生效）
ROLLBACK;          -- 回滚事务（撤销所有操作）

⚠️ 易错点9：ROLLBACK只回滚数据库操作（UPDATE/INSERT/DELETE），不回滚变量赋值（SET）
⚠️ 易错点10：触发器中不能显式调用START TRANSACTION/COMMIT/ROLLBACK

示例：
START TRANSACTION;
UPDATE account SET balance = 100 WHERE id = 1;
SET @msg = '已更新';
ROLLBACK;
-- 结果：balance恢复原值，但@msg仍然是'已更新'
*/

/*
【七、游标关键字】
DECLARE 游标名 CURSOR FOR ...   -- 声明游标
OPEN 游标名                    -- 打开游标（执行查询）
FETCH 游标名 INTO 变量列表     -- 读取一行数据
CLOSE 游标名                   -- 关闭游标（释放资源）
LEAVE 循环标签                 -- 退出循环

⚠️ 易错点11：FETCH的变量顺序必须与SELECT的列顺序一致
⚠️ 易错点12：游标声明必须在HANDLER声明之前
*/

/*
【八、声明顺序（MySQL强制要求）】
BEGIN
    -- 顺序1：普通变量
    DECLARE v_var INT;
    
    -- 顺序2：游标
    DECLARE cur_name CURSOR FOR ... ;
    
    -- 顺序3：异常处理器
    DECLARE CONTINUE HANDLER FOR ...;
    
    -- 顺序4：可执行语句（OPEN/SELECT/UPDATE等）
    OPEN cur_name;
END;

⚠️ 易错点13：如果顺序错误，会报"syntax error"
*/


-- ============================================================================
-- 第三部分：填空题训练（从易到难，共10题）
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 【基础题1】存储过程参数类型（难度：⭐）
-- 考点：IN/OUT/INOUT的基本用法
-- ----------------------------------------------------------------------------
/*
题目：创建一个存储过程，计算两个数的和与差
要求：传入两个数a和b，返回它们的和(sum)与差(diff)
*/

DELIMITER $$
CREATE PROCEDURE calc_sum_diff(
    _in__ p_a INT,          -- [填空1] 输入参数a
    __in_ p_b INT,          -- [填空2] 输入参数b
    _out_ p_sum INT,        -- [填空3] 输出参数sum
    _out_ p_diff INT        -- [填空4] 输出参数diff
)
BEGIN
    SET p_sum = p_a + p_b;
    SET p_diff = p_a - p_b;
END$$
DELIMITER ;

-- 测试调用（请在完成填空后取消注释测试）
-- CALL calc_sum_diff(10, 3, @s, @d);
-- SELECT @s AS 和, @d AS 差;


-- ----------------------------------------------------------------------------
-- 【基础题2】存储函数返回值（难度：⭐）
-- 考点：RETURNS vs RETURN，函数特性声明
-- ----------------------------------------------------------------------------
/*
题目：创建函数计算圆的面积
要求：传入半径，返回面积（π取3.14）
*/

DELIMITER $$
CREATE FUNCTION calc_circle_area(radius DECIMAL(10,2))
returns_ DECIMAL(10,2)    -- [填空5] 声明返回类型（有S）
_deterministic_                  -- [填空6] 特性声明：相同半径→相同面积
BEGIN
    return 3.14 * radius * radius;  -- [填空7] 返回值（无S）
END$$
DELIMITER ;

-- 测试调用
-- SELECT calc_circle_area(5) AS 面积;


-- ----------------------------------------------------------------------------
-- 【基础题3】异常处理器类型（难度：⭐⭐）
-- 考点：EXIT vs CONTINUE，SQLEXCEPTION vs NOT FOUND
-- ----------------------------------------------------------------------------
/*
题目：创建存储过程查询用户余额
要求：如果用户不存在，返回0；如果发生系统错误，立即退出并返回-1
*/

DELIMITER $$
CREATE PROCEDURE get_balance(
    IN p_user_id INT,
    OUT p_balance DECIMAL(10,2)
)
BEGIN
    -- [填空8] 声明NOT FOUND处理器：用户不存在时设置余额为0
    DECLARE _continue_ HANDLER FOR _not found_
        SET p_balance = 0;
    
    -- [填空9] 声明SQLEXCEPTION处理器：系统错误时立即退出
    DECLARE _exit_ HANDLER FOR _sqlexception_
    BEGIN
        SET p_balance = -1;
    END;
    
    SELECT balance INTO p_balance FROM users WHERE user_id = p_user_id;
END$$
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 【中等题4】事务控制（难度：⭐⭐）
-- 考点：START TRANSACTION、COMMIT、ROLLBACK
-- ----------------------------------------------------------------------------
/*
题目：转账操作
要求：从账户A转账到账户B，如果发生错误则回滚
*/

DELIMITER $$
CREATE PROCEDURE transfer_money(
    IN p_from INT,
    IN p_to INT,
    IN p_amount DECIMAL(10,2),
    OUT p_result VARCHAR(50)
)
BEGIN
    DECLARE v_error INT DEFAULT 0;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_error = 1;
    
    -- [填空10] 开启事务
    __start transaction_;
    
    -- 扣款
    UPDATE accounts SET balance = balance - p_amount WHERE id = p_from;
    
    -- 入账
    UPDATE accounts SET balance = balance + p_amount WHERE id = p_to;
    
    -- [填空11] 检查错误：如果有错则回滚，否则提交
    IF v_error = 1 THEN
        _rollback_;         -- 回滚
        SET p_result = 'Fail';
    ELSE
        _commit_;         -- 提交
        SET p_result = 'Success';
    END IF;
END$$
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 【中等题5】函数特性声明（难度：⭐⭐）
-- 考点：READS SQL DATA、NOT DETERMINISTIC
-- ----------------------------------------------------------------------------
/*
题目：创建函数查询学生平均分
要求：传入学生ID，返回平均分（如果没有成绩返回0）
*/

DELIMITER $$
CREATE FUNCTION get_student_avg(stu_id INT)
RETURNS DECIMAL(5,2)
_reads sql data_              -- [填空12] 特性声明：包含SELECT查询
_not deterministic_              -- [填空13] 特性声明：数据可能变化
BEGIN
    DECLARE avg_score DECIMAL(5,2);
    
    SELECT AVG(score) INTO avg_score FROM sc WHERE student_id = stu_id;
    
    RETURN IFNULL(avg_score, 0);
END$$
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 【中等题6】约束错误捕获（难度：⭐⭐⭐）
-- 考点：SQLSTATE '23000'，CONTINUE HANDLER
-- ----------------------------------------------------------------------------
/*
题目：更新员工薪资
要求：如果新薪资违反约束（如低于最低工资3000），捕获错误并返回失败信息
*/

DELIMITER $$
CREATE PROCEDURE update_salary(
    IN p_emp_id INT,
    IN p_new_salary DECIMAL(10,2),
    OUT p_status VARCHAR(50)
)
BEGIN
    DECLARE v_constraint_error INT DEFAULT 0;
    
    -- [填空14] 声明约束违反处理器（SQLSTATE '23000'）
    DECLARE CONTINUE HANDLER FOR SQLSTATE '_______'
        SET v_constraint_error = 1;
    
    START TRANSACTION;
    
    UPDATE employees SET salary = p_new_salary WHERE emp_id = p_emp_id;
    
    -- [填空15] 检查是否违反约束
    IF _v_constraint_error_ = 1 THEN
        ROLLBACK;
        SET p_status = '薪资违反约束';
    ELSE
        COMMIT;
        SET p_status = '更新成功';
    END IF;
END$$
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 【中等题7】INOUT参数（难度：⭐⭐⭐）
-- 考点：参数既输入又输出
-- ----------------------------------------------------------------------------
/*
题目：分数转等级
要求：传入分数字符串（如'85'），转换成等级（如'良好'）并返回
*/

DELIMITER $$
CREATE PROCEDURE score_to_grade(
    _inout_ p_value VARCHAR(20)  -- [填空16] 既输入又输出的参数类型
)
BEGIN
    DECLARE v_score INT;
    SET v_score = CAST(p_value AS SIGNED);
    
    -- [填空17] 使用CASE判断等级
    SET p_value = _case_
        WHEN v_score >= 90 THEN '优秀'
        WHEN v_score >= 80 THEN '良好'
        WHEN v_score >= 60 THEN '及格'
        ELSE '不及格'
    __end_;  -- [填空18] CASE结束关键字
END$$
DELIMITER ;

-- 测试调用
-- SET @grade = '85';
-- CALL score_to_grade(@grade);
-- SELECT @grade;


-- ----------------------------------------------------------------------------
-- 【难题8】游标基础（难度：⭐⭐⭐）
-- 考点：CURSOR、OPEN、FETCH、CLOSE、NOT FOUND
-- ----------------------------------------------------------------------------
/*
题目：遍历所有学生并输出姓名
要求：使用游标逐行读取student表中的姓名
*/

DELIMITER $$
CREATE PROCEDURE print_all_students()
BEGIN
    DECLARE v_name VARCHAR(50);
    DECLARE v_done INT DEFAULT 0;
    
    -- [填空19] 声明游标
    DECLARE cur_students _______ FOR
        SELECT student_name FROM student;
    
    -- [填空20] 声明NOT FOUND处理器
    DECLARE CONTINUE _______ FOR _______
        SET v_done = 1;
    
    -- [填空21] 打开游标
    _______ cur_students;
    
    read_loop: LOOP
        -- [填空22] 从游标读取数据
        _______ cur_students INTO v_name;
        
        IF v_done = 1 THEN
            _______ read_loop;  -- [填空23] 退出循环
        END IF;
        
        SELECT v_name;
    END LOOP;
    
    -- [填空24] 关闭游标
    _______ cur_students;
END$$
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 【难题9】综合应用（难度：⭐⭐⭐⭐）
-- 考点：事务+异常处理+多次查询+业务逻辑
-- ----------------------------------------------------------------------------
/*
题目：会员积分兑换系统
要求：
1. 检查用户是否存在
2. 检查积分是否充足
3. 检查商品库存是否充足
4. 任何一步失败都要回滚并返回具体错误码
状态码：0=成功, -1=用户不存在, -2=积分不足, -3=库存不足, -99=系统错误
*/

DELIMITER $$
CREATE PROCEDURE exchange_product(
    IN  p_user_id    INT,
    IN  p_product_id INT,
    OUT p_status     INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    -- [填空25] 声明3个变量：用户积分、商品价格、商品库存
    DECLARE v_user_points   INT DEFAULT 0;
    DECLARE v_product_price INT DEFAULT 0;
    DECLARE v_product_stock _______ DEFAULT 0;  -- 商品库存
    
    DECLARE v_not_found INT DEFAULT 0;
    
    -- [填空26] 声明NOT FOUND处理器
    DECLARE _______ HANDLER FOR NOT FOUND
        SET v_not_found = 1;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = -99;
        SET p_message = '系统异常';
    END;
    
    -- [填空27] 开启事务
    _______ TRANSACTION;
    
    -- 查询用户积分
    SELECT points INTO v_user_points FROM users WHERE user_id = p_user_id;
    
    -- [填空28] 检查用户是否存在
    IF _______ = 1 THEN
        ROLLBACK;
        SET p_status = -1;
        SET p_message = '用户不存在';
    ELSE
        SET v_not_found = 0;  -- 重置标志
        
        -- [填空29] 查询商品价格和库存
        SELECT point_price, stock INTO _______, v_product_stock
        FROM products WHERE product_id = p_product_id;
        
        IF v_not_found = 1 THEN
            ROLLBACK;
            SET p_status = -3;
            SET p_message = '商品不存在';
        ELSE
            -- [填空30] 检查积分是否充足
            IF v_user_points < _______ THEN
                ROLLBACK;
                SET p_status = -2;
                SET p_message = '积分不足';
            ELSE
                IF v_product_stock < 1 THEN
                    ROLLBACK;
                    SET p_status = -3;
                    SET p_message = '库存不足';
                ELSE
                    -- 扣减积分
                    UPDATE users SET points = points - v_product_price 
                    WHERE user_id = p_user_id;
                    
                    -- 扣减库存
                    UPDATE products SET stock = stock - 1 
                    WHERE product_id = p_product_id;
                    
                    -- [填空31] 提交事务
                    _______;
                    SET p_status = 0;
                    SET p_message = '兑换成功';
                END IF;
            END IF;
        END IF;
    END IF;
END$$
DELIMITER ;


-- ----------------------------------------------------------------------------
-- 【难题10】游标综合应用（难度：⭐⭐⭐⭐⭐）
-- 考点：游标+事务+异常处理+批量更新
-- ----------------------------------------------------------------------------
/*
题目：批量处理逾期图书
要求：
1. 遍历所有逾期且未处理的借阅记录
2. 计算罚款（每天0.5元）并扣除用户余额
3. 标记图书和借阅记录状态
4. 返回处理的记录数量（失败返回-1）
*/

DELIMITER $$
CREATE PROCEDURE process_overdue_books(
    OUT p_processed_count INT
)
BEGIN
    DECLARE v_borrow_id INT;
    DECLARE v_user_id INT;
    DECLARE v_book_id INT;
    DECLARE v_days_overdue INT;
    DECLARE v_done INT DEFAULT 0;
    
    -- [填空32] 声明游标（查询逾期记录）
    DECLARE cur_overdue CURSOR FOR
        SELECT borrow_id, user_id, book_id, 
               DATEDIFF(NOW(), due_date) AS days_overdue
        FROM borrows
        WHERE due_date < NOW() AND status = 'borrowed';
    
    -- [填空33] 声明NOT FOUND处理器
    DECLARE CONTINUE HANDLER FOR _______
        SET v_done = 1;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_processed_count = -1;
    END;
    
    SET p_processed_count = 0;
    START TRANSACTION;
    
    -- [填空34] 打开游标
    _______ cur_overdue;
    
    -- [填空35] 开始循环
    read_loop: _______
        -- [填空36] 读取一行数据
        _______ cur_overdue INTO v_borrow_id, v_user_id, v_book_id, v_days_overdue;
        
        -- [填空37] 检查是否读完
        IF v_done = 1 THEN
            _______ read_loop;  -- 退出循环
        END IF;
        
        -- 计算罚款
        UPDATE users 
        SET balance = balance - (v_days_overdue * 0.5)
        WHERE user_id = v_user_id;
        
        -- 标记图书状态
        UPDATE books SET status = 'overdue' WHERE book_id = v_book_id;
        
        -- 标记借阅记录
        UPDATE borrows SET status = 'overdue_processed' WHERE borrow_id = v_borrow_id;
        
        SET p_processed_count = p_processed_count + 1;
    
    -- [填空38] 结束循环
    _______ LOOP;
    
    -- [填空39] 关闭游标
    _______ cur_overdue;
    
    COMMIT;
END$$
DELIMITER ;


-- ============================================================================
-- 第四部分：完整答案与详解
-- ============================================================================

/*
【基础题1答案】
[填空1] IN
[填空2] IN
[填空3] OUT
[填空4] OUT

解析：
- p_a和p_b是输入参数，使用IN
- p_sum和p_diff是输出参数，使用OUT
- OUT参数在过程内部可以直接赋值
*/

/*
【基础题2答案】
[填空5] RETURNS
[填空6] DETERMINISTIC
[填空7] RETURN

解析：
- RETURNS（有S）用于声明返回类型
- DETERMINISTIC表示相同输入产生相同输出（圆面积是确定的）
- RETURN（无S）用于返回具体值
- ⚠️ 记忆技巧：有S声明，无S返回
*/

/*
【基础题3答案】
[填空8] CONTINUE, NOT FOUND
[填空9] EXIT, SQLEXCEPTION

解析：
- 查询不到用户时，使用CONTINUE HANDLER继续执行（设置默认值0）
- 系统错误时，使用EXIT HANDLER立即退出
- NOT FOUND专门处理SELECT INTO无结果的情况
- SQLEXCEPTION捕获所有SQL错误
*/

/*
【中等题4答案】
[填空10] START TRANSACTION
[填空11] ROLLBACK（第一个空），COMMIT（第二个空）

解析：
- START TRANSACTION开启事务
- ROLLBACK撤销所有数据库操作（扣款和入账）
- COMMIT使操作永久生效
- ⚠️ 注意：ROLLBACK不会撤销变量赋值（SET @var = ... ）
*/

/*
【中等题5答案】
[填空12] READS SQL DATA
[填空13] NOT DETERMINISTIC

解析：
- 函数中包含SELECT查询，必须声明READS SQL DATA
- 数据库中的成绩可能变化，所以是NOT DETERMINISTIC
- 这两个特性可以同时使用
*/

/*
【中等题6答案】
[填空14] 23000
[填空15] v_constraint_error

解析：
- SQLSTATE '23000'专门捕获完整性约束违反错误
- 包括：主键重复、外键冲突、CHECK约束失败、UNIQUE冲突
- ⚠️ 注意：错误码必须用引号（字符串），不能写成数字23000
- 使用CONTINUE HANDLER继续执行，可以记录日志或设置状态
*/

/*
【中等题7答案】
[填空16] INOUT
[填空17] CASE
[填空18] END

解析：
- INOUT参数既可以输入又可以输出
- 这里输入分数字符串'85'，输出等级'良好'
- CASE表达式从上到下匹配，匹配到第一个为真的条件就返回
- ⚠️ 注意：CASE结束用END，不是END CASE
*/

/*
【难题8答案】
[填空19] CURSOR
[填空20] HANDLER, NOT FOUND
[填空21] OPEN
[填空22] FETCH
[填空23] LEAVE
[填空24] CLOSE

解析：
游标五步走：
1. DECLARE CURSOR声明游标
2. DECLARE HANDLER声明NOT FOUND处理器
3. OPEN打开游标（执行查询）
4. FETCH读取一行数据（循环中调用）
5. CLOSE关闭游标（释放资源）

⚠️ 关键点：
- 游标声明必须在HANDLER之前
- NOT FOUND处理器必须用CONTINUE（不能用EXIT）
- FETCH的变量顺序必须与SELECT的列顺序一致
*/

/*
【难题9答案】
[填空25] INT
[填空26] CONTINUE
[填空27] START
[填空28] v_not_found
[填空29] v_product_price
[填空30] v_product_price
[填空31] COMMIT

解析：
这是一个完整的事务处理流程：
1. 声明变量接收查询结果
2. 使用NOT FOUND处理器捕获查询失败
3. 开启事务保证原子性
4. 逐步验证业务条件（用户存在、积分充足、库存充足）
5. 任何条件不满足都要ROLLBACK并设置错误码
6. 所有条件满足后执行UPDATE并COMMIT

⚠️ 重难点：
- 每次SELECT INTO前要重置v_not_found = 0
- 使用嵌套IF-ELSE避免使用LEAVE标签
- ROLLBACK后SET语句仍会执行（用于返回错误信息）
*/

/*
【难题10答案】
[填空32] （已给出完整SQL，无需填空）
[填空33] NOT FOUND
[填空34] OPEN
[填空35] LOOP
[填空36] FETCH
[填空37] LEAVE
[填空38] END
[填空39] CLOSE

解析：
这是游标+事务+批量处理的综合应用：
1. 游标查询所有需要处理的记录
2. 在事务中逐条处理
3. 每条记录执行3个UPDATE操作（扣款、标记图书、标记借阅）
4. 记录处理数量
5. 如果中途发生错误，EXIT HANDLER会回滚所有操作

⚠️ 核心要点：
- 游标循环模式：FETCH → 检查done → 处理数据
- 必须先FETCH再检查v_done（否则会漏掉最后一行）
- CLOSE游标释放资源（虽然过程结束会自动关闭，但显式关闭是规范）
- 游标中的UPDATE操作在同一个事务中，要么全部成功，要么全部回滚
*/


-- ============================================================================
-- 第五部分：易错点总结（考前必看）
-- ============================================================================

/*
【易错点总结表】
+------+----------------------+------------------------+------------------------+
| 编号 | 易错点               | 错误示例               | 正确写法               |
+------+----------------------+------------------------+------------------------+
| 1    | RETURNS vs RETURN    | RETURN INT             | RETURNS INT (声明)     |
|      |                      | BEGIN RETURNS x; END   | BEGIN RETURN x; END    |
+------+----------------------+------------------------+------------------------+
| 2    | OUT参数调用          | CALL proc(1, result);  | CALL proc(1, @result); |
+------+----------------------+------------------------+------------------------+
| 3    | 函数参数类型         | CREATE FUNCTION f(     | 函数只能有IN参数       |
|      |                      |   OUT p INT)           | （IN可省略）           |
+------+----------------------+------------------------+------------------------+
| 4    | SQLSTATE格式         | SQLSTATE 23000         | SQLSTATE '23000'       |
|      |                      |                        | （必须用引号）         |
+------+----------------------+------------------------+------------------------+
| 5    | 游标HANDLER类型      | DECLARE EXIT HANDLER   | DECLARE CONTINUE       |
|      |                      | FOR NOT FOUND          | HANDLER FOR NOT FOUND  |
+------+----------------------+------------------------+------------------------+
| 6    | CASE结束             | CASE ...  END CASE     | CASE ... END           |
|      |                      |                        | （不是END CASE）       |
+------+----------------------+------------------------+------------------------+
| 7    | 声明顺序             | DECLARE HANDLER...     | 变量→游标→HANDLER      |
|      |                      | DECLARE CURSOR...      | →可执行语句            |
+------+----------------------+------------------------+------------------------+
| 8    | 游标FETCH时机        | IF done THEN...        | FETCH先执行            |
|      |                      | FETCH...               | 再检查done标志         |
+------+----------------------+------------------------+------------------------+
| 9    | ROLLBACK作用域       | ROLLBACK撤销SET语句    | 只撤销DML操作          |
|      |                      |                        | （UPDATE/INSERT等）    |
+------+----------------------+------------------------+------------------------+
| 10   | 函数特性组合         | DETERMINISTIC不能与    | 可以同时使用           |
|      |                      | READS SQL DATA共存     | （没有冲突）           |
+------+----------------------+------------------------+------------------------+
*/

/*
【快速记忆口诀】
1. 有S声明，无S返回（RETURNS vs RETURN）
2. 函数只IN，过程三种（IN/OUT/INOUT）
3. EXIT立退，CONTINUE继续
4. 游标必CONTINUE，系统用EXIT
5. 变量游标处理器，顺序不能乱
6. FETCH在前，检查在后
7. 事务只撤DML，变量不回滚
8. 23000约束错，引号不能忘
*/

/*
【考试时间分配建议】
- 看题审题：2分钟（明确要求：IN/OUT/INOUT、函数/过程）
- 填关键词：3分钟（先填简单的：IN/OUT/RETURNS/RETURN）
- 填逻辑词：5分钟（事务控制、异常处理）
- 检查语法：2分钟（引号、顺序、拼写）
总计：12分钟/题
*/

/*
【检查清单】
□ RETURNS有没有S？
□ RETURN有没有S？
□ OUT参数调用时有没有@？
□ SQLSTATE有没有引号？
□ 游标NOT FOUND用的CONTINUE还是EXIT？
□ CASE结束是END还是END CASE？
□ 声明顺序对不对？（变量→游标→HANDLER）
□ 事务有没有COMMIT/ROLLBACK？
□ 游标有没有CLOSE？
□ 函数有没有RETURN语句？
*/


-- ============================================================================
-- 附录：完整可运行示例（供测试用）
-- ============================================================================

-- 创建测试表
CREATE TABLE IF NOT EXISTS accounts (
    id INT PRIMARY KEY,
    balance DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY,
    points INT,
    balance DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    stock INT,
    point_price INT
);

-- 插入测试数据
INSERT INTO accounts VALUES (1, 1000.00), (2, 500.00);
INSERT INTO users VALUES (1, 5000, 1000.00), (2, 200, 500.00);
INSERT INTO products VALUES (1, 10, 300), (2, 0, 500);

-- 测试转账存储过程
CALL transfer_money(1, 2, 100, @result);
SELECT @result;

-- 测试积分兑换存储过程
CALL exchange_product(1, 1, @status, @msg);
SELECT @status, @msg;

-- ============================================================================
-- 结束语
-- ============================================================================
/*
复习完成检查表：
□ 已掌握存储过程三种参数类型（IN/OUT/INOUT）
□ 已掌握存储函数特性声明（DETERMINISTIC/READS SQL DATA等）
□ 已掌握异常处理器类型（EXIT/CONTINUE）
□ 已掌握异常类型（SQLEXCEPTION/NOT FOUND/SQLSTATE）
□ 已掌握事务控制（START TRANSACTION/COMMIT/ROLLBACK）
□ 已掌握游标五步走（DECLARE/OPEN/FETCH/LOOP/CLOSE）
□ 已完成10道填空题练习
□ 已阅读易错点总结

预计掌握程度：_____%
需要重点复习的部分：__________

祝考试顺利！🎉
*/---------------------------------
-- 【中等题7】inout参数（难度：⭐⭐⭐）
-- 考点：参数既输入又输出
-- ----------------------------------------------------------------------------
/*
题目：分数转等级
要求：传入分数字符串（如'85'），转换成等级（如'良好'）并返回
*/

delimiter $$
CREATE PROCEDURE score_to_grade ( _______ p_value VARCHAR ( 20 ) -- [填空16] 既输入又输出的参数类型
  ) BEGIN
  DECLARE
    v_score INT;
  
  SET v_score = cast( p_value AS signed );-- [填空17] 使用case判断等级
  
  SET p_value = _______ 
  WHEN v_score >= 90 THEN
  '优秀' 
  WHEN v_score >= 80 THEN
  '良好' 
  WHEN v_score >= 60 THEN
  '及格' ELSE '不及格' _______;-- [填空18] case结束关键字
  
END $$delimiter;-- 测试调用
-- set @grade = '85';
-- call score_to_grade(@grade);
-- select @grade;
-- ----------------------------------------------------------------------------
-- 【难题8】游标基础（难度：⭐⭐⭐）
-- 考点：cursor、open、fetch、close、not found
-- ----------------------------------------------------------------------------
/*
题目：遍历所有学生并输出姓名
要求：使用游标逐行读取student表中的姓名
*/

delimiter $$
CREATE PROCEDURE print_all_students () BEGIN
  DECLARE
    v_name VARCHAR ( 50 );
  DECLARE
    v_done INT DEFAULT 0;-- [填空19] 声明游标
  DECLARE
    cur_students _______ FOR SELECT
    student_name 
  FROM
    student;-- [填空20] 声明not found处理器
  DECLARE
    CONTINUE _______ FOR _______ 
    SET v_done = 1;-- [填空21] 打开游标
  _______ cur_students;
  read_loop :
  LOOP-- [填空22] 从游标读取数据
    _______ cur_students INTO v_name;
    IF
      v_done = 1 THEN
        _______ read_loop;-- [填空23] 退出循环
      
    END IF;
    SELECT
      v_name;
    
  END LOOP;-- [填空24] 关闭游标
  _______ cur_students;
  
END $$delimiter;-- ----------------------------------------------------------------------------
-- 【难题9】综合应用（难度：⭐⭐⭐⭐）
-- 考点：事务+异常处理+多次查询+业务逻辑
-- ----------------------------------------------------------------------------
/*
题目：会员积分兑换系统
要求：
1. 检查用户是否存在
2. 检查积分是否充足
3. 检查商品库存是否充足
4. 任何一步失败都要回滚并返回具体错误码
状态码：0=成功, -1=用户不存在, -2=积分不足, -3=库存不足, -99=系统错误
*/

delimiter $$
CREATE PROCEDURE exchange_product ( IN p_user_id INT, IN p_product_id INT, OUT p_status INT, OUT p_message VARCHAR ( 100 ) ) BEGIN-- [填空25] 声明3个变量：用户积分、商品价格、商品库存
  DECLARE
    v_user_points INT DEFAULT 0;
  DECLARE
    v_product_price INT DEFAULT 0;
  DECLARE
    v_product_stock _______ DEFAULT 0;-- 商品库存
  DECLARE
    v_not_found INT DEFAULT 0;-- [填空26] 声明not found处理器
  DECLARE
    _______ HANDLER FOR NOT found 
    SET v_not_found = 1;
  DECLARE
  EXIT HANDLER FOR SQLEXCEPTION BEGIN
      ROLLBACK;
    
    SET p_status = - 99;
    
    SET p_message = '系统异常';
    
  END;-- [填空27] 开启事务
  _______ TRANSACTION;-- 查询用户积分
  SELECT
    points INTO v_user_points 
  FROM
    users 
  WHERE
    user_id = p_user_id;-- [填空28] 检查用户是否存在
  IF
    _______ = 1 THEN
      ROLLBACK;
    
    SET p_status = - 1;
    
    SET p_message = '用户不存在';
    ELSE 
      SET v_not_found = 0;-- 重置标志
-- [填空29] 查询商品价格和库存
    SELECT
      point_price,
      stock INTO _______,
      v_product_stock 
    FROM
      products 
    WHERE
      product_id = p_product_id;
    IF
      v_not_found = 1 THEN
        ROLLBACK;
      
      SET p_status = - 3;
      
      SET p_message = '商品不存在';
      ELSE -- [填空30] 检查积分是否充足
      IF
        v_user_points < _______ THEN
          ROLLBACK;
        
        SET p_status = - 2;
        
        SET p_message = '积分不足';
        ELSE
        IF
          v_product_stock < 1 THEN
            ROLLBACK;
          
          SET p_status = - 3;
          
          SET p_message = '库存不足';
          ELSE -- 扣减积分
          UPDATE users 
          SET points = points - v_product_price 
          WHERE
            user_id = p_user_id;-- 扣减库存
          UPDATE products 
          SET stock = stock - 1 
          WHERE
            product_id = p_product_id;-- [填空31] 提交事务
          _______;
          
          SET p_status = 0;
          
          SET p_message = '兑换成功';
          
        END IF;
        
      END IF;
      
    END IF;
    
  END IF;
  
END $$delimiter;-- ----------------------------------------------------------------------------
-- 【难题10】游标综合应用（难度：⭐⭐⭐⭐⭐）
-- 考点：游标+事务+异常处理+批量更新
-- ----------------------------------------------------------------------------
/*
题目：批量处理逾期图书
要求：
1. 遍历所有逾期且未处理的借阅记录
2. 计算罚款（每天0.5元）并扣除用户余额
3. 标记图书和借阅记录状态
4. 返回处理的记录数量（失败返回-1）
*/

delimiter $$
CREATE PROCEDURE process_overdue_books ( OUT p_processed_count INT ) BEGIN
  DECLARE
    v_borrow_id INT;
  DECLARE
    v_user_id INT;
  DECLARE
    v_book_id INT;
  DECLARE
    v_days_overdue INT;
  DECLARE
    v_done INT DEFAULT 0;-- [填空32] 声明游标（查询逾期记录）
  DECLARE
    cur_overdue CURSOR FOR SELECT
    borrow_id,
    user_id,
    book_id,
    datediff( now(), due_date ) AS days_overdue 
  FROM
    borrows 
  WHERE
    due_date < now() 
    AND STATUS = 'borrowed';-- [填空33] 声明not found处理器
  DECLARE
    CONTINUE HANDLER FOR _______ 
    SET v_done = 1;
  DECLARE
  EXIT HANDLER FOR SQLEXCEPTION BEGIN
      ROLLBACK;
    
    SET p_processed_count = - 1;
    
  END;
  
  SET p_processed_count = 0;
  START TRANSACTION;-- [填空34] 打开游标
  _______ cur_overdue;-- [填空35] 开始循环
  read_loop : _______ -- [填空36] 读取一行数据
  _______ cur_overdue INTO v_borrow_id,
  v_user_id,
  v_book_id,
  v_days_overdue;-- [填空37] 检查是否读完
  IF
    v_done = 1 THEN
      _______ read_loop;-- 退出循环
    
  END IF;-- 计算罚款
  UPDATE users 
  SET balance = balance - ( v_days_overdue * 0.5 ) 
  WHERE
    user_id = v_user_id;-- 标记图书状态
  UPDATE books 
  SET STATUS = 'overdue' 
  WHERE
    book_id = v_book_id;-- 标记借阅记录
  UPDATE borrows 
  SET STATUS = 'overdue_processed' 
  WHERE
    borrow_id = v_borrow_id;
  
  SET p_processed_count = p_processed_count + 1;-- [填空38] 结束循环
  _______
  LOOP
      ;-- [填空39] 关闭游标
    _______ cur_overdue;
    COMMIT;
    
  END $$delimiter;-- ============================================================================
-- 第四部分：完整答案与详解
-- ============================================================================
/*
【基础题1答案】
[填空1] in
[填空2] in
[填空3] out
[填空4] out

解析：
- p_a和p_b是输入参数，使用in
- p_sum和p_diff是输出参数，使用out
- out参数在过程内部可以直接赋值
*/
/*
【基础题2答案】
[填空5] returns
[填空6] deterministic
[填空7] return

解析：
- returns（有s）用于声明返回类型
- deterministic表示相同输入产生相同输出（圆面积是确定的）
- return（无s）用于返回具体值
- ⚠️ 记忆技巧：有s声明，无s返回
*/
/*
【基础题3答案】
[填空8] continue, not found
[填空9] exit, sqlexception

解析：
- 查询不到用户时，使用continue handler继续执行（设置默认值0）
- 系统错误时，使用exit handler立即退出
- not found专门处理select into无结果的情况
- sqlexception捕获所有sql错误
*/
/*
【中等题4答案】
[填空10] start transaction
[填空11] rollback（第一个空），commit（第二个空）

解析：
- start transaction开启事务
- rollback撤销所有数据库操作（扣款和入账）
- commit使操作永久生效
- ⚠️ 注意：rollback不会撤销变量赋值（set @var = ... ）
*/
/*
【中等题5答案】
[填空12] reads sql data
[填空13] not deterministic

解析：
- 函数中包含select查询，必须声明reads sql data
- 数据库中的成绩可能变化，所以是not deterministic
- 这两个特性可以同时使用
*/
/*
【中等题6答案】
[填空14] 23000
[填空15] v_constraint_error

解析：
- sqlstate '23000'专门捕获完整性约束违反错误
- 包括：主键重复、外键冲突、check约束失败、unique冲突
- ⚠️ 注意：错误码必须用引号（字符串），不能写成数字23000
- 使用continue handler继续执行，可以记录日志或设置状态
*/
/*
【中等题7答案】
[填空16] inout
[填空17] case
[填空18] end

解析：
- inout参数既可以输入又可以输出
- 这里输入分数字符串'85'，输出等级'良好'
- case表达式从上到下匹配，匹配到第一个为真的条件就返回
- ⚠️ 注意：case结束用end，不是end case
*/
/*
【难题8答案】
[填空19] cursor
[填空20] handler, not found
[填空21] open
[填空22] fetch
[填空23] leave
[填空24] close

解析：
游标五步走：
1. declare cursor声明游标
2. declare handler声明not found处理器
3. open打开游标（执行查询）
4. fetch读取一行数据（循环中调用）
5. close关闭游标（释放资源）

⚠️ 关键点：
- 游标声明必须在handler之前
- not found处理器必须用continue（不能用exit）
- fetch的变量顺序必须与select的列顺序一致
*/
/*
【难题9答案】
[填空25] int
[填空26] continue
[填空27] start
[填空28] v_not_found
[填空29] v_product_price
[填空30] v_product_price
[填空31] commit

解析：
这是一个完整的事务处理流程：
1. 声明变量接收查询结果
2. 使用not found处理器捕获查询失败
3. 开启事务保证原子性
4. 逐步验证业务条件（用户存在、积分充足、库存充足）
5. 任何条件不满足都要rollback并设置错误码
6. 所有条件满足后执行update并commit

⚠️ 重难点：
- 每次select into前要重置v_not_found = 0
- 使用嵌套if-else避免使用leave标签
- rollback后set语句仍会执行（用于返回错误信息）
*/
/*
【难题10答案】
[填空32] （已给出完整sql，无需填空）
[填空33] not found
[填空34] open
[填空35] loop
[填空36] fetch
[填空37] leave
[填空38] end
[填空39] close

解析：
这是游标+事务+批量处理的综合应用：
1. 游标查询所有需要处理的记录
2. 在事务中逐条处理
3. 每条记录执行3个update操作（扣款、标记图书、标记借阅）
4. 记录处理数量
5. 如果中途发生错误，exit handler会回滚所有操作

⚠️ 核心要点：
- 游标循环模式：fetch → 检查done → 处理数据
- 必须先fetch再检查v_done（否则会漏掉最后一行）
- close游标释放资源（虽然过程结束会自动关闭，但显式关闭是规范）
- 游标中的update操作在同一个事务中，要么全部成功，要么全部回滚
*/-- ============================================================================
-- 第五部分：易错点总结（考前必看）
-- ============================================================================
/*
【易错点总结表】
+------+----------------------+------------------------+------------------------+
| 编号 | 易错点               | 错误示例               | 正确写法               |
+------+----------------------+------------------------+------------------------+
| 1    | returns vs return    | return int             | returns int (声明)     |
|      |                      | begin returns x; end   | begin return x; end    |
+------+----------------------+------------------------+------------------------+
| 2    | out参数调用          | call proc(1, result);  | call proc(1, @result); |
+------+----------------------+------------------------+------------------------+
| 3    | 函数参数类型         | create function f(     | 函数只能有in参数       |
|      |                      |   out p int)           | （in可省略）           |
+------+----------------------+------------------------+------------------------+
| 4    | sqlstate格式         | sqlstate 23000         | sqlstate '23000'       |
|      |                      |                        | （必须用引号）         |
+------+----------------------+------------------------+------------------------+
| 5    | 游标handler类型      | declare exit handler   | declare continue       |
|      |                      | for not found          | handler for not found  |
+------+----------------------+------------------------+------------------------+
| 6    | case结束             | case ...  end case      | case ... end           |
|      |                      |                        | （不是end case）       |
+------+----------------------+------------------------+------------------------+
| 7    | 声明顺序             | declare handler...      | 变量→游标→handler      |
|      |                      | declare cursor...      | →可执行语句            |
+------+----------------------+------------------------+------------------------+
| 8    | 游标fetch时机        | if done then...        | fetch先执行            |
|      |                      | fetch...                | 再检查done标志         |
+------+----------------------+------------------------+------------------------+
| 9    | rollback作用域       | rollback撤销set语句    | 只撤销dml操作          |
|      |                      |                        | （update/insert等）    |
+------+----------------------+------------------------+------------------------+
| 10   | 函数特性组合         | deterministic不能与    | 可以同时使用           |
|      |                      | reads sql data共存     | （没有冲突）           |
+------+----------------------+------------------------+------------------------+
*/
/*
【快速记忆口诀】
1. 有s声明，无s返回（returns vs return）
2. 函数只in，过程三种（in/out/inout）
3. exit立退，continue继续
4. 游标必continue，系统用exit
5. 变量游标处理器，顺序不能乱
6. fetch在前，检查在后
7. 事务只撤dml，变量不回滚
8. 23000约束错，引号不能忘
*/
/*
【考试时间分配建议】
- 看题审题：2分钟（明确要求：in/out/inout、函数/过程）
- 填关键词：3分钟（先填简单的：in/out/returns/return）
- 填逻辑词：5分钟（事务控制、异常处理）
- 检查语法：2分钟（引号、顺序、拼写）
总计：12分钟/题
*/
/*
【检查清单】
□ returns有没有s？
□ return有没有s？
□ out参数调用时有没有@？
□ sqlstate有没有引号？
□ 游标not found用的continue还是exit？
□ case结束是end还是end case？
□ 声明顺序对不对？（变量→游标→handler）
□ 事务有没有commit/rollback？
□ 游标有没有close？
□ 函数有没有return语句？
*/-- ============================================================================
-- 附录：完整可运行示例（供测试用）
-- ============================================================================
-- 创建测试表
CREATE TABLE
IF
  NOT EXISTS accounts ( id INT PRIMARY KEY, balance DECIMAL ( 10, 2 ) );
CREATE TABLE
IF
  NOT EXISTS users ( user_id INT PRIMARY KEY, points INT, balance DECIMAL ( 10, 2 ) );
CREATE TABLE
IF
  NOT EXISTS products ( product_id INT PRIMARY KEY, stock INT, point_price INT );-- 插入测试数据
INSERT INTO accounts
VALUES
  ( 1, 1000.00 ),
  ( 2, 500.00 );
INSERT INTO users
VALUES
  ( 1, 5000, 1000.00 ),
  ( 2, 200, 500.00 );
INSERT INTO products
VALUES
  ( 1, 10, 300 ),
  ( 2, 0, 500 );-- 测试转账存储过程
CALL transfer_money ( 1, 2, 100, @result );
SELECT
  @result;-- 测试积分兑换存储过程
CALL exchange_product ( 1, 1, @STATUS, @msg );
SELECT
  @STATUS,
  @msg;-- ============================================================================
-- 结束语
-- ============================================================================
/*
复习完成检查表：
□ 已掌握存储过程三种参数类型（in/out/inout）
□ 已掌握存储函数特性声明（deterministic/reads sql data等）
□ 已掌握异常处理器类型（exit/continue）
□ 已掌握异常类型（sqlexception/not found/sqlstate）
□ 已掌握事务控制（start transaction/commit/rollback）
□ 已掌握游标五步走（declare/open/fetch/loop/close）
□ 已完成10道填空题练习
□ 已阅读易错点总结

预计掌握程度：_____%
需要重点复习的部分：__________

祝考试顺利！🎉
*/