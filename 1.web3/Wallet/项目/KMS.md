# Key Management Service

#### Google Cloud KMS（Key Management Service）

- 全称 **Google Cloud Key Management Service**，是 Google 提供的一个 **密钥管理与硬件安全模块 (HSM) 服务**。
    
- 功能：
    
    - 安全生成和存储密钥（对称 / 非对称，RSA、EC、AES 等）；
        
    - 提供加密、解密、签名、验签等操作接口；
        
    - 支持密钥轮换、权限管理、审计日志；
        
    - 后端由 **HSM 硬件**保障密钥不会泄露（应用层看不到私钥，只能调用 API）。
        
- 在区块链/以太坊场景下，你可以用它托管私钥，然后通过 `AsymmetricSign` 来替代本地 `ecdsa.Sign`。

- **Cloud KMS 服务** = Google 的后台系统（真正的 HSM、密钥库）。
    
- **Go 客户端 `cloud.google.com/go/kms/apiv1`** = 你写代码时调用的 SDK（封装了 RPC）。
    
- **`kmspb` 包** = SDK 用到的请求/响应数据结构（protobuf 生成）。
-
👉 可以理解为：Cloud KMS 是「Google 的云端托管 HSM」。

`kms` 就是 **Google Cloud KMS 的 Go SDK 客户端**，用来和 **Google Cloud Key Management Service（密钥管理服务）** 通信。