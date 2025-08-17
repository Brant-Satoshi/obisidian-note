
**Command Line Interface（CLI）** **命令行界面**，是通过**输入文本命令**与计算机交互的一种方式。

## 1. 基本定义

- CLI 是 **Interface（界面）** 的一种形式
    
- 用户通过**键盘输入命令**（通常是文本），计算机解析并执行
    
- 输出也是文本（标准输出 / 错误输出）
    
- 不依赖图形化按钮、窗口，而是靠命令行语法和参数完成操作

### . 举个例子

假设我们有一个 CLI 工具叫 `app`：

```bash
# 查看帮助
app --help

# 执行 greet 命令
app greet --name Alice
```
- `app` → CLI 程序名
    
- `greet` → 子命令
    
- `--name Alice` → Flag（带参数）
    
- 输出：

`Hello Alice!`

# `urfave/cli` 

Go 语言里最常用的命令行工具包之一，它能帮你快速构建功能完善、易用的 CLI（Command Line Interface）应用。

---
## 1. 基本原理

`urfave/cli` 核心就是：

- 通过定义 **App**（应用）和 **Command**（命令），把终端输入的参数解析出来
    
- 根据用户输入的命令和参数，执行对应的处理函数
    
- 提供统一的帮助信息、环境变量支持、Flag 解析等功能

它封装了 Go 内置的 `flag` 包，但扩展了：

- 命令分组与子命令
- 自动生成帮助与版本信息
- 环境变量读取
- 命令别名、参数校验等
---
## 2. 核心结构

|结构|作用|
|---|---|
|**`cli.App`**|整个 CLI 应用的定义（类似“主入口”）|
|**`cli.Command`**|单个命令的定义（如 `git commit` 中的 `commit`）|
|**`cli.Flag`**|参数定义（string/int/bool/float 等类型）|
|**`cli.Context`**|上下文，包含命令行参数、Flag 值、环境变量等信息|
|**`cli.ActionFunc`**|命令执行的核心回调函数|

---
## 3. 常用功能

### (1) 定义 App 和全局 Flag

```go
package main

import (
    "fmt"
    "os"
    "github.com/urfave/cli/v2"
)

func main() {
    app := &cli.App{
        Name:    "example",
        Usage:   "示例 CLI 应用",
        Version: "1.0.0",

        Flags: []cli.Flag{
            &cli.StringFlag{
                Name:    "config",
                Aliases: []string{"c"},
                Usage:   "配置文件路径",
                EnvVars: []string{"APP_CONFIG"}, // 支持环境变量
            },
        },

        Action: func(c *cli.Context) error {
            fmt.Println("Config 文件路径:", c.String("config"))
            return nil
        },
    }

    app.Run(os.Args)
}

```

---
### (2) 添加多条命令
```go
app := &cli.App{
    Name:  "git-cli",
    Usage: "模拟 git 命令",

    Commands: []*cli.Command{
        {
            Name:    "commit",
            Aliases: []string{"ci"},
            Usage:   "提交更改",
            Flags: []cli.Flag{
                &cli.StringFlag{
                    Name:  "message",
                    Aliases: []string{"m"},
                    Usage: "提交信息",
                },
            },
            Action: func(c *cli.Context) error {
                fmt.Println("提交信息:", c.String("message"))
                return nil
            },
        },
        {
            Name:  "push",
            Usage: "推送到远程",
            Action: func(c *cli.Context) error {
                fmt.Println("正在推送...")
                return nil
            },
        },
    },
}

```

---
### (3) Flag 类型

`urfave/cli` 内置了多种 Flag 类型：

- `cli.StringFlag`
    
- `cli.IntFlag`
    
- `cli.BoolFlag`
    
- `cli.Float64Flag`
    
- `cli.DurationFlag`
    
- `cli.TimestampFlag`
    
- `cli.GenericFlag`（自定义类型）
    
每个 Flag 都支持：

- `Name`（名字）
    
- `Aliases`（别名）
    
- `Usage`（帮助信息）
    
- `Value`（默认值）
    
- `EnvVars`（环境变量）
    
- `Required`（是否必填）

---

## 4. 进阶特性

### (1) 子命令嵌套

命令可以继续包含子命令，例如：
```go
{
    Name: "remote",
    Usage: "管理远程仓库",
    Subcommands: []*cli.Command{
        {
            Name: "add",
            Usage: "添加远程",
            Action: func(c *cli.Context) error {
                fmt.Println("添加远程:", c.Args().First())
                return nil
            },
        },
    },
}
```
---

### (2) Before / After 钩子

可以在执行命令前后运行逻辑：

```go
app.Before = func(c *cli.Context) error {
    fmt.Println("执行前检查")
    return nil
}
app.After = func(c *cli.Context) error {
    fmt.Println("执行后清理")
    return nil
}
```
---
### (3) 自定义错误处理
```go
app.ExitErrHandler = func(c *cli.Context, err error) {
    fmt.Fprintf(os.Stderr, "出错了: %v\n", err)
}
```

---

### (4) 自动帮助 & 版本信息

- 自动生成 `--help` / `-h` 帮助信息
    
- 自动生成 `--version` 版本输出

---

### (5) 常见集成场景

在你给我的代码里，它通常用于：

- 定义 `flags` 包统一管理配置参数（如数据库、RPC 服务、HTTP 服务端口等）
    
- 使用 `EnvVars` 支持从环境变量读取配置
    
- 在 `config` 包里统一加载 CLI 配置到 `Config` 结构体
    
- 在 `main()` 调用 `app.Run(os.Args)` 作为入口