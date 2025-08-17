
## 1. Context 是什么

在 `urfave/cli` 中，`Context` 是**命令运行时的上下文对象**，它包含了：

- 当前应用（`App`）
    
- 当前命令（`Command`）
    
- 解析后的 **Flag 值**
    
- 命令行位置参数（Args）
    
- 继承自 Go 原生 `context.Context` 的能力（超时、取消、传递数据等）

> 你可以把它想成 CLI 执行过程中的「快照」，记录了这一次命令执行的全部环境信息。

```mathematica
main()
  │
  ▼
app.Run(os.Args) ────────────────────────┐
  │                                      │
  │ 1) 根据 app/command 定义解析 flags     │
  │ 2) 构造一个 *cli.Context              │
  │ 3) 把解析结果（flag 值、args 等）放进去  │
  │ 4) 调用 Before/Action/After          │
  ▼                                      │
Action(c *cli.Context)  <── 你在这里使用它 │
```
**关键点**：
- Context 只在命令执行的过程中存在
- `urfave/cli` 会在调用你的回调（`Action`、`Before`、`After`）时，把 `*cli.Context` 作为参数传进去
- 你不能在 Context 创建之前访问 flag 值（因为还没解析）
---
## 3. Context 的核心字段（简化后）

```go
type Context struct {
    context.Context      // Go 原生上下文，可用 c.Context.Done() 等
    App     *App         // 当前 CLI 应用
    Command Command      // 当前命令（含 Flags/Action 等）
    flagSet *flag.FlagSet // 解析后的 flag 集合
    parentContext *Context // 父 Context（支持嵌套命令）
    Args    Args          // 位置参数
}
```
---
## 4. Context 常用方法

### **读取 Flag 值**

根据 Flag 类型选择对应方法：
```go
c.String("name")        // StringFlag
c.Int("port")           // IntFlag
c.Bool("verbose")       // BoolFlag
c.Float64("rate")       // Float64Flag
c.Duration("timeout")   // DurationFlag
c.Timestamp("start")    // TimestampFlag
```
---
读取位置参数（非 Flag）
```go
c.Args().Get(0)    // 第一个位置参数
c.Args().Slice()   // 全部位置参数 []string
c.NArg()           // 位置参数数量
```
例如：

```bash
./app greet Alice Bob
```

`c.Args().Slice()` → `["Alice", "Bob"]`

---
命令和应用信息
```go
c.Command.Name   // 当前命令的名称
c.App.Name       // 应用名称
c.App.Version    // 应用版本
```
### **Go 原生 context.Context 功能**
```go
ctx := c.Context
select {
case <-ctx.Done():
    fmt.Println("执行取消")
default:
    fmt.Println("继续执行")
}
```

 这在 CLI 中做超时/取消控制很有用
 
---

## 5. 多层命令时 Context 的嵌套

`urfave/cli` 支持多层命令（子命令、子子命令…），Context 是**逐层构造的**。
```go
app := &cli.App{
    Commands: []*cli.Command{
        {
            Name: "parent",
            Subcommands: []*cli.Command{
                {
                    Name: "child",
                    Action: func(c *cli.Context) error {
                        fmt.Println("当前命令:", c.Command.Name)         // child
                        fmt.Println("父命令:", c.Parent().Command.Name) // parent
                        return nil
                    },
                },
            },
        },
    },
}
```

运行：

```bash
./app parent child
```

输出：
```makefile
当前命令: child 
父命令: parent
```
---
## 6. Context 的使用场景

- **读取解析后的 flag 值**（这是最常用的）
    
- **获取位置参数**（Args）
    
- **获取当前命令/应用信息**（Name、Usage、Version）
    
- **传递取消信号 / 超时**（结合 `context.Context`）
    
- **多层命令时共享数据**（通过 `Parent()` 访问父 Context）
---
## 7. 总结类比

- **Flag**：像“配置说明书”，定义有哪些参数、默认值、类型
    
- **Context**：像“执行现场的快照”，保存了这次执行的全部解析结果和运行环境
    
- **App/Command**：像“应用大纲”和“功能清单”
    
- **Action(c)**：像“入口函数”，`c` 把现场信息交给你使用