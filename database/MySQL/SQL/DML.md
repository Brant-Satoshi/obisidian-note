# DML（Data Manipulation Language，数据**操作**语言)

它负责对表里的**数据**进行增删改操作，典型语句有 `INSERT`、`UPDATE`、`DELETE`（有的教材也把 `SELECT` 归到 DQL；为了完整，我也简述下与事务相关的读法）。

## 1️⃣ INSERT（新增）

#### 基本用法

```sql
-- 单行 
INSERT INTO user(id, name, age) VALUES (1, 'Alice', 20);  
-- 多行 
INSERT INTO user(name, age) VALUES ('Bob', 18), ('Carol', 22);  
-- 全部 (需填充所有字段的值)
INSERT INTO user VALUES (1, 'Bob', 18, 'male'), (2, 'Carol', 22, 'female');  
-- 从查询插入 
INSERT INTO archive_user(id, name, age)
SELECT id, name, age FROM user WHERE age >= 30;
```
#### 常见变体
```sql
-- 忽略唯一键/外键冲突（失败的行被跳过）
INSERT IGNORE INTO user(id, name) VALUES (1, 'dup');

-- Upsert：主键/唯一键冲突则改为更新
INSERT INTO user(id, name, age) VALUES (1, 'Alice', 20)
ON DUPLICATE KEY UPDATE name = VALUES(name), age = VALUES(age);

-- REPLACE 会先删后插（触发删除再插入，可能丢失未在本次语句提供的列值）
REPLACE INTO user(id, name, age) VALUES (1, 'Zoe', 19);
```
#### 拿到新插入的主键

```sql
SELECT LAST_INSERT_ID();  -- 连接级别
```
---
## 2️⃣ UPDATE（修改）

### 基本用法

```sql
-- 一定加 WHERE！否则全表更新 
UPDATE user SET age = age + 1 WHERE id = 123;  
-- 限制条数（谨慎使用，常用于批处理分批改） 
UPDATE user SET flag = 1 WHERE flag = 0 ORDER BY id LIMIT 1000;
```

### 关联更新（多表）
```sql
UPDATE user u JOIN order_ o ON o.user_id = u.id SET u.last_order_at = o.created_at WHERE o.status = 'PAID';
```
### 原子自增/扣减 & 条件防并发
```sql
-- 余额扣减（仅余额充足才更新成功） 
UPDATE account SET balance = balance - 100 WHERE id = 1 AND balance >= 100; 
-- 受影响行数=1 表示扣款成功；=0 表示失败（并发安全）`
```


---

## 3️⃣ DELETE（删除）

#### 基本用法

```sql
DELETE FROM user WHERE id = 123;  
-- 分批删（大表清理避免长事务） 
DELETE FROM logs WHERE created_at < '2025-01-01' ORDER BY id LIMIT 10000;
```


### 多表删除（带 JOIN）
```sql
DELETE u FROM user u JOIN blacklist b ON b.user_id = u.id WHERE b.expired = 1;
```
