-- 一、核心系统变量查询（@@变量名 格式）
SELECT @@VERSION;	-- 返回数据库版本
SELECT @@SERVER_ID;	-- 获取当前 MySQL 服务器的唯一 ID（主从复制中核心参数）
SELECT @@HOSTNAME;	-- 获取 MySQL 服务器运行的主机名
SELECT @@PORT;	-- 获取 MySQL 服务监听的端口号（默认 3306）
SELECT @@DATADIR;	-- 获取 MySQL 数据文件存储目录（如 /var/lib/mysql/）
SELECT @@BASEDIR;	-- 获取 MySQL 安装目录（如 /usr/local/mysql/）
SELECT @@COLLATION_SERVER;	-- 获取服务器默认排序规则（如 utf8mb4_general_ci）
SELECT @@MAX_CONNECTIONS;	-- 获取最大允许的并发连接数
SELECT @@WAIT_TIMEOUT;	-- 获取非交互连接的超时时间（秒，默认 28800，即 8 小时）
SELECT @@INTERACTIVE_TIMEOUT;	-- 获取交互连接（如 Navicat）的超时时间（秒）
SELECT @@SQL_MODE;	-- 获取当前生效的 SQL 模式（如 ONLY_FULL_GROUP_BY、STRICT_TRANS_TABLES 等）
SELECT @@TIME_ZONE;	-- 获取 MySQL 服务器的时区（如 SYSTEM 表示跟随系统时区，+08:00 表示东八区）

-- 二、系统函数查询（补充常用信息，语法类似 “查询系统值”）
SELECT CURRENT_DATE();	-- 获取当前服务器日期（格式：YYYY-MM-DD）
SELECT CURRENT_TIME();	-- 获取当前服务器时间（格式：HH:MM:SS）
SELECT CURRENT_TIMESTAMP();	-- 获取当前服务器日期时间（格式：YYYY-MM-DD HH:MM:SS），等价于 NOW()
SELECT USER();	-- 获取当前登录的 MySQL 用户名 + 主机（如 root@localhost）
SELECT DATABASE();	-- 获取当前正在使用的数据库名（若未切换数据库则返回 NULL）
SELECT VERSION();	-- 等价于 @@VERSION，直接返回数据库版本（函数形式，更直观）
SELECT CONNECTION_ID();	-- 获取当前会话的连接 ID（可用于查看连接状态：SHOW PROCESSLIST）
SELECT @@GLOBAL.VERSION;	-- 区分全局变量（GLOBAL）和会话变量（SESSION），获取全局版本（默认会话级）
SELECT @@SESSION.SQL_MODE;	-- 获取当前会话的 SQL 模式（会话级可能覆盖全局级）

-- 三、批量查询系统变量（一次性查看多个信息）
SELECT
  @@VERSION AS 数据库版本,
  @@HOSTNAME AS 服务器主机名,
  @@PORT AS 监听端口,
  @@DATADIR AS 数据目录,
  USER() AS 当前登录用户,
  DATABASE() AS 当前数据库,
  CURRENT_TIMESTAMP() AS 服务器时间;

SELECT
  @name AS 姓名,
  @age AS 年龄; 
	
/***************************************************************************/
	
-- 在 MySQL 中，用户变量（会话级变量，仅当前连接生效）的创建和赋值有两种核心语法，变量名需以 @ 开头（区分系统变量）。
-- 以下是具体用法，以变量 name 为例：

-- 一、基础赋值语法（2 种常用方式）
-- 1. 直接赋值（= 或 := 均可，推荐 := 避免歧义）
-- 方式1：使用 := 赋值（推荐，可在 SELECT/UPDATE 等语句中通用，避免与比较运算符 = 混淆）
SET @name := '张三';
SELECT @name;   -- 查看 @name 的值

-- 方式2：使用 = 赋值（仅在 SET 语句中可用，其他场景可能被解析为比较）
SET @name = '李四';
SELECT @name;   -- 查看 @name 的值

-- 2. 从查询结果赋值（仅支持 :=）
-- 如果需要将查询结果赋值给 name（例如从表中查询用户名），用以下语法：
-- 场景1：查询单个值赋值（确保查询结果只有1行1列）
SELECT Sname INTO @name FROM student WHERE sno = '200215121';
SELECT @name;   -- 查看 @name 的值

-- 场景2：直接在 SELECT 中赋值（等价于上面的 INTO 语法）
SELECT @name := Sname FROM student WHERE sno = '200215121' LIMIT 1;
SELECT @name;   -- 查看 @name 的值

-- 四、注意事项
-- 变量名区分大小写吗？MySQL 中用户变量名 不区分大小写（@name 和 @NAME 是同一个变量），但建议统一大小写风格。
-- 与局部变量的区别？不要混淆「用户变量」和「存储过程 / 函数中的局部变量」：
-- 用户变量：@name，无需声明，会话级生效；
-- 局部变量：DECLARE name VARCHAR(20);，需在存储程序中声明，仅程序内生效。

-- 查询返回多行
SELECT @name := Sname FROM student;
SELECT @name;

-- 取第一条结果
SELECT @name := Sname FROM student LIMIT 1;
SELECT @name;

-- 正确：取用户名的最大值（聚合为单行）
SELECT @age := MAX(Sage) FROM student;
SELECT @age;

/***************************************************************************/

-- 【例1】 创建用户变量name并赋值为“王林”。
SET @name='王林';
SELECT @name;

-- 【例2】 创建用户变量user1并赋值为1，user2赋值为2，user3赋值为3。
SET @user1=1, @user2=2, @user3=3;
SELECT @user1;

-- 【例3】 创建用户变量user4，它的值为user3的值加1。
SET @user4=@user3+1;
SELECT @user4;

-- 【例4】 创建并查询用户变量name的值。
SET @name='王林';     
SELECT @name;

-- 【例5】查询book表中图书编号为Ts.3035的书名，并存储在变量b_name中。
SET @b_name=(SELECT 书名 FROM book WHERE 图书编号='Ts.3035');

-- 查询Book表中名字等于@b_name值的图书信息。
SELECT * FROM Book  WHERE 书名=@b_name; 


-- 【例6】 获得现在使用的MySQL版本。
SELECT @@VERSION ;

-- 【例7】获得系统当前时间。
SELECT CURRENT_TIME;

-- =================================================================================================================
-- 【例8】 创建存储过程，判断两个输入的参数哪一个更大。
-- =================================================================================================================
DELIMITER //
drop PROCEDURE if EXISTS COMPAR;
CREATE PROCEDURE COMPAR
(IN K1 INTEGER, IN K2 INTEGER, OUT K3 CHAR(6) )
BEGIN
		IF K1>K2 THEN
					SET K3= '大于';
		ELSEIF K1=K2 THEN
					SET K3= '等于';
		ELSE 
				SET K3= '小于';
	 END IF;
END //
DELIMITER;

-- 测试
-- 1. 基础调用（直接查看结果）
-- 1. 调用存储过程：比较 10 和 5，用 @result 接收输出结果 K3
CALL COMPAR(10, 5, @result);
-- 2. 查看输出结果（@result 中存储的是 K3 的值）
SELECT @result AS 比较结果;

-- 2. 不同场景测试示例
-- 场景1：K1 > K2（10 > 5）
CALL COMPAR(10, 5, @result);
SELECT @result; -- 输出：大于

-- 场景2：K1 = K2（8 = 8）
CALL COMPAR(8, 8, @result);
SELECT @result; -- 输出：等于

-- 场景3：K1 < K2（3 < 15）
CALL COMPAR(3, 15, @result);
SELECT @result; -- 输出：小于


-- 3. 在 SQL 脚本中复用变量
-- 多次调用，复用 @result 变量
CALL COMPAR(20, 20, @result);
SELECT '20和20的关系：' || @result AS 结果; -- 输出：20和20的关系：等于

CALL COMPAR(7, 12, @result);
SELECT CONCAT('7和12的关系：', @result) AS 结果; -- 输出：7和12的关系：小于


-- =================================================================================================================
-- 【例9】 创建一个存储过程，当给定参数为Ｕ时返回“上升”，给定参数为Ｄ时返回“下降”，给定其他参数时返回“不变”。
-- =================================================================================================================
DELIMITER //
drop PROCEDURE if EXISTS var_cp;
CREATE PROCEDURE var_cp
   (IN str VARCHAR(1), OUT direct VARCHAR(4) )
     BEGIN
				CASE str
				WHEN 'U' THEN SET direct ='上升';
				WHEN 'D' THEN SET direct ='下降';
				ELSE  SET direct ='不变';
		 END CASE;
		 
END //
DELIMITER ; 


-- 测试
-- 1. 测试输入 'U'（预期输出：上升）
CALL var_cp('U', @direct_result); -- 传入 'U'，用变量 @direct_result 接收输出
SELECT '输入字符：U' AS 测试场景, @direct_result AS 输出结果; -- 查看结果

-- 2. 测试输入 'D'（预期输出：下降）
CALL var_cp('D', @direct_result); -- 复用变量，无需重新定义
SELECT '输入字符：D' AS 测试场景, @direct_result AS 输出结果;

-- 3. 测试输入非 'U'/'D' 的单个字符（预期输出：不变）
CALL var_cp('A', @direct_result); -- 输入 'A'
SELECT '输入字符：A' AS 测试场景, @direct_result AS 输出结果;

-- 4. 测试输入数字字符（预期输出：不变）
CALL var_cp('5', @direct_result); -- 输入 '5'
SELECT '输入字符：5' AS 测试场景, @direct_result AS 输出结果;

-- 5. 测试输入空格字符（预期输出：不变）
CALL var_cp(' ', @direct_result); -- 输入空格（单个字符，符合 VARCHAR(1) 类型）
SELECT '输入字符：空格' AS 测试场景, @direct_result AS 输出结果;

-- 6. 测试输入空值（NULL，预期输出：不变）
CALL var_cp(NULL, @direct_result); -- 输入 NULL（IN 参数允许为空）
SELECT '输入字符：NULL' AS 测试场景, @direct_result AS 输出结果;


-- =================================================================================================================
-- 【例】用LOOP语句创建一个循环。
-- =================================================================================================================
DELIMITER //
-- 1. 删除已存在的存储过程（避免冲突）
DROP PROCEDURE IF EXISTS doloop;
-- 2. 创建修正后的存储过程
CREATE PROCEDURE doloop()
BEGIN
    -- 声明局部变量 a（INT 类型，初始值 10）
    DECLARE a INT DEFAULT 10;
    
    Label: LOOP
        SET a = a - 1; -- 每次循环 a 减 1        
        -- 循环终止条件：a < 0 时退出循环
        IF a < 0 THEN
            LEAVE Label;
        END IF;
    END LOOP Label;
    
    -- 打印最终结果（验证循环执行效果）
    SELECT '循环结束后 a 的值：' AS 提示, a AS 结果;
END //

-- 3. 恢复默认分隔符
DELIMITER ;

-- 4. 调用存储过程测试
CALL doloop();

-- 调用 CALL doloop(); 后，会输出如下结果：
-- 提示	结果
-- 循环结束后 a 的值：	-1


-- -------------------------------------------------------------------------------------------
-- 扩展：如果需要查看循环过程
-- 该版本会依次输出 a = 9、a = 8、...、a = -1，最后显示最终结果，便于调试循环逻辑。
DELIMITER //
DROP PROCEDURE IF EXISTS doloop_with_log;
CREATE PROCEDURE doloop_with_log()
BEGIN
    DECLARE a INT DEFAULT 10;
    
    Label: LOOP
        SET a = a - 1;
        -- 打印每次循环的 a 值
        SELECT CONCAT('循环中：a = ', a) AS 循环日志;
        
        IF a < 0 THEN
            LEAVE Label;
        END IF;
    END LOOP Label;
    
    SELECT '循环结束' AS 提示, a AS 最终结果;
END //
DELIMITER ;

-- 测试带日志的版本
CALL doloop_with_log();

-- -------------------------------------------------------------------------------------------

/*
  什么时候用存储函数，什么时候用存储过程？什么时候用触发器？什么时候用游标

在MySQL中，存储函数、存储过程、触发器、游标 是不同的数据库对象，核心区别在于「使用场景、返回值、触发方式」，
选择时需结合业务需求（如是否需要返回值、是否自动执行、是否处理批量数据等）。
以下是清晰的适用场景划分，附通俗示例和对比：

一、存储函数（FUNCTION）：有返回值的 “计算工具”
核心特点：
		必须有 返回值（单个值，如数字、字符串），不能返回结果集；
		可直接嵌入 SELECT/WHERE 等语句中使用（像内置函数一样）；
		不能有 OUT/INOUT 参数，只能用 IN 参数（或无参数）；
		执行权限要求较低，语法更简洁。
什么时候用？
		当你需要 封装一个 “计算逻辑”，且只需返回单个结果，希望像用 SUM()/CONCAT() 一样直接调用时。
典型场景：
		数据转换（如手机号脱敏、日期格式化）；
		业务计算（如税费计算、评分换算）；
		简单判断（如判断用户等级、数据是否合法）。
*/

-- 示例：创建一个 “计算商品折扣价” 的存储函数，直接在查询中使用：
-- 创建存储函数：原价 * 折扣（折扣为 0-1 之间的数）
CREATE FUNCTION calc_discount(original_price DECIMAL(10,2), discount DECIMAL(3,2)) 
RETURNS DECIMAL(10,2)
DETERMINISTIC -- 相同输入返回相同结果（优化标记）
BEGIN
    RETURN original_price * discount;
END //

-- 直接嵌入 SELECT 中使用（像内置函数一样）
SELECT goods_name, original_price, calc_discount(original_price, 0.8) AS discount_price 
FROM goods;

/*
二、存储过程（PROCEDURE）：无返回值的 “业务流程容器”
核心特点：
		可以没有返回值，也可以通过 OUT/INOUT 参数返回多个结果；
		支持复杂逻辑（分支、循环、事务、调用其他存储过程 / 函数）；
		不能嵌入 SELECT 语句，必须用 CALL 单独调用；
		可操作数据（增删改查），适合封装完整业务流程。
什么时候用？
		当你需要 封装一个 “完整业务流程”（多步操作、事务控制），或需要返回多个结果、执行批量操作时。
典型场景：
		多步业务操作（如用户注册：插入用户表 + 插入用户角色表 + 记录日志）；
		批量处理数据（如批量更新订单状态、批量导入数据）；
		带事务的操作（如转账：扣减 A 账户 + 增加 B 账户，需原子性）；
		需要返回多个结果（如同时返回用户信息、订单数、余额）。
*/

-- 示例：创建一个 “用户注册” 的存储过程（多表插入 + 事务控制）：
-- 创建存储过程：用户注册（插入用户表 + 记录日志，事务回滚）
CREATE PROCEDURE user_register(
    IN username VARCHAR(50),
    IN password VARCHAR(50),
    OUT result INT -- 0=失败，1=成功
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION -- 异常处理：出错回滚
    BEGIN
        ROLLBACK;
        SET result = 0;
    END;

    START TRANSACTION; -- 开启事务
    -- 步骤1：插入用户表
    INSERT INTO users(username, password) VALUES(username, password);
    -- 步骤2：插入注册日志
    INSERT INTO register_log(username, create_time) VALUES(username, NOW());
    COMMIT; -- 提交事务
    SET result = 1;
END //

-- 调用存储过程
CALL user_register('zhangsan', '123456', @res);
SELECT @res AS 注册结果; -- 1=成功，0=失败


/*
三、触发器（TRIGGER）：自动执行的 “事件响应器”
核心特点：
		无需手动调用，由特定事件自动触发（如 INSERT/UPDATE/DELETE 操作）；
		触发时机：BEFORE（操作前）或 AFTER（操作后）；
		不能有参数，也不能直接返回值；
		通常用于 “数据校验、自动填充、日志记录、关联数据同步”。
什么时候用？
		当你需要 在数据发生变化时，自动执行某个逻辑（无需人工干预）。
典型场景：
		数据校验（如插入订单时，校验商品库存是否充足）；
		自动填充字段（如插入数据时，自动填充 create_time/update_time）；
		日志记录（如更新用户信息后，自动记录修改前的旧值）；
		关联数据同步（如删除用户时，自动删除其关联的订单、评论）。
*/

-- 示例：创建一个 “插入订单时，自动扣减商品库存” 的触发器：
-- 创建触发器：插入订单后（AFTER INSERT），扣减对应商品库存
CREATE TRIGGER trig_order_deduct_stock
AFTER INSERT ON orders
FOR EACH ROW -- 行级触发器：每插入一条订单，执行一次
BEGIN
    -- NEW 表示插入的新订单记录（NEW.goods_id = 新订单的商品ID，NEW.num = 购买数量）
    UPDATE goods 
    SET stock = stock - NEW.num 
    WHERE id = NEW.goods_id;
END //

-- 插入订单时，触发器自动执行（无需手动调用）
INSERT INTO orders(goods_id, num, user_id) VALUES(1, 2, 1001);
-- 此时 goods 表中 id=1 的商品库存已自动减 2

/*
四、游标（CURSOR）：遍历结果集的 “指针”
核心特点：
		用于 逐行遍历查询结果集（MySQL 存储过程 / 函数中不支持直接遍历结果集，需用游标）；
		只能在存储过程 / 函数中使用，不能单独使用；
		适合处理 “批量单行操作”（如逐行更新数据、逐行生成报表）；
		效率较低（逐行处理），非必要不使用。
什么时候用？
		当你需要 在存储过程 / 函数中，逐行处理查询结果（如批量更新、逐行计算、数据迁移），且无法用 UPDATE/DELETE 批量实现时。
典型场景：
		批量数据修正（如逐行检查用户手机号格式，不合法则标记）；
		逐行生成复杂报表（如遍历订单表，计算每个用户的总消费）；
		数据迁移（如从旧表逐行读取数据，处理后插入新表）。
*/

-- 示例：创建一个 “遍历订单表，计算每个用户总消费” 的存储过程（用游标）：
-- 创建存储过程：用游标遍历订单，计算用户总消费
CREATE PROCEDURE calc_user_total_consume()
BEGIN
    DECLARE done INT DEFAULT 0; -- 游标结束标记
    DECLARE uid INT; -- 存储用户ID
    DECLARE amount DECIMAL(10,2); -- 存储单条订单金额
    DECLARE total DECIMAL(10,2) DEFAULT 0; -- 存储用户总消费

    -- 1. 定义游标：查询所有订单的用户ID和金额
    DECLARE order_cursor CURSOR FOR 
        SELECT user_id, order_amount FROM orders;

    -- 2. 定义游标结束处理：当游标遍历完，设置 done=1
    DECLARE EXIT HANDLER FOR NOT FOUND SET done = 1;

    -- 3. 打开游标
    OPEN order_cursor;

    -- 4. 循环遍历游标
    read_loop: LOOP
        FETCH order_cursor INTO uid, amount; -- 从游标读取一行数据到变量
        IF done = 1 THEN LEAVE read_loop; END IF; -- 遍历结束，退出循环
        SET total = total + amount; -- 累加总消费
    END LOOP read_loop;

    -- 5. 关闭游标
    CLOSE order_cursor;

    -- 6. 输出结果
    SELECT '所有用户总消费' AS 说明, total AS 总金额;
END //

-- 调用存储过程（游标在内部自动遍历）
CALL calc_user_total_consume();

/*
五、核心区别与选择决策表
	数据库对象	核心用途	返回值特点	触发方式	适用场景关键词
	存储函数	单个值计算 / 转换	必须返回单个值	嵌入 SELECT 调用	数据转换、业务计算、简单判断
	存储过程	完整业务流程 / 多步操作	无返回值或多参数返回	CALL 手动调用	多表操作、事务、批量处理
	触发器	数据变化时自动响应	无返回值	INSERT/UPDATE/DELETE 触发	数据校验、自动填充、日志
	游标	逐行遍历结果集	无返回值（内部处理）	存储过程 / 函数内使用	逐行处理、批量修正、报表
快速选择口诀：
		要 “计算单个值” 且想直接嵌入查询 → 存储函数；
		要 “多步业务 / 事务 / 批量操作” → 存储过程；
		要 “数据变化时自动做某事” → 触发器；
		要 “在存储过程中逐行处理数据” → 游标（尽量少用）。

六、避坑建议
	优先用 SQL 语句（UPDATE/DELETE 批量操作）代替游标，游标效率低；
	触发器不能写复杂逻辑（如事务、循环），否则会导致主操作（INSERT 等）变慢；
	存储函数不能修改表数据（如 INSERT/UPDATE），若需修改数据用存储过程；
	避免触发器嵌套（如触发器 A 触发 UPDATE，又触发触发器 B），容易造成死锁或逻辑混乱。

*/


