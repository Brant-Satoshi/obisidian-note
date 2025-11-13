## **ABI（Application Binary Interface，应用二进制接口）**
用 Go 写链上交互，这些规则直接决定怎么打包 `tx.Data`、怎么解析返回值和事件日志。

# ABI 是什么

- **合约与外部世界的“约定”**：规定了函数/事件的**命名、参数类型**以及**二进制编码方式**。
- **用在哪儿**：
    
    1. 交易输入数据（`tx.data`，也叫 calldata）的编码/解码
        
    2. 函数返回值的解码（`eth_call` 的返回）
        
    3. 事件日志（logs）的编码/解码

# ABI 的四块核心

## 1) 函数选择器（function selector）

- 选择器 = `keccak256("函数名(参数类型列表)")` 的**前4字节**。
    
- 例：`transfer(address,uint256)` → `0xa9059cbb`  
    `safeTransferFrom(address,address,uint256)` → `0x42842e0e`
    
- 注意：**没有空格、类型全小写、必须写全**（重载函数通过类型区分）。

## 2) 参数编码（calldata 布局）

- EVM 是 **256-bit（32字节）字长**，ABI 以 **32字节为单位（slot）**对齐。
    
- **静态类型**（固定长度）：
    - `uint<M>/int<M>`、`address`、`bool`、`bytes<M>`（M≤32）、**定长数组**（元素若静态则整体静态）、tuple(全静态)…
    - 编码：**占一个或若干 32B slot，按大端左填充零**（例如 `address` 左填充到 32B；`bytes<M>` 右侧填充到整 32B）。
- **动态类型**：
    
    - `bytes`、`string`、**动态数组** `T[]`、tuple(含动态成分)
        
    - **调用处位置**先放一个 **offset**（相对整个参数区的偏移，单位字节）；  
        在 offset 指向的位置：先写 **长度**（以元素/字节为单位），再写 **数据本体**，末尾**右填充到 32B**。
        
- **返回值**：使用同一套编码（只是没有 4 字节选择器）。
    

### 小例子（静态参数）

```less
transfer(address,uint256)  
calldata = `[4B 选择器] [to 32B] [amount 32B]`
```
### 小例子（动态参数）
```less
`setName(string)`，参数 `"alice"`：

```less
[4B 选择器]
[0x20]                      // 第1个参数是动态类型 → 放偏移 0x20
[0x05] [ "alice" ] [padding] // 偏移处：长度=5，随后是数据和填充
```

## 3) 事件编码（logs）

- 事件签名主题（topic0）= `keccak256("EventName(type1,type2,...)")`。
    
- `indexed` 参数进 **topics**（动态类型会放其 keccak 哈希）；非 indexed 参数按 ABI 规则**编码在 data 里**。
    
- 解码日志要用 ABI 定义的事件原型。
    

## 4) 函数/错误签名与重载

- 函数重载靠**完整签名**区分（`foo(uint256)` vs `foo(string)`），选择器不同。
    
- 常见错误选择器：`Error(string)` 的选择器是 `0x08c379a0`（revert reason 常见）。
    

# 常见类型的编码要点（速查）

- `address`：20B → **左填充**到 32B
    
- `uint256/int256`：大端表示，**左填充**到 32B
    
- `bool`：`0/1`，**左填充**到 32B
    
- `bytes<M>`（定长 ≤32）：右填充到 32B
    
- `bytes` / `string`：**offset → [length][data][padding]**
    
- `T[]`：**offset → [length][elem0][elem1]…**（元素各自按规则编码）
    
- tuple：把内部成员按顺序“摊平”，内含动态类型时同理放 offset
    

# 典型坑位

- **签名里多空格/大小写不一致** → 选择器错（比如 `"transfer(address, uint256)"` 是错的）。
    
- **把 `encodePacked` 当 `encode` 用**：`encodePacked` 是紧凑拼接，**不按 32B 对齐**，只适合哈希/签名场景，**不适合 calldata**。
    
- **动态参数 offset 计算错**：offset 相对整个参数区起点（紧跟在 4B 选择器之后）。
    
- **bytes vs bytes32 混淆**：`bytes32` 是定长静态；`bytes` 是动态。
    
- **EIP-1559 签名的 v 值**：是 **y-parity（0/1）**，不是 27/28。

## 为什么需要 ABI
### 1. EVM 本质上只认 **字节流**

- 以太坊虚拟机 (EVM) 处理的是非常底层的 **字节流**：交易的 `data` 字段就是一串 `0x...`。
    
- 但我们在写合约时用的是 **Solidity 函数/参数**（比如 `transfer(address,uint256)`）。
    
- **ABI 的作用就是把“人类友好的函数调用”翻译成“EVM 能读的字节流”**，反之也一样。
    

没有 ABI：

- 调用 `transfer(to, amount)`，EVM 根本不知道哪个字节是函数、哪个字节是地址、哪个字节是数额。
    
- 只能靠 ABI 规则才能编码/解码正确。

---

## 2. 为什么必须有统一标准

想象一下：

- 假设每个开发者都自己规定参数怎么拼接（比如有人左补零，有人右补零），那不同钱包、不同节点根本没法互通。
    
- ABI = **统一的语言**，让钱包、DApp、节点、合约彼此都能理解。
---
## 3. ABI 的作用场景

### (1) 交易调用 (calldata)

- 你在 MetaMask 点“转账 1000 USDT” → 钱包会用 **ABI 规则**把 `transfer(address,uint256)` 编码成 `0xa9059cbb...` 这种字节流 → 发给链上。
    
- 合约在链上运行时，也会按照 ABI 规则去解析。

### (2) 读取返回值

- 调用 `balanceOf(address)`，节点返回一串字节。
    
- ABI 告诉你：这是一条 `uint256` → 你才能正确解码成人能看的余额。
    

### (3) 事件日志 (logs)

- 合约里 `emit Transfer(from, to, value)`，节点只会存字节。
    
- ABI 告诉你：第一个 topic 是 `from` 地址，第二个是 `to`，data 是 `value` → 区块浏览器才能展示“从A转给B多少币”。
    

---

## 4. 开发中的意义

- **写合约**：编译 Solidity → 得到 ABI JSON 文件，里面描述所有函数/事件的签名和参数类型。
    
- **前端/Go 程序调用**：加载 ABI → 用 `abi.Pack` 自动编码参数、生成正确的 `data`，再发交易。
    
- **解码**：用 `abi.Unpack` 从交易返回值或事件日志里还原出 `address`、`uint256` 等。
    

---

## 5. 为什么需要它？

一句话总结：

👉 **因为以太坊是字节码机器，ABI 是把“人能理解的函数调用/数据” ↔ “EVM能执行的字节流”的唯一桥梁。**

没有 ABI：

- 你得手写拼接字节（容易错，几乎不可维护）。
    
- 不同钱包/SDK 之间无法兼容。
    

有了 ABI：

- 所有工具链（MetaMask、ethers.js、web3.go、etherscan …）都能说同一种语言。