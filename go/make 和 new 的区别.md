
在 Go（Golang）语言中，`make` 和 `new` 都是用来分配内存的内建函数，但它们的使用方式、返回值以及适用的类型是不同的：

---

## ✅ 一句话区别：

- `new` 用于 **任何类型**，返回的是 **指针**，只做 **零值分配**；
    
- `make` 只能用于 **slice、map、chan**，返回的是 **初始化后的值本身**（非指针）。
    
---

## 📌 `new` 的特点：

- 用法：`ptr := new(T)`，其中 T 是任意类型。
    
- 功能：分配一块内存，将其置为类型 `T` 的零值，并返回该类型的指针 `*T`。
    
- 示例：

    
```go
type Person struct {
	    Name string 
} 

p := new(Person)  // p 的类型是 *Person，p.Name == ""
``` 
    
- 等价于：
```
    var p *Person = &Person{}
```

---

## 📌 `make` 的特点：

- 用法：`make(T, args)`，其中 T **必须是 slice、map 或 channel**。
    
- 功能：不仅分配内存，还完成初始化（比如设置 slice 长度和容量，或 map 的哈希结构）。
    
- 返回的不是指针，而是 **初始化好的值** 本身。
    
- 示例（slice）：
    `s := make([]int, 5, 10) // 长度为 5，容量为 10 的 slice`
    
- 示例（map）：
    
    `m := make(map[string]int) m["key"] = 1`
    
- 示例（channel）：
    
    `ch := make(chan int, 2) ch <- 1`
    

---

## 📋 总结对比表：

|特点|`new`|`make`|
|---|---|---|
|返回类型|指针（`*T`）|值（slice、map、chan）|
|适用类型|任意类型|仅限 slice、map、chan|
|是否初始化|只置零值，不做复杂初始化|完整初始化（如 map 哈希表结构）|
|使用目的|获取指针，多用于自定义 struct 等|创建可用的 slice/map/channel|

---

## 🧠 使用建议：

- 需要创建结构体并返回指针，用 `new`（或 `&T{}`）。
    
- 需要创建并使用 slice、map、channel，用 `make`。