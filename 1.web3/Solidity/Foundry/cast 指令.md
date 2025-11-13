```bash
# 生成新钱包（私钥/助记词）
cast wallet new

# 查余额
cast balance <address> -r <rpc-url>

# 查 nonce
cast nonce <address> -r <rpc-url>

# 转账（EIP-1559）
cast send <to> --value 0.01ether -r <rpc-url> --private-key <hex-privkey>

# 调用合约只读函数
cast call <contract> "balanceOf(address)" <addr> -r <rpc-url>

# 查询合约代码/是否为合约
cast code <address> -r <rpc-url>
```