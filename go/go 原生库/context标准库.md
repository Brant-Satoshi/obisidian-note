# `context` 是什么

为**协程间取消信号、超时/截止时间、请求范围内（request-scoped）只读元数据**提供统一传递机制。其核心思想：**把“这次操作的生命周期与元信息”作为第一个参数显式传递**，跨函数/协程边界传播。

---
### 1. 为什么需要 `context`

在并发或网络调用中，我们经常会遇到这些问题：

- 如何在某个超时时间后自动取消操作？
    
- 如何在调用链的某个节点取消时，让所有下游 Goroutine 都能收到信号？
    
- 如何给整个调用链共享一些元数据（trace id、用户信息等）？
    
如果不用 `context`，我们可能会自己造轮子用 `chan` 传递信号、用全局变量存储数据，容易混乱和泄漏资源。  
`context` 解决了这些问题，并且是 Go 官方推荐的模式。

---
### 2. 基本概念

`context` 包核心是一个接口：
```go
type Context interface {
    Deadline() (deadline time.Time, ok bool) // 返回截止时间
    Done() <-chan struct{}                   // 取消信号通道
    Err() error                              // 取消原因
    Value(key any) any                       // 获取上下文中的值
}
```
Go 提供了几个内置的实现函数：

- `context.Background()`：根 Context，通常作为顶层入口
    
- `context.TODO()`：占位 Context，用于还没确定要用什么 Context 的地方
    
- `context.WithCancel(parent)`：返回一个可取消的 Context
    
- `context.WithTimeout(parent, duration)`：带超时自动取消的 Context
    
- `context.WithDeadline(parent, time)`：到指定时间自动取消的 Context
    
- `context.WithValue(parent, key, val)`：在 Context 中存储一个键值对
---
### 3. 使用示例

#### 3.1 超时控制
```go
package main

import (
    "context"
    "fmt"
    "time"
)

func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()

    ch := make(chan string)

    go func() {
        time.Sleep(3 * time.Second) // 模拟耗时操作
        ch <- "完成"
    }()

    select {
    case res := <-ch:
        fmt.Println(res)
    case <-ctx.Done():
        fmt.Println("超时:", ctx.Err())
    }
}
```
输出：
```makefile
超时： context deadline exceeded
```
---
#### 3.2 取消多个 Goroutine

```go
package main

import (
    "context"
    "fmt"
    "time"
)

func worker(ctx context.Context, id int) {
    for {
        select {
        case <-ctx.Done():
            fmt.Printf("worker %d 停止: %v\n", id, ctx.Err())
            return
        default:
            fmt.Printf("worker %d 工作中...\n", id)
            time.Sleep(500 * time.Millisecond)
        }
    }
}

func main() {
    ctx, cancel := context.WithCancel(context.Background())

    for i := 1; i <= 3; i++ {
        go worker(ctx, i)
    }

    time.Sleep(2 * time.Second)
    cancel() // 取消所有 worker

    time.Sleep(1 * time.Second) // 等待所有 worker 停止
}
```
---
#### 3.3 传递元数据
```go
package main

import (
    "context"
    "fmt"
)

func process(ctx context.Context) {
    if v := ctx.Value("userID"); v != nil {
        fmt.Println("处理用户:", v)
    }
}

func main() {
    ctx := context.WithValue(context.Background(), "userID", 42)
    process(ctx)
}
```
⚠ **注意**：`WithValue` 一般只存储请求范围的元数据（如 trace id、认证信息），不要存放大量数据或业务参数。

---
### 4. 常见用法总结

| 函数                       | 作用             |
| ------------------------ | -------------- |
| `context.Background()`   | 创建根 Context    |
| `context.TODO()`         | 占位 Context     |
| `context.WithCancel()`   | 可手动取消的 Context |
| `context.WithTimeout()`  | 一段时间后自动取消      |
| `context.WithDeadline()` | 到指定时间点自动取消     |
| `context.WithValue()`    | 存储键值对          |

---
### 5. 最佳实践

1. **不要在结构体中存储 `Context`**，应作为参数传递
    
2. **Context 是不可变的**，需要派生新的 Context 再传递
    
3. **及时调用 `cancel()`**，避免 Goroutine 泄漏
    
4. **不要用 Context 传递可选参数**，只用于控制和元数据
    
5. 在并发任务中，`ctx.Done()` 是监听退出信号的标准方式