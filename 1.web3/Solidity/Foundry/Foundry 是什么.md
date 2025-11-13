`Foundry` 是一个用于以太坊智能合约开发的现代化、极速开发工具集，由 Paradigm 开发，完全用 Rust 编写。它是 Hardhat 和 Truffle 的强力替代方案，特别适合追求速度、模块化、原生命令行体验的开发者。

|工具|作用|
|---|---|
|`forge`|智能合约编译、测试、部署、分析（核心工具）|
|`cast`|与链交互、发送交易、签名、调用合约（类似 ethers.js 但是 CLI）|
|`anvil`|本地以太坊测试节点，支持自动矿工、状态跟踪、模拟主网等（替代 Ganache）|
|`chisel`|新增的 Yul（底层 EVM 汇编）代码工具（较高级）|
forge test
- `-v`：显示更详细日志
    
- `-vv`：显示 trace
    
- `-vvv`：显示 setup traces
    
- `-vvvv`：**显示 `console.log` 输出** ✅
## call 的使用

```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

  

contract Caller {

function callSetNumber(address _target, uint256 _number) public {

(bool success, ) = _target.call(

abi.encodeWithSignature("setNumber(uint256)", _number)

);

require(success, "call setNumber is failed");

}

  
function callIncrement(address _target) public {

(bool success, ) = _target.call(

abi.encodeWithSignature("increment()")

);

require(success, "call increment is failed");

}

}
```