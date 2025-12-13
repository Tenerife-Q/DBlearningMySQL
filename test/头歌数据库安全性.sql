-- =================================================================================================================
-- =================================================================================================================
/*第1关: 权限赋值：表
	创建用户cuit，密码123456。现有数据表books，booktype，将select,insert权限赋给创建的用户。
    注意：在实际生产环境或区块链节点数据库中，应限制host为'localhost'或特定IP以减少攻击面。
*/
-- 创建用户cuit，密码123456
CREATE USER 'cuit'@'localhost' IDENTIFIED BY '123456';

-- 为用户cuit分配books表的select和insert权限
GRANT SELECT, INSERT ON books TO 'cuit'@'localhost';

-- 为用户cuit分配booktype表的select和insert权限
GRANT SELECT, INSERT ON booktype TO 'cuit'@'localhost';


-- =================================================================================================================
/*第2关: 权限收回：表
	本关任务：创建用户cuit，密码123456。现有数据表books(cBookID char(10),mSalePrice decimal,cTypeID char(5))，将所有权限赋给用户cuit。然后收回insert 权限。
*/
-- 创建用户cuit，密码123456
-- 若用户已存在，需先 DROP USER 'cuit'@'localhost';
CREATE USER 'cuit'@'localhost' IDENTIFIED BY '123456';

-- 授予用户cuit对books表的所有权限
GRANT ALL PRIVILEGES ON books TO 'cuit'@'localhost';

-- 收回用户cuit对books表的INSERT权限
REVOKE INSERT ON books FROM 'cuit'@'localhost';


-- =================================================================================================================
/*第3关: 权限赋予：属性 (列级权限)
	本关任务：创建用户cuit，密码123456。现有数据表books和booktype，将books所有属性的select权限赋给用户cuit，
    将booktype中cTypeID的select权限赋给用户cuit，vTypeName的select 和update权限赋给用户cuit。
    注：列级权限控制提供了更细粒度的安全管理。
*/

-- 创建用户cuit，密码123456
CREATE USER 'cuit'@'localhost' IDENTIFIED BY '123456';

-- 授予用户cuit对books表所有属性的select权限
GRANT SELECT ON books TO 'cuit'@'localhost';

-- 授予用户cuit对booktype表中cTypeID的select权限
GRANT SELECT(cTypeID) ON booktype TO 'cuit'@'localhost';

-- 授予用户cuit对booktype表中vTypeName的select和update权限
GRANT SELECT(vTypeName), UPDATE(vTypeName) ON booktype TO 'cuit'@'localhost';


-- =================================================================================================================
/*第4关: 权限收回：属性
	本关任务：现有用户cuit，密码123456。
	现有数据表books，books属性cTypeID的select,update已经赋给用户cuit，将select,update权限赋给cBookID、mSalePrice，然后去除cuit对于表books的cTypeID的update权限。
	为用户cuit授予books表中cBookID和mSalePrice的select、update权限
*/

-- 授予 cBookID 和 mSalePrice 的 select, update 权限
GRANT SELECT(cBookID, mSalePrice), UPDATE(cBookID, mSalePrice) ON books TO 'cuit'@'localhost';

-- 收回用户cuit对books表中cTypeID的update权限
-- 注意：REVOKE 列级权限时，必须精准匹配该列
REVOKE UPDATE(cTypeID) ON books FROM 'cuit'@'localhost';


-- =================================================================================================================
-- 第5关: 级联权限赋予
-- 本关任务：创建用户cuit和cuit2，密码123456。现有数据表books，将select，insert，update权限（可传递权限）赋给用户cuit。
-- 解析：WITH GRANT OPTION 允许用户将自己拥有的权限转授给其他人，这类似于区块链中的多签钱包或代理授权，需谨慎使用。

-- 创建用户cuit和cuit2，密码123456
CREATE USER 'cuit'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'cuit2'@'localhost' IDENTIFIED BY '123456';

-- 为用户cuit授予books表的select、insert、update权限，并允许其传递权限（WITH GRANT OPTION）
GRANT SELECT, INSERT, UPDATE ON books TO 'cuit'@'localhost' WITH GRANT OPTION;

-- 刷新权限使设置生效（如需）
FLUSH PRIVILEGES;


-- =================================================================================================================
/*第6关: 视图权限
	本关任务：创建用户cuit，密码123456。
	现有数据表books。创建视图Book_Price(cBookID,vBookName,mSalePrice,cTypeID)，将所有属性的select，属性mSalePrice的update权限赋给用户cuit。
    注：视图（View）通过隐藏底层表结构提供了一层抽象安全性。
*/

-- 创建用户cuit，密码123456
CREATE USER 'cuit'@'localhost' IDENTIFIED BY '123456';

-- 创建视图Book_Price，包含指定属性
-- 假设 books 表包含 vBookName 字段，虽然第2关描述未提及，但视图定义需要它
CREATE OR REPLACE VIEW Book_Price AS 
SELECT cBookID, vBookName, mSalePrice, cTypeID 
FROM books;

-- 授予用户cuit对视图Book_Price所有属性的select权限
GRANT SELECT ON Book_Price TO 'cuit'@'localhost';

-- 授予用户cuit对视图Book_Price中mSalePrice属性的update权限
GRANT UPDATE(mSalePrice) ON Book_Price TO 'cuit'@'localhost';