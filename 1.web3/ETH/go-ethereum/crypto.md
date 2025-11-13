## ✅ 1. `crypto.GenerateKey()`

**作用：**

- 生成一个新的 ECDSA 私钥（`*ecdsa.PrivateKey`），基于 secp256k1 曲线。
    
- 这个私钥包括：
    
    - `D`: 32 字节私钥（大整数）
        
    - `PublicKey`: 椭圆曲线上的点 `(X, Y)`
        
**示例：**

`privateKey, _ := crypto.GenerateKey() // privateKey 是 *ecdsa.PrivateKey`

#### Pubkey 和 CompressPubkey

✅ 两者都代表一个椭圆曲线上的点 `(X, Y)`，但：

- **未压缩公钥**：包含 X 和 Y 坐标（共 65 字节）
    
- **压缩公钥**：只包含 X 坐标 + Y 的奇偶性（共 33 字节）

|名称|字节数|内容|前缀|是否包含 Y|
|---|---|---|---|---|
|**未压缩公钥**|65|X (32) + Y (32)|`0x04`|✅ 是|
|**压缩公钥**|33|X (32) + Y 奇偶|`0x02` / `0x03`|❌ 否（可恢复）|

---

## ✅ 2. `crypto.FromECDSA(privateKey)`

**作用：**

- 从 `*ecdsa.PrivateKey` 提取出私钥 `D`（一个大整数），并返回其 32 字节二进制表示（`[]byte`）
    
- 返回值可以用于持久化或签名操作

**示例：**

`privBytes := crypto.FromECDSA(privateKey) // privBytes: [32]byte`

**用途：**

- 可转为 hex 存储
    
- 可用 `ToECDSA()` 还原回来

