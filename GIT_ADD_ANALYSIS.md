# priority_list 目录：需要 add 的文件分析

## 一、需要 add 的文件（应提交到 Git）

| 路径 | 说明 |
|------|------|
| **.gitignore** | 忽略规则，必须提交 |
| **README.md** | 仓库说明与使用方式 |
| **.github/workflows/release.yml** | 打 tag 自动构建并上传 Releases |
| **scripts/build-release.sh** | 本地打包脚本 |
| **scripts/ExportOptions.plist** | 导出 .app 的选项 |
| **priority_list.xcodeproj/project.pbxproj** | Xcode 工程配置 |
| **priority_list.xcodeproj/project.xcworkspace/contents.xcworkspacedata** | 工作区配置 |
| **priority_list/ContentView.swift** | 主界面与四象限 UI |
| **priority_list/priority_listApp.swift** | 应用入口与菜单栏 |
| **priority_list/TodoStore.swift** | 数据模型与持久化 |
| **priority_list/Assets.xcassets/Contents.json** | 资源目录 |
| **priority_list/Assets.xcassets/AccentColor.colorset/Contents.json** | 强调色 |
| **priority_list/Assets.xcassets/AppIcon.appiconset/Contents.json** | 应用图标配置 |

若存在 **DEVELOPMENT_PLAN.md**、**DISTRIBUTION.md**，也应一并 add（文档）。

---

## 二、会被 .gitignore 排除（不要 add）

| 路径 / 规则 | 原因 |
|-------------|------|
| **xcuserdata/** | Xcode 用户数据（窗口、scheme 等），每人本机不同 |
| **\*.xcuserstate** | Xcode 界面状态 |
| **build/** | 构建产物，可随时重新生成 |
| **DerivedData/** | Xcode 派生数据 |
| **\*.zip**、**\*.dmg** | 发布包，由 CI 或本地脚本生成 |
| **.DS_Store** | macOS 目录元数据 |

当前目录下会被忽略的示例：
- `priority_list.xcodeproj/xcuserdata/dadaguaijiangjun.xcuserdatad/xcschemes/xcschememanagement.plist`
- `priority_list.xcodeproj/project.xcworkspace/xcuserdata/.../UserInterfaceState.xcuserstate`

---

## 三、推荐操作

在项目根目录执行：

```bash
cd /Users/dadaguaijiangjun/code/priority_list
git add .
git status
```

`git add .` 会按 `.gitignore` 自动排除上面「不要 add」的文件；`git status` 里应只出现「需要 add」的那些路径。确认无误后：

```bash
git commit -m "Initial commit"
git push origin main
```

这样只会把源码、工程、脚本、文档和 CI 配置提交上去，不会带上构建产物和本机用户数据。
