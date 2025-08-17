# **Data Definition Language**（数据定义语言），主要用来 **定义和管理数据库的结构**，而不是操作数据本身。
## DDL 数据库操作 

| 命令         | 作用                        | 示例                                                           |
| ---------- | ------------------------- | ------------------------------------------------------------ |
| `CREATE`   | 创建数据库或表                   | `CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(50));` |
| `ALTER`    | 修改现有数据库对象的结构              | `ALTER TABLE users ADD COLUMN email VARCHAR(100);`           |
| `DROP`     | 删除数据库或表（结构和数据一起删除）        | `DROP TABLE users;`                                          |
| `TRUNCATE` | 清空表数据，但保留结构（速度比 DELETE 快） | `TRUNCATE TABLE users;`                                      |
| `RENAME`   | 重命名表                      | `RENAME TABLE users TO customers;`                           |
```sql
-- 创建数据库
CREATE DATABASE company;

CREATE DATABASE [IF NOT EXISTS] company;

-- 切换到新数据库
USE company;

-- 查看当前数据库
SELECT DATABASE();

-- 创建表
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    hire_date DATE
);

-- 修改表，增加一个列
ALTER TABLE employees ADD COLUMN salary DECIMAL(10,2);

-- 删除表
DROP TABLE [IF EXISTS] employees;

```


指定字符集（charset）是为了**确保数据存储和读取时的编码一致**，避免出现乱码、

- `latin1`：只能存英文和部分西欧语言
    
- `utf8`：可存中文、英文、日文等（但 MySQL 的 `utf8` 只能存 3 字节）
    
- `utf8mb4`：支持完整 Unicode，包括 Emoji、特殊符号等

字符集会决定**默认排序规则（collation）**，比如：

- `utf8_general_ci`：大小写不敏感（`ci = case-insensitive`）
    
- `utf8_bin`：大小写敏感（`bin = binary`）
    

所以相同的字符串在不同字符集下排序结果可能不同。


**指定字符集为 `utf8`**
```sql
CREATE DATABASE test
DEFAULT CHARACTER SET utf8
DEFAULT COLLATE utf8_general_ci;
```

更推荐用 **`utf8mb4`**（支持完整的 Unicode，包括 Emoji）：
```sql
CREATE DATABASE test
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_general_ci;
```

## DDL -  表操作 - 查询

- 查询当前数据库所有表
```sql
SHOW TABLES;
```

- 查询表结构

```sql
DESC 表名
```

- 查询指定表的建表语句

```sql
SHOW CREATE TABLE 表名;
```

```sql
CREATE TABLE `employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `position` varchar(50) DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

CREATE TABLE 表名(
	字段1 字段1类型[COMMENT 字段1注释],
	字段2 字段2类型[COMMENT 字段2注释]
)[COMMENT 表注释]
```

## DDL -  表操作 -  修改

### 1️⃣ 添加字段（ADD COLUMN）

```sql
ALTER TABLE 表名 ADD COLUMN 字段名 数据类型 [约束] [COMMENT '注释'] [位置];

ALTER TABLE user
ADD COLUMN email VARCHAR(100) COMMENT '邮箱' AFTER name;
```
### 2️⃣ 修改字段类型或属性（MODIFY COLUMN）

```sql
ALTER TABLE 表名
MODIFY COLUMN 字段名 新数据类型 [约束] [COMMENT '注释'];

ALTER TABLE user
MODIFY COLUMN age SMALLINT UNSIGNED COMMENT '年龄';
```

### 3️⃣ 修改字段名（CHANGE COLUMN）
```sql
ALTER TABLE 表名 CHANGE COLUMN 旧字段名 新字段名 数据类型 [约束] [COMMENT '注释'];


ALTER TABLE user
CHANGE COLUMN name username VARCHAR(50) COMMENT '用户名';
```

### 4️⃣ 删除字段（DROP COLUMN）

```sql
ALTER TABLE 表名 DROP COLUMN 字段名;

ALTER TABLE user
DROP COLUMN gender;
```

### 5️⃣ 修改表名（RENAME TO）

```sql
ALTER TABLE 旧表名 RENAME TO 新表名;

-- 例子：

ALTER TABLE user RENAME TO users;
```
### 6️⃣ 修改表选项（CHARSET、ENGINE、COMMENT）

```sql
ALTER TABLE 表名 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- 修改存储引擎：

ALTER TABLE 表名 ENGINE = InnoDB;

-- 修改表注释：

ALTER TABLE 表名 COMMENT = '新用户表';
```

## DDL -  表操作  - 删除 

```sql
DROP TABLE [IF EXISTS] 表名;

-- 删除指定表 并重新创建该表
TRUNCATE TABLE 表名;
```
**删除表会删除表中所有数据！！！
## DDL -  表操作 - 数据类型

### 1️⃣ 数值类型（Numeric Types）

| 类型                         | 字节  | 范围（有符号）                  | 说明                 |
| -------------------------- | --- | ------------------------ | ------------------ |
| `TINYINT`                  | 1   | -128 ~ 127               | 小整数（适合状态标记、布尔值）    |
| `SMALLINT`                 | 2   | -32768 ~ 32767           | 小范围整数              |
| `MEDIUMINT`                | 3   | -8388608 ~ 8388607       | 中等整数               |
| `INT` / `INTEGER`          | 4   | -2147483648 ~ 2147483647 | 常用整数               |
| `BIGINT`                   | 8   | -2^63 ~ 2^63-1           | 大整数（适合存毫秒时间戳）      |
| `DECIMAL(M,D)` / `NUMERIC` | 变长  | 精确小数                     | **金融场景推荐**，不会有浮点误差 |
| `FLOAT(M,D)`               | 4   | 近似值                      | 单精度浮点，速度快但有误差      |
| `DOUBLE(M,D)` / `REAL`     | 8   | 近似值                      | 双精度浮点              |
| `BIT(M)`                   | 1~8 | 二进制位                     | 存二进制标志位            |
### 2️⃣ 日期与时间类型（Date and Time Types）

| 类型          | 字节  | 范围                                        | 格式                           |
| ----------- | --- | ----------------------------------------- | ---------------------------- |
| `DATE`      | 3   | 1000-01-01 ~ 9999-12-31                   | `YYYY-MM-DD`                 |
| `DATETIME`  | 8   | 1000-01-01 00:00:00 ~ 9999-12-31 23:59:59 | `YYYY-MM-DD HH:MM:SS`        |
| `TIMESTAMP` | 4   | 1970-01-01 ~ 2038                         | `YYYY-MM-DD HH:MM:SS`（受时区影响） |
| `TIME`      | 3   | -838:59:59 ~ 838:59:59                    | `HH:MM:SS`                   |
| `YEAR`      | 1   | 1901 ~ 2155                               | `YYYY`                       |
### 3️⃣ 字符串类型（String Types）
#### (1) 固定长度

|类型|最大长度|特点|
|---|---|---|
|`CHAR(M)`|0~255|固定长度，速度快但浪费空间（不足补空格）|
 
#### (2) 可变长度

|类型|最大长度|特点|
|---|---|---|
|`VARCHAR(M)`|0~65535|变长节省空间，需额外 1~2 字节记录长度|

> 实际最大长度会受 **行大小** 和 **字符集** 限制，例如 `utf8mb4` 每字符最多占 4 字节。

#### (3) 大文本

| 类型           | 存储大小        | 最大长度       | 用途   |
| ------------ | ----------- | ---------- | ---- |
| `TINYTEXT`   | 1 字节长度 + 数据 | 255        | 小文本  |
| `TEXT`       | 2 字节长度 + 数据 | 65,535     | 普通文本 |
| `MEDIUMTEXT` | 3 字节长度 + 数据 | 16,777,215 | 中型文本 |
| `LONGTEXT`   | 4 字节长度 + 数据 | 4GB        | 超大文本 |
#### (4) 二进制数据
| 类型             | 最大长度      | 用途             |
| -------------- | --------- | -------------- |
| `BINARY(M)`    | 固定长度      | 存原始二进制         |
| `VARBINARY(M)` | 可变长度      | 存原始二进制         |
| `BLOB` 系列      | 同 TEXT 系列 | 存二进制大对象（图片、文件） |

### 4️⃣ 枚举与集合

| 类型                    | 用途              |
| --------------------- | --------------- |
| `ENUM('v1','v2',...)` | 枚举单值，内部存索引，节省空间 |
| `SET('v1','v2',...)`  | 集合，可多选          |
|                       |                 |
示例：
```sql
CREATE TABLE user (
    id INT UNSIGNED AUTO_INCREMENT COMMENT '编号',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    age TINYINT UNSIGNED COMMENT '年龄',
    balance DECIMAL(10,2) DEFAULT 0.00 COMMENT '账户余额',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    gender ENUM('M','F') COMMENT '性别',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```
