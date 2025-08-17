### 使用 The Graph 的步骤：

1. **写一个 Subgraph（子图）**
    
    - 定义你想抓取的合约地址、事件、状态（比如 `Transfer` 事件）
        
    - 编写一个 `subgraph.yaml` 配置文件
        
    - 写一个 `schema.graphql` 定义结构（类似数据库结构）
        
    - 写 `mapping.ts` 文件，用 AssemblyScript 处理链上数据映射
        
2. **部署到 The Graph 协议上**
    
    - 可以部署到 Hosted Service（托管服务）
        
    - 也可以部署到去中心化网络（The Graph Network）
        
3. **DApp 中调用 GraphQL API**
    
    - 查询你定义的子图数据
        
    - 非常快，非常方便，响应像数据库一样
        

---

### ✅ 示例应用场景

- NFT 项目要展示每个用户的持有情况（从链上抓 `Transfer` 事件）
    
- 去中心化交易所（DEX）要显示历史交易记录
    
- Staking 平台要显示用户质押总量和奖励