## 双花攻击
double spending attack 由于有帐户余额概念，可以防止双花攻击

replay attack

当前 nouce = 20
A -> B (10ETH) nonce = 21  signed by A
发送交易后 nouce = 21
通过交易数 如 nonce = 21 A 第21次交易, 可以防止再次发送该交易

## 帐户类型
externally owned account  外部帐户 (EOA)
本地产生公钥私钥来控制
有 balance 余额  nonce 计数器（counter）
交易只能由外部帐户发送

smart contract account
 也有 balance 余额  nonce 计数器
 但是不能主动发送交易，可以发送 msg 到另一个 smart contract account
 
code  storage 