`urfave/cli` 的 **Flag 类型** 是它的核心之一，主要负责 **定义命令行参数** 的名字、类型、默认值、帮助信息、环境变量支持等。
## 1. Flag 的分类

`urfave/cli/v2` 提供的 Flag 类型基本分为 **两类**：

-  **按数据类型划分**（内置常用类型）

| 类型                        | Go 类型         | 示例值                   |
| ------------------------- | ------------- | --------------------- |
| `StringFlag`              | string        | "abc"                 |
| `IntFlag` / `Int64Flag`   | int / int64   | 123                   |
| `UintFlag` / `Uint64Flag` | uint / uint64 | 42                    |
| `BoolFlag`                | bool          | true                  |
| `Float64Flag`             | float64       | 3.14                  |
| `DurationFlag`            | time.Duration | "5s" / "1m30s"        |
| `TimestampFlag`           | time.Time     | "2025-08-14 15:00:00" |
| `PathFlag`                | string        | "./config.yaml"       |
| `GenericFlag`             | 任意类型          | 自定义解析                 |
| `StringSliceFlag`         | []string      | 多值字符串                 |

-  **按作用域划分**
    
    - **全局 Flag**（定义在 `app.Flags`，所有命令可用）
        
    - **命令专属 Flag**（定义在 `cli.Command.Flags`，仅该命令可用）
---
## 2. 通用字段（所有 Flag 都有的属性）

无论是哪种 Flag 类型，基本都支持以下字段

| 字段名             | 类型       | 作用            |
| --------------- | -------- | ------------- |
| **Name**        | string   | Flag 的名字（主名称） |
| **Aliases**     | []string | 别名（短名称）       |
| **Usage**       | string   | 帮助说明          |
| **Value**       | 对应类型     | 默认值           |
| **Required**    | bool     | 是否必填          |
| **EnvVars**     | []string | 支持从环境变量读取值    |
| **Hidden**      | bool     | 是否隐藏（帮助信息不显示） |
| **TakesFile**   | bool     | 是否将值当作文件路径    |
| **Destination** | *T       | 直接将值赋给指定变量地址  |

---
## 3. 各 Flag 类型详解
#### (1) StringFlag
```go
&cli.StringFlag{
    Name:     "name",
    Aliases:  []string{"n"},
    Usage:    "用户名称",
    Value:    "defaultUser",
    EnvVars:  []string{"APP_USER"},
    Required: false,
}
```
运行：
```bash
./app --name Alice
```
结果：
```go
c.String("name") // "Alice"
```
####  流程示意
```bash
./app --name Alice
     │
     ├─ urfave/cli 解析 Flags
     │    - name = "Alice"
     │
     ├─ 构造 *cli.Context (c)
     │    - 把 "name" → "Alice" 存进去
     │
     └─ 调用 Action(c)
          - 在 Action 里 c.String("name") 返回 "Alice"
```
---
#### **(3) BoolFlag**

布尔类型，默认值为 `false`，只要写了 Flag 就是 `true`。

```go
&cli.BoolFlag{     
	Name:   "verbose",
	Usage:  "启用详细日志", 
}
```

运行：
```bash
./app --verbose
```

结果：
```go
c.Bool("verbose") // true
```

### **(6) TimestampFlag**

直接解析成 `time.Time`
```go
&cli.TimestampFlag{
    Name:   "start",
    Usage:  "开始时间",
    Layout: "2006-01-02 15:04:05", // 解析格式
}
```

```bash
./app --start "2025-08-14 15:00:00"
```

结果：
```go
c.Timestamp("start") // time.Time
```
---
## 4. 高级特性

### (1) Destination 直接绑定变量

```go
var port int
&cli.IntFlag{
    Name:        "port",
    Destination: &port,
}
```

运行后 `port` 自动赋值，不需要 `c.Int("port")`。

---

### (2) 环境变量优先级

```go
&cli.StringFlag{
    Name:    "db",
    EnvVars: []string{"DB_URL", "DATABASE_URL"},
}
```

优先级：**命令行参数 > 环境变量 > 默认值**

---

### (3) Required 校验
```go
&cli.StringFlag{
    Name:     "token",
    Required: true,
}
```

如果没传 `--token`，会直接报错。

---

### (4) 多值 Flag（重复传递）

`urfave/cli` 支持 **同一个 Flag 重复出现** ，自动累加：

```go
&cli.StringSliceFlag{
	name: "include", 
}
```

```bash
./app --include a --include b
```

结果：
```go
c.StringSlice("include") // ["a", "b"]
```
---

**解析顺序**：先找命令路径 → 解析各层 Flags → 套用 EnvVars/默认值 → 构建 Context → 执行钩子与 Action。