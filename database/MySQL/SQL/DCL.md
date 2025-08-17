# DCL（Data Control Language，数据控制语言)
管理数据库用户，控制数据库的访问权限，**账户/角色管理**与**权限授予/收回**。

# 1) 对象与层级

## 账户与角色

- **用户账户**：`'user'@'host'`（`host` 可限制来源，如 `localhost`、内网段或 `%`）。
    
- **角色（ROLE）**：权限的“集合”。先给角色授权，再把角色赋给用户，便于管理。
    
## 权限层级（从粗到细）

- 全局：`*.*`
    
- 库级：`db.*`
    
- 表级：`db.tbl`
    
- **列级**：`db.tbl (col1, col2)`
    
- 例程级：`PROCEDURE db.p` / `FUNCTION db.f`
    
- 其他对象：`EVENT`、`TRIGGER`、`VIEW` 等
---
```sql
-- 查询用户
USE mysql;
SELECT * FROM user;
```
# 2) 用户生命周期
```sql
-- 创建用户（8.0 推荐 CREATE USER，不再用 GRANT 隐式建用户）
CREATE USER 'app_rw'@'10.0.%' IDENTIFIED BY 'Strong#Pass123';

-- 修改口令 / 认证插件 / 账户属性
ALTER USER 'app_rw'@'10.0.%' IDENTIFIED BY 'New#Pass123';
ALTER USER 'app_rw'@'10.0.%' ACCOUNT LOCK;   -- 锁定
ALTER USER 'app_rw'@'10.0.%' ACCOUNT UNLOCK; -- 解锁

-- 密码策略（示例：过期、失败登录锁定）
ALTER USER 'app_rw'@'10.0.%' PASSWORD EXPIRE INTERVAL 90 DAY;
ALTER USER 'app_rw'@'10.0.%'
  FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 2; -- 锁2天

-- TLS 安全要求（强制走加密连接）
ALTER USER 'app_rw'@'10.0.%' REQUIRE SSL;

-- 删除/改名
DROP USER 'app_rw'@'10.0.%';
RENAME USER 'old'@'%' TO 'new'@'%';

````

>  备注：MySQL 8.0 默认认证插件多为 `caching_sha2_password`；老客户端不兼容时才考虑`mysql_native_password`。
---
## 3) GRANT：授予权限
```sql
-- 库级读写
GRANT SELECT, INSERT, UPDATE, DELETE
ON mydb.* TO 'app_rw'@'10.0.%';

-- 表级只读
GRANT SELECT
ON mydb.orders TO 'analyst'@'%';

-- 列级（只允许查 id、name 两列）
GRANT SELECT (id, name)
ON mydb.user TO 'limited'@'%';

-- 视图/例程/事件/触发器
GRANT SHOW VIEW ON mydb.* TO 'dev'@'%';
GRANT EXECUTE ON PROCEDURE mydb.p_sync TO 'worker'@'%';
GRANT EVENT   ON mydb.* TO 'scheduler'@'%';
GRANT TRIGGER ON mydb.* TO 'etl'@'%';

-- WITH GRANT OPTION：允许再转授（谨慎）
GRANT SELECT ON mydb.* TO 'lead'@'%' WITH GRANT OPTION;

```

常见权限名（节选）：
`SELECT/INSERT/UPDATE/DELETE`、`CREATE/DROP/ALTER/INDEX`、  
`CREATE TEMPORARY TABLES`、`REFERENCES`、`CREATE VIEW/SHOW VIEW`、  
`TRIGGER`、`EVENT`、`EXECUTE`

以及全局类：`PROCESS`、`RELOAD`、`FILE`、`REPLICATION CLIENT`、`REPLICATION SLAVE`（8.0 也接受 `REPLICATION REPLICA` 同义）


**查看已授予**
```sql
`SHOW GRANTS FOR 'app_rw'@'10.0.%'; SHOW GRANTS;  -- 查看当前会话`
```
---
## 4) REVOKE：收回权限

```sql
-- 回收特定权限
REVOKE INSERT, UPDATE ON mydb.* FROM 'app_rw'@'10.0.%';

-- 回收再转授能力
REVOKE GRANT OPTION ON mydb.* FROM 'lead'@'%';

-- 回收所有权限与转授
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'user'@'%';

```
---
## 5) 角色（推荐用法）

```sql
-- 创建角色并赋权
CREATE ROLE 'role_reader', 'role_writer';

GRANT SELECT ON mydb.* TO 'role_reader';
GRANT INSERT, UPDATE, DELETE ON mydb.* TO 'role_writer';

-- 角色分配给用户
GRANT 'role_reader', 'role_writer' TO 'app_rw'@'10.0.%';

-- 默认启用哪些角色
SET DEFAULT ROLE 'role_reader', 'role_writer' TO 'app_rw'@'10.0.%';

-- 会话中切换角色（调试/临时）
SET ROLE 'role_reader';   -- 或 SET ROLE ALL / NONE

-- 角色也能带 ADMIN OPTION（可转授角色本身）
GRANT 'role_reader' TO 'lead'@'%' WITH ADMIN OPTION;

-- 删除角色（先确保没人依赖）
DROP ROLE 'role_writer';

```
---
# 6) 代理用户 / DEFINER / 安全模式

- **PROXY 用户**：让 A 以 B 的身份执行（常用于网关/中间件账户）：
    
 ```sql
    GRANT PROXY ON 'target'@'%' TO 'proxy'@'10.0.%';
 ```
    
- **SQL SECURITY**：
    
    - 视图/例程可声明 `SQL SECURITY DEFINER|INVOKER`
        
    - **DEFINER**：按创建者权限跑（需要谨慎、配合 `DEFINER` 账户的受控权限）
        
    - **INVOKER**：按调用者权限跑（更贴合最小权限）
        

---

# 7) 资源配额（限流/配额控制）

```sql
GRANT SELECT ON mydb.* TO 'report'@'%'   WITH MAX_QUERIES_PER_HOUR 3600        MAX_CONNECTIONS_PER_HOUR 300        MAX_USER_CONNECTIONS 20;
```

---

# 8) 实战建议（最小权限 & 审计）

1. **最小权限**：精确到库/表/列；读写分离账户。
    
2. **限制来源**：`'user'@'固定网段/主机'`，能内网就不放 `%`。
    
3. **强制加密**：`REQUIRE SSL`；为服务端配好 TLS 证书。
    
4. **用角色** 管理应用/团队权限，少对个人直授。
    
5. **谨慎 GRANT OPTION / ADMIN OPTION**，避免权限蔓延。
    
6. **定期巡检**：`SHOW GRANTS FOR ...`，脚本比对与审计。
    
7. **密码与锁定策略**：过期、复杂度、失败锁定、旋转。
    
8. **避免 root** 常用；只在初始化/运维时临时使用。
    

---

# 9) 常见坑

- **GRANT 不再建用户**（8.0）：先 `CREATE USER` 再 `GRANT`。
    
- 用 `%` 作为 host 太宽松；连接匹配是**最精确优先**，可能连到你没想到的用户条目。
    
- 列级授权后忘了给表级 `SELECT`：列级即可查询那几列，但执行时仍需满足实际访问列。
    
- 直接改 `mysql.*` 表导致权限异常；应使用 DCL 语句。
    

---

# 10) 一套示例（可直接参考）

```sql
-- 1. 建账户，强制 SSL
CREATE USER 'app_rw'@'10.0.%' IDENTIFIED BY 'Strong#Pass123' REQUIRE SSL;

-- 2. 建角色并授权
CREATE ROLE 'role_app_reader', 'role_app_writer';
GRANT SELECT ON mydb.* TO 'role_app_reader';
GRANT INSERT, UPDATE, DELETE ON mydb.* TO 'role_app_writer';

-- 3. 把角色分给账户并设默认启用
GRANT 'role_app_reader', 'role_app_writer' TO 'app_rw'@'10.0.%';
SET DEFAULT ROLE 'role_app_reader','role_app_writer' TO 'app_rw'@'10.0.%';

-- 4. 查看最终权限
SHOW GRANTS FOR 'app_rw'@'10.0.%';

```