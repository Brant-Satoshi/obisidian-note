## 一、项目初始化与依赖管理
- `forge init <name>`：创建标准项目骨架（含 `src/ test/ script/ foundry.toml` 等）。
    
- `forge install <repo>[@tag]`：安装 Git 依赖到 `lib/`（默认作为子模块）。常用：`forge install foundry-rs/forge-std`。支持 `--no-git`（不使用子模块）或 `--no-commit`。
    
- `forge update`：更新 `lib/` 中依赖到目标版本/分支。
    
- `forge remove <repo>`：移除已安装依赖。
    
- `forge tree`：打印依赖树与版本。
    
- `forge remappings`：查看/生成 remappings；也可直接在 `foundry.toml` 里写 `remappings = [...]`。
    
- `forge config`：查看当前生效配置（合并了默认值、环境变量和 `foundry.toml`）。
---
## 二、编译与构建

- `forge build`（或 `forge b`）：编译项目并产出到 `out/`。  
    常用参数：
    - `--optimize` / `--optimizer-runs <N>`、`--via-ir`（走 Yul IR 管线）
        
    - `--sizes`（显示合约字节码大小）、`--names`
        
    - `--extra-output(-files)`（如 `storageLayout`, `abi`, `ir` 等）
        
    - `--use <solc>`、`--evm-version`、`--no-auto-detect`、`--offline`
        
    - 监听编译：`--watch`
        
    - 指定库地址：`--libraries src/Lib.sol:Lib:0x...`  
        以上均为官方参数。

- `forge clean`：清缓存与产物。
    
- `forge inspect <path:Contract> <field>`：查询 ABI、字节码、`storage-layout`、`methods` 等编译输出（对排查存储布局/事件/函数签名超好用）。
    
- `forge fmt`：Solidity 格式化（支持 `--check`、按 `foundry.toml` 设置）。
---
## 三、测试与调试

- `forge test`：运行 Foundry 测试  
    常用筛选：
    - `--match-test <regex>`、`--match-contract <regex>`、`--match-path <glob>`
        
    - `--list`（仅列出测试）、`--json`  
        执行环境：
        
    - `--fork-url <RPC>`（分叉主网/测试网），可配 `--fork-block-number`
        
    - `-v/-vv/-vvv/-vvvv/-vvvvv`（日志/回溯详细级别）
        
    - `--gas-report`（打印 Gas 报告）
        
    - `--ffi`（启用 FFI cheatcode）  
        还有区块参数、链 ID、初始余额等 executor 选项。
        
- `forge snapshot`：生成/对比 Gas 快照（CI 里监控回归常用）。
    
- `forge coverage`：覆盖率（支持 lcov 等报告）。
    
- `forge debug`：交互式调试某个测试或交易（结合 `--debug <TEST>` 打开）
---
## 四、脚本执行、部署与验证

- `forge script <path:ContractScript>`：执行 Solidity 脚本；  
    典型部署（EIP-1559）：

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url $RPC_URL --broadcast \
  --ledger # 或 --private-key $PK / --mnemonic-path ... 
```

可配 --verify 自动验证、--resume 续播失败步骤、-vvvv 提升日志、--sender、硬件钱包 --ledger/--trezor 等。

`forge create <path:Contract>` ：一条命令部署合约（更推荐用 forge script 做可重复化部署）。

`forge verify-contract <address> <path:Contract>` :
在 Etherscan/区块浏览器验证源码（需 --etherscan-api-key/--verifier-url；脚本也可 --verify 一把梭）。

`forge flatten <path:Contract>` ：源码扁平化（有时审计/人工验证方便）。

```bash
# 初始化与依赖
forge init myproj
git init && forge install foundry-rs/forge-std@v1.9.6 --no-commit
forge update && forge tree && forge remappings

# 编译与信息
forge build --via-ir --optimize --optimizer-runs 200
forge inspect src/Token.sol:Token abi
forge fmt --check

# 测试与气体
forge test -vvv --gas-report
forge test --match-contract TokenTest --match-test "test*"
forge test --fork-url $RPC --fork-block-number 20000000

# Gas 快照 / 覆盖率
forge snapshot
forge coverage --report lcov

# 部署与验证（推荐 script）
forge script script/Deploy.s.sol:Deploy \
  --rpc-url $RPC --broadcast --verify -vvvv \
  --ledger   # 或 --private-key $PK / --mnemonic-path ...

# 一次性部署（不建议长期用）
forge create src/Token.sol:Token --rpc-url $RPC --private-key $PK

# 其他
forge flatten src/Token.sol > flat/Token.flattened.sol
forge config
```

## 五、工具与实用命令

- `forge geiger`：静态分析（检测潜在危险操作模式）。[登链社区](https://learnblockchain.cn/docs/foundry/i18n/en/reference/forge/forge-geiger.html)
    
- `forge bind`：生成多语言绑定（如给前端/后端使用的接口）。
    
- `forge doc`：生成文档网站。
    
- `forge cache` / `forge cache ls | clean`：管理编译缓存。

## 六、配置文件与多配置档（profiles）

- `foundry.toml` 支持多配置档：
```toml
[profile.default]
optimizer = true
optimizer-runs = 10_000
via_ir = true

[profile.lite]
optimizer = false
```
通过环境变量切换：`FOUNDRY_PROFILE=lite forge test`。编译器、IR、优化器、额外输出、稀疏编译（`sparse_mode`）等都在 `build/test/script` 三命令中生效。

## 七、常见坑位与解决（结合你之前的报错）

1. **`forge install` 报 “fatal: not a git repository ... / submodule exited with code 128”**

- 发生原因：`forge install` 默认把依赖作为 **Git 子模块** 写入项目，需要当前目录是 Git 仓库。
- 解决：先 `git init`（或用 `forge init` 新建工程），再执行 `forge install`。若不想用子模块，可加 `--no-git`；若不想自动提交，用 `--no-commit`。

2. **事件/函数名不匹配（如 `emit Counter.NumberChanged` 找不到）**
    
- 用 `forge inspect <path:Contract> abi`/`methods`/`events` 确认真实签名与名字；也可检查是否在测试里 `using for`/继承层级导致命名空间和可见性问题。
    

3. **测试过滤与调试**
    
- 只跑某合约或某测试：  
    `forge test --match-contract CounterTest --match-test "testIncrement*"`
    
- 交互调试：  
    `forge test --debug testIncrement -vvvv`（或 `forge debug` 针对交易/测试）。

4. **主网状态下复现问题**
    - 分叉测试：`forge test --fork-url $MAINNET_RPC --fork-block-number 20_000_000`，结合 `--gas-report` 看真实消耗
---
## 常用命令速查清单
```bash
# 初始化与依赖
forge init myproj
git init && forge install foundry-rs/forge-std@v1.9.6 --no-commit
forge update && forge tree && forge remappings

# 编译与信息
forge build --via-ir --optimize --optimizer-runs 200
forge inspect src/Token.sol:Token abi
forge fmt --check

# 测试与气体
forge test -vvv --gas-report
forge test --match-contract TokenTest --match-test "test*"
forge test --fork-url $RPC --fork-block-number 20000000

# Gas 快照 / 覆盖率
forge snapshot
forge coverage --report lcov

# 部署与验证（推荐 script）
forge script script/Deploy.s.sol:Deploy \
  --rpc-url $RPC --broadcast --verify -vvvv \
  --ledger   # 或 --private-key $PK / --mnemonic-path ...

# 一次性部署（不建议长期用）
forge create src/Token.sol:Token --rpc-url $RPC --private-key $PK

# 其他
forge flatten src/Token.sol > flat/Token.flattened.sol
forge config
```