以太坊交易格式演进的核心问题 👇

---
## 1. **Legacy 类型交易**（最早的格式）

这是以太坊从创世块开始用的传统交易格式。

字段大概是：

- `nonce`：账户发送的交易序号
    
- `gasPrice`：愿意支付的每 gas 价格（**单一字段**）
    
- `gasLimit`：最大可消耗的 gas
    
- `to`：目标地址（合约/外部账户）
    
- `value`：转账金额
    
- `data`：合约调用数据（可为空）
    
- `v, r, s`：签名字段

**特点：**

- 手动指定 `gasPrice`。
    
- 交易费 = `gasUsed * gasPrice`。
    
- Gas 市场是 **拍卖模式**：大家抬价拼 `gasPrice`，容易导致拥堵时手续费飙升。

---

## 2. **EIP-1559 类型交易**（London 升级后）

在 2021 年 8 月的 **London 硬分叉**中，引入了 **DynamicFeeTx**，即 EIP-1559 交易类型。

字段大概是：

- `chainId`
    
- `nonce`
    
- `gasTipCap` (=`maxPriorityFeePerGas`)：给矿工的小费（激励矿工优先打包）
    
- `gasFeeCap` (=`maxFeePerGas`)：用户愿意付的 **gas 单价上限**
    
- `gas`：最大可消耗的 gas
    
- `to`
    
- `value`
    
- `data`
    
- `accessList`：提前声明会访问的存储和地址（EIP-2930，引入访问列表优化）
    
- `v, r, s`：签名字段

**特点：**

- **两段式费用机制**：
    
    - **Base Fee**（由协议动态调整，**销毁**）
        
    - **Priority Fee (Tip)**（矿工可得）
        
- 用户只需设定一个 `maxFeePerGas`（最高能付多少）+ `maxPriorityFeePerGas`（给矿工多少），避免“乱拍卖”。
    
- 交易费 = `gasUsed * (baseFee + priorityFee)`，其中 baseFee 销毁，priorityFee 给矿工。

---
## 3. **关键区别对比**

|特性|Legacy Tx|EIP-1559 Tx|
|---|---|---|
|类型标识|无（默认）|有 type=2（DynamicFeeTx）|
|手续费字段|`gasPrice`|`maxFeePerGas` + `maxPriorityFeePerGas`|
|费用机制|全部给矿工|baseFee 销毁 + tip 给矿工|
|手续费波动|拍卖式，容易飙升|baseFee 动态调整，用户体验更稳|
|向后兼容|最老的格式|新链上主流（London 之后）|
|AccessList|不支持|支持（EIP-2930）|

---

## 4. 为什么要引入 EIP-1559

- **缓解手续费竞价大战**：有了 baseFee 自动调节，避免暴涨。
    
- **改善用户体验**：用户只要设定愿意接受的上限，交易能更快确认。
    
- **ETH 通缩模型**：baseFee 销毁，使 ETH 有“通缩压力”。
    
- **为未来扩展打基础**：和 EIP-2930（访问列表）配合，gas 估算更准确。
---
✅ **总结**

- **Legacy**：用 `gasPrice`，矿工全收，手续费完全市场拍卖 → 波动大。
    
- **EIP-1559**：用 `maxFeePerGas` & `maxPriorityFeePerGas`，协议收 baseFee 销毁，矿工收 tip，手续费更稳定 → 已成主流。