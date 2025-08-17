# 什么是函数选择器

函数选择器（Function Selector）是 Solidity 中用于标识特定函数的机制。它是函数签名的哈希值的前 4 个字节，主要用于在低级调用（如 call、delegatecall，staticcall）中指定要调用的目标函数。

**Selector**（函数选择器）是：

> 函数签名（signature）哈希值的前 4 个字节。

- **函数签名**是指函数名 + 参数类型（不包括返回值类型）。
- 然后用 `keccak256` 对这个签名字符串进行哈希，再取前 4 个字节。
```sol
function transfer(address recipient, uint256 amount) public returns (bool);
```
它的签名是:
` "transfer(address,uint256)" `

计算：
`keccak256("transfer(address,uint256)") = 0xa9059cbb...（共32字节）`

取前 4 字节：
`selector = 0xa9059cbb`

## 🤔 为什么需要 Selector？

以太坊的底层调用机制是通过向合约地址发送交易，并传递 **calldata（调用数据）** 来工作的。

- `calldata` 的前 4 字节 **就是 selector**，告诉合约你要调用哪个函数。
- 剩下的字节是参数的 ABI 编码。

**合约怎么知道你要调用哪个函数？**

1. 它读取 `msg.data` 的前 4 字节（即 selector）
    
2. 和合约里所有函数的 selector 对比
    
3. 找到匹配的函数，执行它