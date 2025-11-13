# 1. **本地节点是什么？**

## 定义

本地节点是一个运行在开发者计算机上的 **以太坊区块链模拟器**，通过软件（如 Hardhat Network、Ganache）模拟以太坊虚拟机（EVM）和区块链的核心功能。它提供了一个隔离的、临时的区块链环境，开发者可以在其中部署 Solidity 智能合约、执行交易和测试 DApp，而无需连接真实的以太坊网络（如主网或测试网）。

- **Hardhat Network**：你使用的 `npx hardhat node` 启动的本地节点，是 Hardhat 提供的内置区块链模拟器，运行在 `http://127.0.0.1:8545`（默认 JSON-RPC 端口）。

- **特点**：
  - **轻量**：无需运行完整的以太坊客户端（如 Geth）。
  - **快速**：交易和区块生成几乎即时，无需等待网络确认。
  - **可控**：支持自定义账户、余额、区块时间等。
  - **隔离**：数据仅存在于本地，关闭节点后重置（除非配置持久化）。

## 功能

本地节点的用途已在你的前述问题中详细说明，简要总结如下：

1. **智能合约开发**：部署 Solidity 合约（如 Lock.sol），测试 external 函数（如 withdraw）。
2. **测试环境**：运行单元测试，验证合约逻辑，使用 Viem 或 Hardhat Ignition。
3. **DApp 开发**：连接前端工具（如 Viem、MetaMask），模拟用户交互。
4. **调试**：通过日志、console.log 和时间控制（如 evm_increaseTime）定位问题。
5. **主网分叉**：模拟主网状态，测试与现有合约的交互。

### 2. **本地节点的数据结构**

“数据结构”在区块链上下文中通常指区块链的核心组件（如区块、交易、状态）以及节点维护的数据组织方式。Hardhat Network 作为本地节点，模拟以太坊的数据结构，并以内存或文件形式存储。以下是本地节点数据结构的详细说明，分为 **区块链数据结构** 和 **Hardhat Network 特定存储** 两部分。

#### 2.1 **区块链数据结构**

本地节点模拟以太坊区块链，其数据结构与标准以太坊一致，包括以下核心组件：

1. **区块（Block）**：
    - **结构**：
        - **区块头（Header）**：
            - `parentHash`：父区块的哈希。
            - `stateRoot`：状态树的根哈希（存储账户状态）。
            - `transactionsRoot`：交易树的根哈希。
            - `receiptsRoot`：交易收据树的根哈希。
            - `number`：区块高度（从 0 开始）。
            - `timestamp`：区块生成时间（可通过 evm_setTime 控制）。
            - `gasLimit`：区块 gas 限制。
            - `gasUsed`：已使用 gas。
            - `miner`：矿工地址（本地节点中通常为零地址）。

        - **交易列表**：包含区块内的所有交易。

    - **本地节点特点**：
        - 区块按需生成（即有交易时才创建新区块）。
        - 默认没有自动挖矿，可通过 evm_mine 手动触发或启用 autoMine: false 模拟真实网络延迟。

    - **存储**：保存在内存中，关闭节点后清空（除非配置持久化）。

2. **交易（Transaction）**：

    - **结构**：
        - `from`：发送者地址（如 Hardhat 默认账户）。
        - `to`：接收者地址（合约地址或 EOA）。
        - `value`：转账金额（以 wei 为单位）。
        - `data`：交易数据（如合约调用或部署字节码）。
        - `gasLimit`：最大 gas 限制。
        - `gasPrice` 或 `maxFeePerGas/maxPriorityFeePerGas`（EIP-1559）。
        - `nonce`：发送者的交易计数。
        - `signature`：交易签名（本地节点中由测试账户私钥生成）。

    - **本地节点特点**：
        - 交易由本地节点处理，无需真实签名（测试账户私钥已知）。
        - 支持 EIP-1559 和传统交易。
        - 失败交易（如 `revert`）会记录详细错误（如 `Not yet unlocked`）。

    - **存储**：交易存储在区块中，收据（receipt）记录执行结果（如事件日志）。

3. **状态（State）**：

    - **结构**：

        - **账户状态**：
            - balance：账户余额（默认 10,000 ETH）。
            - nonce：交易计数。
            - code：合约字节码（对于合约账户）。
            - storage：合约存储（键值对，存储变量如 `Lock.unlockTime`）。

    - **状态树**：
        使用 Merkle Patricia Trie 组织账户状态，stateRoot 是树的根哈希。

    - **本地节点特点**：
            - 初始化 20 个测试账户，余额可通过 hardhat.config.ts 配置。
            - 合约状态（如 Lock 的 unlockTime 和 owner）在部署后更新。
            - 支持 `evm_setNextBlockTimestamp` 修改时间，影响状态（如 `block.timestamp`）。

    - **存储**：状态保存在内存中，节点重启后重置。

4. **事件日志（Logs）**：
    - **结构**：
        - address：发出事件的合约地址。
        - topics：事件签名和索引参数。
        - data：非索引参数。
        - blockNumber：事件所在区块高度。
    - **本地节点特点**：
        - 支持 Solidity 事件（如 Transfer、Approval），通过 Viem 的 getLogs 查询。
        - Hardhat 的 console.log 输出到节点日志，方便调试。

5. **链数据**：

    - **结构**：
        - 区块链是一个区块链表，通过 parentHash 连接。
        - 每个区块包含交易、状态更新和事件。

    - **本地节点特点**：
        - 默认链 ID 为 1337（可配置）。
        - 支持分叉模式，复制主网的链数据（通过 forking 配置）。

---

#### 2.2 **Hardhat Network 特定存储**

Hardhat Network 在本地节点中维护额外的数据，用于支持开发和调试。这些数据不完全是区块链核心数据，而是与开发工具相关：

1. **账户数据**：
    - **结构**：
        - 20 个默认账户（地址和私钥）。
        - 示例：

    ```solidity
    Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
    Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
    ```

    - **存储**：内存中，基于配置的种子生成（hardhat.config.ts 中的 accounts）。
    - **用途**：用于部署合约（如 Lock）、发送交易或测试 external 函数。

2. **数据结构的具体示例（基于 Lock 合约）**

##### 运行流程与数据结构

1. **启动本地节点**（npx hardhat node）：
    - 初始化内存数据库，创建 20 个账户。
    - 区块链状态：空链，blockNumber: 0，stateRoot 为初始状态。

2. **部署 Lock 合约**（`npx hardhat ignition deploy ./ignition/modules/Lock.ts --network localhost`）：
    - **交易**：
        - to: null（创建合约）。
        - data：包含 Lock 合约的字节码和构造函数参数（unlockTime）。
        - value：1_000_000_000（1 Gwei，来自 LockModule）。
    - **区块**：
        - 新区块生成，包含部署交易。
        - stateRoot 更新，记录新合约的状态。
    - **状态**：
        - 合约地址（如 0x5FbDB2315678afecb367f032d93F642f64180aa3）。
        - 存储变量：
            - unlockTime：1893456000（2030-01-01）。
            - owner：部署者的地址（如 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266）。
            - balance：1_000_000_000 wei。
    - **日志**：
        - Ignition 生成 journal.jsonl，记录 LockModule#Lock 的部署。
