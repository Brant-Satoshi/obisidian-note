
### 1. `buf.yaml`
作用：定义 **模块信息**

- 这是 **必须要有的文件**，告诉 Buf：
    - “proto 的根目录在哪”        
    - “依赖有哪些（deps）”
    - “模块名是什么（可选，用于发布到 BSR）”

```yaml
# buf.yaml（v2，放在仓库根）
version: v2
modules:
  - path: protobuf         # 这里就是你的 .proto 根目录
# 如需第三方依赖（例如 googleapis），加到 deps：
# deps:
#   - buf.build/googleapis/googleapis
# 可以在这里统一配置 lint/breaking 规则（可选）
# lint:
#   use: [STANDARD]
# breaking:
#   use: [FILE]
```
有了它，就能跑：
```bash
buf lint 
buf breaking
```

```yaml
# buf.gen.yaml
version: v1  
plugins:                    # 代码生成器列表；buf 会依次调用下面每个插件  
  - plugin: buf.build/protocolbuffers/go   # 使用 Buf 托管的 protoc-gen-go 插件（生成 *.pb.go：消息/枚举等）  
    out: .                             # 生成文件输出到当前目录为根  
    opt:                          # 传给插件的参数（等价于 protoc 的 --go_opt）  
      - paths=source_relative     # 生成文件相对 proto 源文件路径输出（与 proto 目录结构一致)
  - plugin: buf.build/grpc/go    # 使用 Buf 托管的 protoc-gen-go-grpc 插件
    out: .  
    opt:                         # 传给插件的参数（等价于 protoc 的 --go-grpc_opt）  
      - paths=source_relative               # 与 proto 源路径保持相对结构  
      - require_unimplemented_servers=false # 不强制要求服务实现嵌入 (默认 true)
```

生成代码
```yaml
version: v2
plugins:
  - remote: buf.build/protocolbuffers/go       # 等价于 protoc-gen-go
    out: .
    opt: [paths=source_relative]
  - remote: buf.build/grpc/go                  # 等价于 protoc-gen-go-grpc
    out: .
    opt:
      - paths=source_relative
      - require_unimplemented_servers=false
# 可选：开启 managed 模式时在这里配置 managed.enabled/override/disable
# managed:
#   enabled: true
```

```bash
buf generate
```

---
### 从 v1 快速迁移到 v2

Buf 提供了迁移命令，会把你仓库里的 v1 配置自动升级到 v2，并把 `buf.work.yaml` 合并到根的 `buf.yaml`：

```bash
# 在 Git 仓库根执行 
buf config migrate         # 直接迁移 
# 或先看差异
buf config migrate --diff
```

迁移后在仓库根跑：
```bash
buf build && buf lint
```
（官方迁移指引与命令见文档。[buf.build](https://buf.build/docs/migration-guides/migrate-v2-config-files/)）