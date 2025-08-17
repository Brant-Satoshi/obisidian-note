## 1. 接口是什么

- **接口是方法集合（method set）的命名**：只描述“需要有哪些方法”，不关心数据和实现。
    
- **隐式实现**：只要某个类型的方法集“包含”接口的所有方法，就实现了该接口；无需 `implements` 之类的关键字。
    

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```
---
## 2. 实现判定（方法集 & 指针/值接收者）

- **方法集**规则（记住这三条即可）：
    
    1. `T` 的方法集：**值接收者方法**
        
    2. `*T` 的方法集：**值接收者 + 指针接收者方法**
        
    3. 判定“谁实现接口”看**静态类型**：如果接口需要的方法里有指针接收者实现的，那么只有 `*T` 才实现接口，`T` 不算。
        
- 例子：

```go
type Counter int

func (c Counter) Value() int      { return int(c) }      // 值接收者
func (c *Counter) Inc()           { *c++ }               // 指针接收者

type Acc interface {
    Value() int
    Inc()
}

var a Acc
var x Counter = 10
// a = x        // ❌ 编译失败：x（类型 T）不含 Inc（指针接收者）
// 只有 *Counter 才有完整方法集：
a = &x          // ✅
```
---
