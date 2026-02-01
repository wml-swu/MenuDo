# Do it! — 四象限待办（艾森豪威尔矩阵）

基于艾森豪威尔矩阵的 macOS 待办应用，支持菜单栏常驻、四象限固定正方形布局。

---

## 直接下载使用（无需 Xcode，和其他 macOS 插件一样）

1. 打开本仓库的 **[Releases](https://github.com/你的用户名/priority_list/releases)** 页面  
2. 下载最新版本的 **Do-it-Release.zip**  
3. 解压得到 `priority_list.app`，拖到 **「应用程序」** 文件夹  
4. 从 **菜单栏右侧** 点击 Do it! 图标即可使用  

无需 clone、无需 Xcode、无需编译，和安装其他 macOS 插件一样。

> 若系统提示「无法验证开发者」：右键该 app → **打开**，再点 **打开**（仅首次需要）。

---

## Fork 参与开发（需要 Xcode）

1. **Fork** 本仓库到你的 GitHub 账号  
2. **Clone** 你的 fork：
   ```bash
   git clone https://github.com/你的用户名/priority_list.git
   cd priority_list
   ```
3. 用 **Xcode** 打开 `priority_list.xcodeproj`，选择 scheme **priority_list**，运行即可  

修改后可以提 PR 回上游，或在你自己的 fork 里打 tag 触发自动构建（见下方「发布流程」）。

---

## 发布流程（维护者：打 tag 即自动构建并上传 Releases）

把源码推送到 GitHub 后，按下面做即可让用户**直接下载使用**，无需在本地 Xcode 运行：

1. 在仓库里打一个 **tag**（例如 `v1.0.0`）并推送：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. **GitHub Actions** 会自动构建 macOS 应用，并上传 **Do-it-Release.zip** 到该 tag 对应的 **Release**  
3. 在 **Releases** 页面编辑该 Release，补充说明（可选）后发布  
4. 用户从 Releases 下载 zip 即可使用，和别的 macOS 插件一样  

这样：**用户可 fork 开发，也可直接下载使用，不需要在 Xcode 上运行。**

---

## 技术栈

- SwiftUI，macOS 15.7+
- 菜单栏：`MenuBarExtra`（仅菜单栏、不占 Dock）
- 数据：UserDefaults 持久化

详见 [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)、[DISTRIBUTION.md](DISTRIBUTION.md)。
