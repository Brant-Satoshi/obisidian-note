# Continuous Integration 持续集成

每次你把代码提交到远程仓库（比如 GitHub/GitLab），系统会**自动拉取代码、编译、测试、检查**，保证代码质量。

---
## 为什么需要 CI

没有 CI 的团队开发会有这些问题：

- 代码能不能编译过？ → 要等到上线才发现错误。
    
- 新人写的代码规范对不对？ → 要靠人工 review。
    
- 修改 proto 文件会不会破坏兼容性？ → 没有自动检查。

有了 CI：

- 每次提交自动运行 `go test` / `buf lint` / `buf breaking`；
    
- 发现错误，提交会直接标红，开发者立刻修；
    
- 保证主分支始终是**可编译、可运行**的。
---
## CI 的常见平台

- **GitHub Actions**（GitHub 自带）
    
- **GitLab CI**（GitLab 自带）
    
- **Jenkins**（传统自建 CI 工具）
    
- **CircleCI、Travis CI、Drone CI**（第三方 SaaS）
---
## 常见流程（以 Go + Buf 项目为例）

1. **开发者提交代码**
    
    `git push origin main`
    
2. **CI 自动触发**
    
    - 拉取最新代码
        
    - 安装依赖（Go, Buf）
        
    - 执行检查：
        
        - `go build && go test`
            
        - `buf lint`
            
        - `buf breaking --against '.git#branch=main'`
            
3. **结果反馈**
    
    - 绿色 ✅：代码没问题
        
    - 红色 ❌：代码有错误（比如 lint 不过），开发者必须修改
---
## 举个 GitHub Actions 的例子

放在 `.github/workflows/ci.yml`：

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: 1.22
      - name: Run Go tests
        run: go test ./...

      - name: Setup Buf
        uses: bufbuild/buf-setup-action@v1
      - name: Run buf lint
        run: buf lint
      - name: Run buf breaking check
        run: buf breaking --against '.git#branch=main'
```

这样，每次提交或 PR 都会自动执行这些检查。

---

✅ **总结**：

- CI = 持续集成，就是**自动化编译 & 测试**。
    
- 作用：保证每次提交的代码都健康。
    
- 在你现在的 **proto + Go 项目**里，CI 可以帮你自动跑 **`buf lint`、`buf breaking`、`buf generate`、`go test`**。