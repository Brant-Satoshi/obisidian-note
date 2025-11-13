- **大多数前端/Node 项目（单包或 Monorepo）**：选 **pnpm**（快、省磁盘、依赖更干净）。
    
- **需要最广兼容、团队成员不想装额外工具**：选 **npm**（Node 自带，够用）。
    
- **想用超严格的零 `node_modules` 管理（Plug’n’Play）或已有 Yarn 生态**：选 **Yarn（Berry v3+）**。但要评估三方工具兼容性。
    

---

# 三者核心差异一图流

|维度|npm|Yarn（v1 Classic / v3 Berry）|pnpm|
|---|---|---|---|
|安装速度/磁盘|中等|v1 中等；v3 快|**最快/最省**（硬链接+内容寻址全局仓库）|
|依赖结构|扁平化 hoist 到 `node_modules`|v1 同 npm；v3 默认 **PnP**（可配 node_modules）|**严格分层 + symlink**，避免意外跨依赖|
|兼容性|**最好**（行业默认）|v1 好；v3 PnP 需适配|很好，个别老包需配置 hoist|
|Monorepo|npm workspaces|Yarn workspaces（成熟）|**pnpm workspaces（强）**|
|锁定文件|`package-lock.json`|`yarn.lock`（v1/3 格式不同）|`pnpm-lock.yaml`|
|Peer deps|v7+ 自动安装|良好|良好（可配置）|
|离线安装|基础|v3 PnP 离线体验很强|有缓存，全局 store 复用|
|学习/上手|无成本|v1 低；v3 有新概念（PnP、constraints）|低（少量新概念：store/symlink）|

---

# 各自的“杀手锏”

- **pnpm**
    
    - **内容寻址全局仓库 + 硬链接**：多项目共享依赖，磁盘大幅节省。
        
    - **严格依赖解析**：防止“幽灵依赖”（A 能误用 B 的子依赖）。
        
    - **workspaces + filters**：在 Monorepo 中按包/依赖图选择性安装或运行脚本，很适合 Turborepo/Nx。
        
- **Yarn Berry（v3+）**
    
    - **Plug’n’Play（PnP）**：跳过 `node_modules`，解析更快、依赖边界最严格。
        
    - **Constraints/Packages 插件体系**：内置规则和工具链，超可定制。
        
- **npm**
    
    - **零门槛**：Node 自带，CI/CD 最稳妥。
        
    - v7+ 的 **workspaces**、**自动 peerDependencies**，功能已够用。
        

---

# 典型使用场景建议

- **Web 应用 / 组件库 / Node 服务（React、Vue、Next、Nest）**：→ **pnpm**
    
- **大型 Monorepo（多包共享依赖）**：→ **pnpm** 或 **Yarn v3**。若团队刚起步，优先 pnpm。
    
- **React Native / 某些需要真实 `node_modules` 的工具链**：→ **pnpm（nodeLinker=hoisted）** 或 **npm**。
    
- **对依赖边界要求极严、想禁用“隐式可用依赖”**：→ **Yarn v3 + PnP**。
    

---

# 常见命令对照表

|任务|npm|Yarn（v1/v3）|pnpm|
|---|---|---|---|
|初始化|`npm init -y`|`yarn init -y`|`pnpm init`|
|安装全部|`npm i`|`yarn`|`pnpm i`|
|安装依赖|`npm i lodash`|`yarn add lodash`|`pnpm add lodash`|
|安装开发依赖|`npm i -D typescript`|`yarn add -D typescript`|`pnpm add -D typescript`|
|删除依赖|`npm rm lodash`|`yarn remove lodash`|`pnpm remove lodash`|
|运行脚本|`npm run build`|`yarn build`|`pnpm build`|
|Monorepo 选择性执行|`npm -w pkga run test`|`yarn workspaces foreach`|`pnpm -F pkga test` 或 `pnpm -r run test`|

---

# Monorepo 快速起步（pnpm）

**pnpm-workspace.yaml**

`packages:   - packages/*   - apps/*`

**package.json**

`{   "private": true,   "packageManager": "pnpm@9",   "workspaces": ["packages/*", "apps/*"],   "scripts": {     "build": "pnpm -r build",     "dev": "pnpm -r --parallel dev",     "test:changed": "pnpm -r --filter ...[origin/main] test"   } }`

> 说明：`--filter` 可按依赖图/变更范围选择包，配合 Turborepo/Nx 很香。

---

# Yarn Berry 用或不用 PnP

- **默认 PnP** 无 `node_modules`，更快更干净，但某些工具（自定义解析、native 模块）需要适配。
    
- 若遇到兼容问题，可在 `.yarnrc.yml` 中切回：
    

`nodeLinker: node-modules`

---

# pnpm 与兼容性小贴士

- 极少数包假设“扁平 node_modules”并跨包 require：
    
    - 方案 A：`pnpmfile.cjs`/`packageExtensions` 定补丁
        
    - 方案 B：`.npmrc` 里启用 **hoist**：
        
        `shamefully-hoist=true`
        
- React Native 项目常这样配合：
    
    `node-linker=hoisted`
    

---

# CI/CD 与可复现性

- 三者都能锁定版本；CI 建议：
    
    - **npm**：`npm ci`
        
    - **Yarn**：`yarn install --immutable`（v3）
        
    - **pnpm**：`pnpm install --frozen-lockfile`
        
- 建议在仓库声明包管家版本，团队一致性更好：
    
    `corepack enable corepack prepare pnpm@9 --activate   # 或 yarn@3 / npm@10`
    

---

# 从 X 迁移到 Y（最简流程）

1. 清理：删除 `node_modules` 和旧锁（`package-lock.json` / `yarn.lock` / `pnpm-lock.yaml`）。
    
2. 选择工具并安装：`corepack prepare pnpm@9 --activate`
    
3. 安装：`pnpm install`（生成 `pnpm-lock.yaml`）
    
4. Monorepo 则补充 `pnpm-workspace.yaml`；遇兼容问题按上节小贴士处理。
    
5. CI 用 `pnpm install --frozen-lockfile`。
    

---

# 一句话决策树

- 追求**速度/省空间/Monorepo 体验** → **pnpm**
    
- 重视**普适兼容、零学习成本** → **npm**
    
- 需要**最严格依赖边界/PnP 特性** → **Yarn Berry**