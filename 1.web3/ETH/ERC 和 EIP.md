# ERC 和 EIP 是什么？

在以太坊（Ethereum）生态中，**ERC** 和 **EIP** 是两种不同但密切相关的标准/提案系统，它们用于推动整个 Ethereum 网络的**功能标准化与升级演进**。

---

## ✅ 一、什么是 EIP？

**EIP 全称：Ethereum Improvement Proposal（以太坊改进提案）**

它是对以太坊协议提出的**技术性改进建议**，包括：

- 核心协议更新（如合并、PoS）
    
- 虚拟机规范（EVM 规则）
    
- 智能合约接口标准（如代币、预言机接口）
    
- 网络安全增强、Gas 计算调整等

### 📚 举例：

|EIP 编号|内容|
|---|---|
|EIP-1559|引入基础手续费销毁机制（London 升级）|
|EIP-20|定义了 ERC-20 代币接口标准|
|EIP-721|定义了 NFT 接口（后来的 ERC-721）|
|EIP-4337|账户抽象（Account Abstraction）|
|EIP-2612|对 ERC-20 授权机制的扩展（支持签名）|

📌 所有 EIP 草案都发布在：https://eips.ethereum.org/

---

## ✅ 二、什么是 ERC？

**ERC 全称：Ethereum Request for Comments（以太坊征求意见稿）**

它是一类 **“面向应用层的 EIP”**，通常用于定义：

- 智能合约的接口规范（如代币标准）
    
- 如何实现可互操作的 DApps、钱包、交易所支持
    
- 一般由社区发起，用于制定“惯例标准”
    

💡可以简单记住：

> 所有 ERC 都是 EIP，但不是所有 EIP 都是 ERC。ERC 是特定领域的 EIP。

---

## 📦 三、ERC 和 EIP 的关系总结

|维度|EIP|ERC|
|---|---|---|
|全称|Ethereum Improvement Proposal|Ethereum Request for Comments|
|范围|全链协议、EVM、合约、钱包等|主要是智能合约标准（ERC-20、721）|
|目标|改进以太坊整体网络|定义应用层接口标准|
|类型|提案系统（技术提案）|应用标准（接口定义）|
|举例|EIP-1559、EIP-3074|ERC-20、ERC-721、ERC-1155、ERC-4626|

---

## 🧠 举个现实世界类比

可以类比 Web 世界的：

- **EIP ≈ HTML/CSS/HTTP 协议的 RFC 提案**
    
- **ERC ≈ JavaScript 框架的组件接口规范**
    

比如：

- EIP-20 是 Ethereum 层面的提案草案
    
- ERC-20 是它的代币接口实现标准（社区接受广泛后以“ERC”命名）
    

---

## ✅ 四、总结一句话

> **EIP 是 Ethereum 网络发展的“蓝图提案”，而 ERC 是应用层接口的“使用规范”，ERC-20、ERC-721 都来自于 EIP 的具体标准。**
