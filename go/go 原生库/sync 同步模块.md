
这是 Go 标准库里非常重要的一个包，用来处理 **多 goroutine 的并发控制**，主要功能是 **互斥锁、读写锁、条件变量、一次性执行、等待组、池** 等。

---
###. `sync` 包的作用

`sync` 包就是为了解决 **并发安全** 问题，提供了多种同步原语：

- **互斥锁 (Mutex)**：保证同一时间只有一个 goroutine 进入临界区。
    
- **读写锁 (RWMutex)**：读多写少时性能更好。
    
- **等待组 (WaitGroup)**：等待一组 goroutine 完成。
    
- **条件变量 (Cond)**：实现等待/通知机制。
    
- **一次性执行 (Once)**：保证某段代码只执行一次（单例模式）。
    
- **对象池 (Pool)**：缓存临时对象，减少 GC 压力。
    
- **并发安全 Map (sync.Map)**：读多写少的 map。

## 1. sync 包的核心功能

`sync` 提供了多种并发原语：
#### 1. **互斥锁 (Mutex)**

- 类型：`sync.Mutex`
-  作用：保证同一时间只有一个 goroutine 进入临界区。
- 方法：
     - `Lock()`：加锁，如果已经被锁住则阻塞。
     - `Unlock()`：解锁，如果没有锁住时调用会 panic。
    **示例：**

```go
var mu sync.Mutex
var count int

func worker() {
    mu.Lock()
    count++
    mu.Unlock()
}
```
--- 
### 2. **读写锁 (RWMutex)**
- 类型：`sync.RWMutex`
- 作用：读共享、写独占；多个读可以同时进行，但写时必须独占。
 - 方法：
	- `RLock()` / `RUnlock()`：加/解读锁。
	- `Lock()` / `Unlock()`：加/解写锁。
   **示例:**
```go
var rw sync.RWMutex
var data int

func readData() int {
    rw.RLock()
    defer rw.RUnlock()
    return data
}

func writeData(v int) {
    rw.Lock()
    data = v
    rw.Unlock()
}
```
---
## 3.**条件变量 (Cond)**

- 类型：`sync.Cond`
- 作用：配合 `Lock` 使用，等待或唤醒条件满足时的 goroutine。
- 方法：
    - `Wait()`：等待条件成立，会自动解锁并阻塞，直到被 `Signal/Broadcast` 唤醒后重新加锁。
    - `Signal()`：唤醒一个等待的 goroutine。
    - `Broadcast()`：唤醒所有等待的 goroutine。

**示例：**
```go
var mu sync.Mutex
var cond = sync.NewCond(&mu)
var ready = false

func worker() {
    mu.Lock()
    for !ready {
        cond.Wait()
    }
    fmt.Println("worker run")
    mu.Unlock()
}

func main() {
    go worker()
    time.Sleep(time.Second)
    mu.Lock()
    ready = true
    cond.Signal()
    mu.Unlock()
}
```
---
### 4.**一次性执行 (Once)**
- 类型：`sync.Once`
- 作用：保证某段代码只执行一次（常用于单例模式或只需初始化一次的操作）。
- 方法：
    - `Do(f func())`：只会执行一次 `f`。
**示例：**
```go
var once sync.Once

func initConfig() {
    fmt.Println("init config")
}

func worker() {
    once.Do(initConfig)
    fmt.Println("worker run")
}
```
---
### 5.**等待组 (WaitGroup)**

- 类型：`sync.WaitGroup`
- 作用：等待一组 goroutine 完成。
- 方法：    
    - `Add(n int)`：计数器增加 n。
    - `Done()`：计数器减 1。
    - `Wait()`：阻塞直到计数器为 0。
**示例：**
```go
var wg sync.WaitGroup

func worker(id int) {
    defer wg.Done()
    fmt.Println("worker", id)
}

func main() {
    for i := 0; i < 5; i++ {
        wg.Add(1)
        go worker(i)
    }
    wg.Wait()
    fmt.Println("all done")
}
```
---
### 6.**对象池 (Pool)**
- 类型：`sync.Pool`
- 作用：临时对象池，减少内存分配和 GC 压力。
- 字段/方法：
    
    - `New func() interface{}`：当池子为空时，调用该函数生成新对象。
        
    - `Get()`：从池中取对象（如果没有则调用 `New`）。
        
    - `Put(x interface{})`：把对象放回池中。
**示例：**
```go
var pool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

func main() {
    buf := pool.Get().(*bytes.Buffer)
    buf.WriteString("hello")
    fmt.Println(buf.String())

    buf.Reset()
    pool.Put(buf)
}
```
---
#### 7.Sync.Map 简介
- 类型：`sync.Map`
- 出现版本：Go 1.9 引入
- **作用**：并发安全的 map，适用于读多写少的场景。
- **区别于普通 `map`**：
    - 普通 `map` 不是并发安全的，多 goroutine 同时读写会导致竞态问题。
        
    - `sync.Map` 内部做了优化，避免了大部分场景中加全局锁带来的性能开销。
 `主要方法`:
```go
 type Map struct {
   // 内部实现隐藏
}

func (m *Map) Store(key, value interface{})     // 存储键值对
func (m *Map) Load(key interface{}) (value interface{}, ok bool) // 根据 key 获取
func (m *Map) LoadOrStore(key, value interface{}) (actual interface{}, loaded bool)
func (m *Map) Delete(key interface{})           // 删除 key
func (m *Map) Range(f func(key, value interface{}) bool) // 遍历
```
#### 方法详解
1. **`Store(key, value)`**  
    存储或更新键值对。
2. **`Load(key)`**  
    根据 `key` 获取 `value`，如果不存在返回 `nil, false`。
3. **`LoadOrStore(key, value)`**
    - 如果 `key` 已经存在，返回已存在的值，并返回 `loaded = true`。
    - 如果 `key` 不存在，存入 `value` 并返回它，`loaded = false`。
    👉 常用于初始化缓存，避免重复创建。
4. **`Delete(key)`**  
    删除键值对。
5. **`Range(f)`**  
    遍历 map 中的所有键值对。回调函数返回 `false` 时停止遍历。
#### 使用示例
```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var m sync.Map
	// 存值
	m.Store("name", "Alice")
	m.Store("age", 20)
	// 取值
	if v, ok := m.Load("name"); ok {
		fmt.Println("name =", v)
	}
	// LoadOrStore
	actual, loaded := m.LoadOrStore("name", "Bob")
	fmt.Println(actual, loaded) // Alice true
	// 遍历
	m.Range(func(k, v interface{}) bool {
		fmt.Println(k, v)
		return true
	})
	// 删除
	m.Delete("age")
}
// name = Alice
// Alice true
// name Alice
// age 20
```
---
## 2. sync 包的特点和底层原理

- **轻量级**：这些同步原语是对操作系统原语（如 futex、信号量）的封装。
- **适合并发场景**：Go 的 goroutine 数量很大，sync 提供了高效的同步机制。
- **非可拷贝**：`Mutex`、`RWMutex`、`Cond`、`WaitGroup` 等类型都不能被复制，一旦复制会导致竞态问题甚至 panic。
- **原子性保证**：Mutex、RWMutex 底层依赖 CAS（Compare-And-Swap）和 runtime 调度器。
---
## 3. 常见注意事项

1. `Unlock()` 必须和 `Lock()` 配对，否则会死锁。建议使用 `defer`。
    
2. `WaitGroup` 的 `Add()` 必须在 `Wait()` 前调用，否则可能死锁。
    
3. `Cond.Wait()` 要放在循环中检查条件，因为唤醒可能是“虚假唤醒”。
    
4. `sync.Pool` 中的对象会被 GC 回收，不能依赖它做持久缓存。
    
5. `sync.Once` 的 `Do()` 函数若 panic，再次调用也不会执行。
