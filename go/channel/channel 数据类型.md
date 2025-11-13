## 一、什么是 channel

- **channel 是 Go 语言中的一种内置数据类型**，用于 **在 goroutine 之间传递数据**。
    
- 它本质上是一个 **有类型的队列**，只能存储一种类型的值（强类型）。
    
- 常常与 goroutine 搭配使用，实现 **并发安全的数据通信**。

> 官方定义：`channel` 是 goroutine 之间的通信机制，**通过通信来共享内存，而不是通过共享内存来通信**。
---

## 二、channel 的创建

使用 `make` 创建：

```go
ch := make(chan int)        // 无缓冲 channel
ch2 := make(chan string, 5) // 有缓冲 channel，容量为 5
```

- **无缓冲 channel**：必须发送和接收同时就绪才能完成（同步通信）。

- **有缓冲 channel**：发送方写入数据到缓冲区，缓冲满时才阻塞。
---
## 三、基本操作

1. **发送数据**

```go
ch <- 10   // 将 10 发送到 channel
```

2. **接收数据**

```go
x := <-ch  // 从 channel 接收数据并赋值给 x <-ch       // 接收数据，但丢弃`
```

3. **关闭 channel**

```go
close(ch)
```

>**注意**：关闭后不能再发送数据，否则会 panic；  
   但仍可以继续接收数据，直到数据读空，之后返回该类型零值。
---
## 四、无缓冲 channel 示例

```go
func main() {
    ch := make(chan int)

    go func() {
        fmt.Println("准备发送数据 10")
        ch <- 10
        fmt.Println("发送完成")
    }()

    time.Sleep(time.Second)
    fmt.Println("准备接收数据")
    x := <-ch
    fmt.Println("接收到：", x)
}
```
执行顺序：

1. 子 goroutine 在 `ch <- 10` 时阻塞，直到主 goroutine 执行 `<-ch`。
    
2. 主 goroutine 接收后，子 goroutine 才能继续执行。  
    👉 **无缓冲 channel 保证了发送与接收的同步。**
---
### 五、有缓冲 channel 示例

```go
func main() {
    ch := make(chan int, 2)

    ch <- 1
    ch <- 2
    fmt.Println("已经发送了 2 个数据")

    fmt.Println(<-ch) // 1
    fmt.Println(<-ch) // 2
}
```
---
###  六、range 与 channel

`range` 可以不断从 channel 接收数据，直到 channel 被关闭：

```go
ch := make(chan int, 3)
ch <- 1
ch <- 2
ch <- 3
close(ch)

for v := range ch {
    fmt.Println(v)
}
/* 
1
2
3
*/
```
---
### 七、select 与 channel

`select` 语句可以同时等待多个 channel 操作（类似于网络编程里的 `select`）：
```go
ch1 := make(chan int, 1)
ch2 := make(chan string, 1)

ch1 <- 10
ch2 <- "hello"

select {
case v := <-ch1:
    fmt.Println("从 ch1 收到：", v)
case v := <-ch2:
    fmt.Println("从 ch2 收到：", v)
default:
    fmt.Println("没有数据可读")
}
```
---
### 八、单向 channel

限制 channel 只能 **发送** 或 **接收**，用于函数参数约束：

```go
func send(ch chan<- int) { // 只能发送
    ch <- 10
}

func recv(ch <-chan int) { // 只能接收
    fmt.Println(<-ch)
}

func main() {
    ch := make(chan int, 1)
    send(ch)
    recv(ch)
}
```
---
### 九、channel 的零值

- channel 的零值是 `nil`，**不能直接使用**。
    
- 对 `nil` channel 的读写会永久阻塞。

---

### 十、使用场景

1. **goroutine 通信**：不同协程之间安全传递数据。
    
2. **任务分发**：生产者-消费者模型。
    
3. **信号通知**：结束信号、同步点。
    
4. **控制并发数**：利用缓冲 channel 作为令牌池。
    
---

### 十一、常见坑

1. **关闭 channel**：只能由发送方关闭，接收方不要关闭。
    
2. **多次关闭**：会 panic。
    
3. **读写 nil channel**：永久阻塞。
    
4. **有缓冲 channel 滥用**：如果容量过大，相当于内存队列，可能导致内存占用。

---
✅ 总结：

- `channel` 是 Go 提供的 **并发安全的通信机制**。
 
- 分为 **无缓冲**（同步通信）和 **有缓冲**（异步通信）。

- 搭配 `range`、`select`、单向 channel，可灵活构建并发模式