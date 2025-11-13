[]()## 🔑 1. 构造交易 (TxData)

- 先准备交易字段：
    
    - `nonce`、`gasLimit`、`to`、`value`、`data`
        
    - `maxFeePerGas`、`maxPriorityFeePerGas`（EIP-1559）或 `gasPrice`（Legacy）
        
- 在 Go 里就是 `types.LegacyTx` 或 `types.DynamicFeeTx`，再包成 `types.NewTx(txData)`。

---
## 🔍 2. 计算待签名哈希 (Message Hash / Digest)

- 用合适的签名器（`types.LatestSignerForChainID(chainId)`）。
    
- 调用 `signer.Hash(tx)` → 得到一个 **32字节哈希 (common.Hash)**。
    
- 这个值就是 **需要私钥签名的消息**。
    
- ⚠️ 注意：这里的 hash 已经包含 chainId，防止跨链重放（EIP-155）。
---
## ✍️ 3. 用私钥签名 (r, s, v)

- 拿私钥对这个哈希做 **ECDSA(secp256k1)** 签名。
    
- 得到 `(r, s, v)`：
    
    - `r`、`s` → 椭圆曲线签名结果。
        
    - `v` → 恢复位（y-parity），EIP-1559 下取 0 或 1。
        
- 最终拼成 65 字节：`r(32) || s(32) || v(1)`。
---

## 🔗 4. 把签名塞回交易

- 调用 `tx.WithSignature(signer, sigBytes)`，返回新的 `*types.Transaction`。
    
- 此时交易结构里已经带上 `(r, s, v)` 字段。
    

---

## 📦 5. 编码成 RawTx

- 用 `rlp.EncodeToBytes(signedTx)` 或 `signedTx.MarshalBinary()`。
    
- 得到 **rawTx（0x开头的 hex 字符串）**。
    
- rawTx 就是可以直接广播到节点的字节流。
    

---

## 🧾 6. 计算交易哈希 (TxHash)

- `signedTx.Hash()` = 交易的唯一标识。
    
- 区块里存的就是这个哈希。
    

---

## ⚙️ 整个链路（你的函数里对应）

1. **BuildDynamicFeeTx** → 构造 txData
    
2. **CreateEip1559UnSignTx** → 生成待签名哈希
    
3. **SignMessage** → HSM/KMS/私钥签哈希 → 65字节签名
    
4. **CreateEip1559SignedTx** → 塞回签名，得到已签名交易
    
5. **MarshalBinary** → 编成 rawTx
    
6. **Hash()** → 交易哈希
    

---

✅ **一句话总结：**  
签名流程就是  
**构造交易 → 算 digest → 私钥签名 (r,s,v) → 塞回交易 → 得 rawTx & txHash → 广播。**

---

要不要我帮你画一个 **“以太坊交易签名流程图”**（从 TxData 到 rawTx / txHash），一眼就能看出每个环节？

##### 
---
```
flowchart TD
    A[构造 TxData<br/>LegacyTx / DynamicFeeTx] --> B[NewTx(txData)]
    B --> C[选择 Signer<br/>LatestSignerForChainID(chainId)]
    C --> D[计算待签名哈希<br/>signer.Hash(tx)<br/>(digest, 32字节)]
    D --> E[私钥签名 digest<br/>ECDSA(secp256k1)]
    E --> F[得到 (r,s,v)<br/>拼成 65 字节签名]
    F --> G[塞回交易<br/>tx.WithSignature(signer, sig)]
    G --> H[编码 RawTx<br/>RLP / MarshalBinary]
    H --> I[已签名 RawTx (0x...)<br/>可直接广播到节点]
    G --> J[交易哈希 tx.Hash()<br/>链上唯一 ID]
```

---

## 流程解释

1. **TxData**：交易基本字段（nonce、to、value、gas…）。
    
2. **Signer**：根据链 ID 选合适签名规则（Legacy=EIP155Signer，EIP-1559=LondonSigner）。
    
3. **待签名哈希 (digest)**：对 TxData 规范化编码 + keccak256，结果 32字节。
    
4. **签名 (r,s,v)**：用私钥签 digest，得到 65字节签名（低S规范，v=0/1）。
    
5. **WithSignature**：把签名塞回交易结构，得到完整的已签名交易。
    
6. **RawTx**：RLP 编码，变成 0x 开头的字节串，可直接 `eth_sendRawTransaction`。
    
7. **TxHash**：`signedTx.Hash()`，交易的唯一标识，链上查询凭证。
---