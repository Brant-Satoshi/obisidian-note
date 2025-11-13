### 1.`Call`

用法
```solidity
(bool success, bytes memory data) = target.call(
    abi.encodeWithSignature("foo(uint256)", 123)
);
```
- **最常用**方式，低级调用。
    
- 会执行目标合约中的代码。
    
- `msg.sender` 是外部调用者。
    
- 可发送 `ETH`。
    
- 能调用不存在的函数（注意 fallback 执行）。
- 调用结果需要手动检测返回值d

✅ 用于调用外部合约函数或转账。
### 2. `delegatecall`

solidity

复制编辑
```sol
(bool success, bytes memory data) = target.delegatecall(
	abi.encodeWithSignature("foo(uint256)", 123) 
);
```

- **在当前合约的上下文中执行目标合约的代码**。
    
- 被调用代码 **可以修改调用者合约的状态变量**。
    
- `msg.sender` 和 `msg.value` 仍保持外部调用者的值。
    
- 目标合约的 `storage`、`address(this)` 不会被用到。
    

✅ **用于代理合约**（Proxy Pattern），合约升级场景。

### 3. `staticcall`

solidity

```sol
(bool success, bytes memory data) = target.staticcall( 
	abi.encodeWithSignature("getValue()") 
);
```

- 用于只读调用。
    
- 如果尝试修改状态，则 **会 revert**。
    
- `msg.sender` 不变。
    
- 类似于 view 函数的低级版本。
    

✅ 用于安全读取外部合约的数据，防止状态污染。
### 4. `multicall`（工具函数 / 合约）

```sol
function aggregate(Call[] calldata calls) external returns (uint256 blockNumber, bytes[] memory returnData)
```

通常不是原生方法，而是一个合约工具（如 Uniswap 的 Multicall 合约），通过一次调用批量执行多个合约函数，常用于：

- 多数据读取
    
- 多步交易组合
    
- 节省调用开销

例如：
`struct Call {     address target;     bytes callData; }`

✅ 场景：读取多个余额、价格等，不需要多次 RPC 请求。

|方法|作用|使用者上下文|状态修改|`msg.sender`|`address(this)`|使用场景|
|---|---|---|---|---|---|---|
|`call`|调用其他合约（最常用）|被调用合约|✅ 可修改|外部调用者|被调用合约地址|跨合约调用（灵活）|
|`delegatecall`|在调用者上下文中执行被调逻辑|调用者合约|✅ 可修改|外部调用者|调用者合约地址|代理合约、合约升级|
|`staticcall`|只读方式调用其他合约|被调用合约|❌ 不可改|外部调用者|被调用合约地址|查询数据（保障安全）|
|`multicall`|一次批量执行多个函数|多样|✅ / ❌|根据内部方法|各自上下文|多调用合约节省 gas|
