在 Go 以太坊的库（`go-ethereum`）里，很多类型都有一个 `.Bytes()` 方法，它的作用就是把内部数据转成 **原始的字节切片 (`[]byte`)**，方便序列化或做哈希。

### 1. `common.Address.Bytes()`

- `common.Address` 是一个 **固定 20 字节的地址类型**。
- `.Bytes()` 返回一个 `[]byte{20}`。
```go
addr := common.HexToAddress("0x1111111111111111111111111111111111111111")
fmt.Printf("%x\n", addr.Bytes())
// 输出：1111111111111111111111111111111111111111
```
---
### 2. `common.Hash.Bytes()`

- `common.Hash` 是一个 **固定 32 字节的哈希类型**。
    
- `.Bytes()` 返回 32 字节数组的切片。
```go
hash := common.HexToHash("0xabcdef...") 
fmt.Printf("%x\n", hash.Bytes())
```
---
### 3. `big.Int.Bytes()`

- `math/big.Int` 里的 `.Bytes()` 返回 **大整数的绝对值的字节切片**（大端序）。
    
- 不固定长度，前面不会自动填零，需要时要 `LeftPadBytes`。

```go
amount := big.NewInt(1000)   // 十进制 1000
fmt.Printf("%x\n", amount.Bytes())
// 输出：03e8   （= 0x03e8）
```
### 为什么要 `.Bytes()`？

在 ABI 编码里，所有参数都必须拼成字节流：

- `address` → 20字节，需要 `addr.Bytes()`。
    
- `uint256` → 变长整数，需要 `big.Int.Bytes()` 再 pad 到 32字节。
    
- `hash` → 32字节，直接 `hash.Bytes()`。

如果不转成 `[]byte`，就没法 `append` 到 calldata 里。

---
✅ **总结** 
`.Bytes()` = **取底层的二进制表示**。

- `Address.Bytes()` → 20 字节地址
    
- `Hash.Bytes()` → 32 字节哈希
    
- `big.Int.Bytes()` → 大整数的变长字节