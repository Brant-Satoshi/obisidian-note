
# **DQL（Data Query Language，数据查询语言）** 

DQL 主要就是 **`SELECT`** 语句，它是用来**查询数据**的语言子集，不改数据、不改结构（改数据属于 DML，改结构属于 DDL）

## 1. 核心作用

- **只读**：从一个或多个表/视图中读取数据，不会修改数据本身。
    
- **组合数据**：可以做条件筛选、排序、分组、聚合、连接等操作。
    
- **数据来源**：表、视图、子查询、临时表、函数返回值等
---
## 2. 基本语法结构
```sql
SELECT [ALL | DISTINCT]
       字段列表 | 表达式 | 聚合函数
FROM   表名 [AS 别名]
[JOIN 连接类型 JOIN 表2 ON 条件 ...]
[WHERE 条件]
[GROUP BY 分组字段 [HAVING 分组后条件]]
[ORDER BY 排序字段 [ASC|DESC]]
[LIMIT 偏移量, 行数];
```

#### SQL 逻辑执行顺序（数据库处理顺序）

逻辑顺序是 MySQL 解析器在执行时的**概念步骤**

| 步骤  | 关键字        | 作用                    |
| --- | ---------- | --------------------- |
| 1   | `FROM`     | 确定要从哪些表取数据（包括子查询、临时表） |
| 2   | `ON`       | 执行连接条件（JOIN 时用）       |
| 3   | `JOIN`     | 根据连接条件组合数据            |
| 4   | `WHERE`    | 过滤行（不分组）              |
| 5   | `GROUP BY` | 分组                    |
| 6   | `HAVING`   | 过滤组（可以用聚合函数）          |
| 7   | `SELECT`   | 选择列、计算表达式             |
| 8   | `DISTINCT` | 去重                    |
| 9   | `ORDER BY` | 排序                    |
| 10  | `LIMIT`    | 取出指定范围的行              |
 **From-On-Join-Where-Group-Having-Select-Distinct-Order-Limit**  
（可以记成 "**F**oxes **O**ften **J**ump **W**hile **G**oats **H**op **S**ideways **D**uring **O**range **L**ights" 方便记忆 😄）
 
--- 
## 3.基本查询

```sql
-- 查询所有列
SELECT * FROM user;

-- 查询指定列
SELECT id, name, age FROM user;

-- 查询常量值
SELECT 'Hello World', 100, NOW();
```
---
## 4. 别名（AS）
```sql
-- 列别名
SELECT name AS username, age AS years FROM user;

-- 表别名（简化 JOIN）
SELECT u.id, o.id
FROM user u
JOIN orders o ON u.id = o.user_id;
```
## 5. 条件筛选（WHERE）
```sql
-- 基础条件
SELECT * FROM user WHERE age >= 18;

-- 逻辑运算
SELECT * FROM user WHERE age BETWEEN 18 AND 30;
SELECT * FROM user WHERE name LIKE 'A%';
SELECT * FROM user WHERE age IN (18, 20, 22);
SELECT * FROM user WHERE age IS NULL;
SELECT * FROM user WHERE (age > 30 AND gender = 'M') OR is_vip = 1;
```
📌 **注意**：`NULL` 比较必须用 `IS NULL` / `IS NOT NULL`，不能用 `=` 或 `!=`。

---
## 6. 排序（ORDER BY）

- ASC 升序（默认）
- DESC 降序
```sql
-- 升序 / 降序
SELECT * FROM user ORDER BY age;
SELECT * FROM user ORDER BY age ASC;
SELECT * FROM user ORDER BY age DESC, name ASC;

-- 用表达式排序
SELECT * FROM user ORDER BY LENGTH(name) DESC;
```

---
## 7.分页查询-限制返回行（LIMIT）
```sql
SELECT [字段列表] FROM [表名] LIMIT [起始索引],[查询记录数];
-- 前 10 行
SELECT * FROM user LIMIT 10;

-- 从第 11 行开始，取 10 行
SELECT * FROM user LIMIT 10 OFFSET 10;

-- 简写
SELECT * FROM user LIMIT 10, 10;
```
  
  📌 **Attention**：
  - 起始索引从 0 开始，起始索引 = （查询页码 - 1）* 每页记录数。
  - LIMIT 是MySQL 的方言，不同数据库不一样
  - 如果是查询第一页，起始索引可以省略
---
## 8. 去重（DISTINCT）

```sql
-- 去掉重复行
SELECT DISTINCT gender FROM user;

-- 去掉重复组合
SELECT DISTINCT gender, city FROM user;
```
---
## 9. 聚合函数（Aggregate Functions）

将一列数据作为一个整体，进行纵向计算

| 函数         | 作用           |
| ---------- | ------------ |
| COUNT(*)   | 统计行数（含 NULL） |
| COUNT(col) | 统计非 NULL 值数量 |
| SUM(col)   | 求和           |
| AVG(col)   | 平均值          |
| MAX(col)   | 最大值          |
| MIN(col)   | 最小值          |
```sql
SELECT COUNT(*) FROM user;
SELECT AVG(age) AS avg_age FROM user WHERE gender = 'F';
```
---
## 10. 分组（GROUP BY）和分组过滤（HAVING）

```sql
-- 按性别分组，统计人数 
SELECT gender, COUNT(*) AS cnt 
FROM user 
GROUP BY gender; 
-- 按城市分组，筛选人数大于 5 的城市 
SELECT city, COUNT(*) AS cnt 
FROM user GROUP 
BY city HAVING cnt > 5;
```
📌 **区别**：

- `WHERE`：分组前过滤行
    
- `HAVING`：分组后过滤组（可以用聚合函数）
---

## 11. 连接查询（JOIN）

### 内连接（INNER JOIN）

```sql
-- 只返回匹配的行 
SELECT u.id, u.name, o.id AS order_id 
FROM user u 
INNER JOIN orders o ON u.id = o.user_id;
```
``
### 左连接（LEFT JOIN）

```sql
-- 返回左表全部行，右表没匹配的补 NULL 
SELECT u.id, u.name, o.id AS order_id 
FROM user u 
LEFT JOIN orders o ON u.id = o.user_id;
```
### 右连接（RIGHT JOIN）

```sql
-- 返回右表全部行 
SELECT u.id, u.name, o.id AS order_id 
FROM user u RIGHT 
JOIN orders o ON u.id = o.user_id;
```
---

## 12. 子查询（Subquery）

```sql
-- 标量子查询（返回一个值） 
SELECT * FROM user 
WHERE age > (SELECT AVG(age) FROM user);  
-- 表子查询 
SELECT * FROM (     
	SELECT id, name FROM user WHERE age > 18 
) AS adults;  
-- IN 子查询
SELECT * FROM orders 
WHERE user_id IN (SELECT id FROM user WHERE is_vip = 1);
```

---
## 13. 组合查询（UNION / UNION ALL）

```sql
-- 合并两个结果集并去重 
SELECT id, name FROM user_us 
UNION 
SELECT id, name FROM user_cn;  
-- 不去重（效率高） 
SELECT id, name FROM user_us 
UNION ALL 
SELECT id, name FROM user_cn;
```

---

## 14. 函数与表达式

- 字符串函数：`CONCAT()`, `SUBSTRING()`, `LENGTH()`, `UPPER()`, `LOWER()`
    
- 日期时间函数：`NOW()`, `CURDATE()`, `DATE_ADD()`, `DATEDIFF()`
    
- 数值函数：`ROUND()`, `CEIL()`, `FLOOR()`, `ABS()`
    
```sql
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM user; 
SELECT DATE_ADD(NOW(), INTERVAL 7 DAY) AS next_week;
```

---

## 15. 安全与性能建议

1. **避免 `SELECT *`**：只取需要的列，减少网络和内存开销。
    
2. 条件列要**命中索引**，否则会全表扫描，慢且耗资源。
    
3. 大量数据分页时，优先用**条件分页**而不是大偏移量：
    
```sql
  -- 慢：
  LIMIT 100000, 20 
  -- 快： 
  SELECT * FROM orders WHERE id > 500000 LIMIT 20;
```
    
4. `GROUP BY` + `ORDER BY` 时，注意可能需要额外索引或临时表。
    
5. 需要锁数据时用 `SELECT ... FOR UPDATE`（事务内），避免并发更新冲突。
    
6. 查询优化可配合 `EXPLAIN` 分析执行计划。


# 运算符
### 1. 比较运算符（Comparison Operators）

| 运算符         | 作用             | 示例          | 结果                           |
| ----------- | -------------- | ----------- | ---------------------------- |
| `=`         | 等于             | `age = 18`  | age 等于 18                    |
| `<>` 或 `!=` | 不等于            | `age <> 18` | age 不等于 18                   |
| `<`         | 小于             | `age < 18`  | age 小于 18                    |
| `>`         | 大于             | `age > 18`  | age 大于 18                    |
| `<=`        | 小于等于           | `age <= 18` | age ≤ 18                     |
| `>=`        | 大于等于           | `age >= 18` | age ≥ 18                     |
| `<=>`       | 安全等于（可比较 NULL） | `a <=> b`   | a 与 b 同为 NULL 或值相等时返回 1，否则 0 |

---
## 2. NULL 检查运算符

| 运算符           | 作用     | 示例                |
| ------------- | ------ | ----------------- |
| `IS NULL`     | 值是否为空  | `age IS NULL`     |
| `IS NOT NULL` | 值是否不为空 | `age IS NOT NULL` |

---

## 3. 范围运算符（Range Operators）

|运算符|作用|示例|
|---|---|---|
|`BETWEEN a AND b`|在范围内（含边界）|`age BETWEEN 18 AND 30`|
|`NOT BETWEEN a AND b`|不在范围内|`price NOT BETWEEN 100 AND 500`|

📌 **注意**：- `BETWEEN` 等价于 `a >= 值1 AND a <= 值2`，并且包含端点。
---
## 4. 集合运算符（Set Operators）

|运算符|作用|示例|
|---|---|---|
|`IN (...)`|值在集合中|`city IN ('Beijing', 'Shanghai')`|
|`NOT IN (...)`|值不在集合中|`id NOT IN (1, 2, 3)`|

📌 **注意**：

- `NOT IN` + `NULL` 有坑：集合里有 `NULL` 会导致结果全为 UNKNOWN，需要排除 `NULL`。

```sql
   SELECT * FROM t WHERE id NOT IN (1, 2, NULL); -- 可能全查不到`
```     
---
## 5. 模式匹配运算符（Pattern Matching）

|运算符|作用|示例|
|---|---|---|
|`LIKE`|模糊匹配|`name LIKE 'A%'`|
|`NOT LIKE`|不匹配|`name NOT LIKE '%test%'`|
|`REGEXP` / `RLIKE`|正则匹配|`email REGEXP '^[a-z0-9._%+-]+@gmail\\.com$'`|
|`NOT REGEXP`|正则不匹配|`name NOT REGEXP '^[0-9]+$'`|

📌 **通配符**（`LIKE` 专用）：

- `%`：匹配任意长度（0 个或多个）字符
    
- `_`：匹配任意单个字符  

    例子：
```sql
name LIKE 'A%'    -- 以 A 开头
name LIKE '%A'    -- 以 A 结尾
name LIKE '_A%'   -- 第二个字符是 A
```
---
## 6. 逻辑运算符（Logical Operators）

| 运算符          | 作用  | 示例                           |
| ------------ | --- | ---------------------------- |
| `AND` 或 `&&` | 逻辑与 | `age >= 18 AND gender = 'F'` |
| `OR` 或 `     |     | `                            |
| `NOT` 或 `!`  | 逻辑非 | `NOT is_vip`                 |

📌 逻辑运算的优先级：

1. `NOT`
    
2. `AND`
    
3. `OR`  
    如果不确定优先级，最好用 `()` 明确分组。

---
## 7. 任意/所有比较（Any/All）

|运算符|作用|示例|
|---|---|---|
|`= ANY (子查询)`|等于子查询任一结果|`age = ANY (SELECT age FROM vip)`|
|`> ALL (子查询)`|大于子查询所有结果|`salary > ALL (SELECT salary FROM dept)`|

📌 用法类似数学的“∃”与“∀”。

---

## 8. EXISTS 子查询判断

```sql
-- 判断子查询是否返回行
SELECT name FROM user u
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

-- 判断子查询是否无行
SELECT name FROM user u
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

```

- `EXISTS` 只关心子查询是否有结果，不关心返回什么。

---

## 9. 特殊运算符（MySQL 扩展）

|运算符|作用|示例|
|---|---|---|
|`<=>`|NULL 安全等于|`a <=> b`|
|`IS TRUE` / `IS FALSE`|检查布尔值|`flag IS TRUE`|
|`IS UNKNOWN`|检查是否为 UNKNOWN（三值逻辑）|`condition IS UNKNOWN`|

---

✅ **总结图**

```sql
比较运算符      =  <>  !=  <  >  <=  >=  <=>  
NULL 检查       IS NULL  IS NOT NULL
范围运算        BETWEEN ... AND ...   NOT BETWEEN ...
集合运算        IN (...)  NOT IN (...)
模式匹配        LIKE  NOT LIKE  REGEXP  NOT REGEXP
逻辑运算        AND  OR  NOT
任意/所有       ANY   ALL
存在判断        EXISTS  NOT EXISTS
```

---
