# Archive Reader · Flutter 工程

一个更舒服的 AO3 阅读器的安卓客户端（**非官方**，不托管任何作品内容）。

这个工程的目标是：**你先能装到手机上摸一摸**，界面/交互全部按前面定稿的原型实现；
数据暂时用内置演示数据，下一步再把 AO3 真实抓取接进 `data/` 层。

---

## 一、这个版本里有什么（都是真能用的）

| 模块 | 状态 |
|---|---|
| 登录页（含右上角深色切换 + 设置入口） | ✅ 可点，走本地状态 |
| 发现页卡片流 + 搜索 + 筛选 chips（完结/连载/有译文/短篇）+ 排序 | ✅ 真在本地过滤排序 |
| 作品详情页（渐变头图、摘要、标签、章节列表、开始阅读/译文/收藏） | ✅ |
| 阅读器：**上下滑动 / 左右翻页** 两种模式，翻页无动画 | ✅ 分页是真按屏幕高度算的 |
| 阅读页快捷设置（字号、背景透明度、正文衬底、色相） | ✅ |
| 整页「阅读设置」：字号/字体/应用范围/纸色/主题色/背景图/透明度/模糊/翻页方式 | ✅ |
| **自定义字体导入**（.ttf/.otf/.woff2），导入后全站立刻生效，重启后自动重新注册 | ✅ |
| 自定义背景图（相册选图）+ 首页/阅读页分别的透明度 + 正文衬底 | ✅ |
| 所有设置持久化（SharedPreferences + 应用私有目录） | ✅ |
| AO3 真实抓取 / 登录 Cookie / 翻译引擎 / 离线书库 | ⏳ 还没接（下一步） |

---

## 二、上传到 GitHub 出 APK（你已经很熟练的那套）

1. GitHub 新建一个 **Private** 仓库
2. 把这个文件夹里的**所有文件**拖上去
   > ⚠️ `.github` 是隐藏文件夹，一定要一起传（它是自动编译的配置）。
   > Mac 上按 `Cmd+Shift+.` 可以显示隐藏文件。
3. 传完会自动开始编译；也可以去 **Actions → Build APK → Run workflow** 手动点一次
4. 等 8～15 分钟 → 在 **Artifacts** 下载 `app-release-apk` → 解压得到 `app-release.apk`
5. 传到手机安装（允许一次「未知来源」）

---

## 三、签名（已经给你配好了，可以一直覆盖安装）

工程里**已经内置了一个正式签名**，你不用做任何配置：

```
android/key.properties          # 口令、alias 指向下面这个文件
android/app/ao3-release.jks     # 签名文件（有效期到 2056 年）
```

- 口令：`ao3reader2026`
- alias：`ao3`
- 证书 SHA-256：`C8:2A:61:EC:0F:80:11:D5:31:2B:95:B6:5E:54:BA:B8:0C:2E:5C:01:80:19:8A:5D:5C:68:E6:4D:36:3C:D9:C1`

因为签名固定，加上 workflow 里 `build-number` 用的是 Actions 的递增序号：

```yaml
flutter build apk --release --build-name=0.1.${{ github.run_number }} --build-number=${{ github.run_number }}
```

所以**以后每次改完代码、重新上传、编译出新 APK，直接覆盖安装就行，不用卸载。**

### ⚠️ 三个必须记住的坑

1. **别改 `applicationId`**（现在是 `com.archivereader.ao3_reader`）。
   一改手机上就会变成两个独立的 App，旧的那个删不删都装不上覆盖。
2. **别删、别替换 `ao3-release.jks`**。签名一变，系统就会认为这是另一个 App，只能卸载重装。
   建议把这个文件在电脑上另存一份备份。
3. 想改口令/换 keystore：重新生成后，同时更新 `key.properties` 里的四个值。

### 如果你更想用 GitHub Secrets（更安全）

仓库是私有的，所以直接把 keystore 放仓库里最省事。想换成 Secrets 的话：

在 **Settings → Secrets and variables → Actions** 添加 4 个 secret：

| Secret 名 | 值 |
|---|---|
| `KEYSTORE_BASE64` | keystore 文件的 base64 文本 |
| `STORE_PASSWORD` | 上面那个口令 |
| `KEY_PASSWORD` | 同上 |
| `KEY_ALIAS` | `ao3` |

workflow 里的「配置签名」那一步会自动用 Secrets 覆盖仓库里的文件，然后就可以把
`android/app/ao3-release.jks` 和 `android/key.properties` 从仓库里删掉了。

生成 base64：

```bash
# macOS / Linux
base64 -i android/app/ao3-release.jks | pbcopy      # macOS
base64 -w0 android/app/ao3-release.jks              # Linux
```

---

## 四、本地跑（可选，需要在电脑上装 Flutter）

```bash
flutter pub get
flutter analyze          # 静态检查
flutter test             # 单元测试 + 界面流程测试
flutter run              # 插上手机直接跑
flutter build apk --release
```

---

## 五、目录结构

```
lib/
├── main.dart                  入口（AppScope + MaterialApp）
├── app_state.dart             全局状态：纸色/主题色/字体/背景/持久化/字体导入
├── palettes.dart              纸面色板 + 强调色预设
├── models.dart                Work / Chapter / Para
├── demo_data.dart             演示数据（以后换成 AO3 抓取）
├── pager.dart                 分页算法（按块装箱，不拆段落）
├── screens/
│   ├── login_screen.dart      登录 + 右上角设置
│   ├── home_shell.dart        底部导航（发现/书库/我的）
│   ├── discover_screen.dart   卡片流 / 搜索 / 筛选
│   ├── detail_screen.dart     作品详情
│   ├── reader_screen.dart     阅读器（滑动 + 无动画翻页）
│   ├── settings_screen.dart   整页阅读设置（含自定义字体/背景）
│   └── me_screen.dart         我的
└── widgets/
    ├── paper_scaffold.dart    背景图 → 纸色遮罩 → 内容；滑块等通用件
    └── work_card.dart         卡片
test/widget_test.dart          单元 + 流程测试（CI 会跑）
test_preview/                  本地截图预览用（CI 不跑）
```

---

## 六、下一步要接的（按优先级）

1. **AO3 解析层**：搜索页 / 作品页 / 正文页抓取 + 限速（≥1 秒/请求）
2. **登录**：模拟表单登录拿 Cookie（CSRF token → POST → 存 session）
3. **本地库**：SQLite 存作品 + 段落级翻译缓存 + 阅读进度（记段落锚点，不记页码）
4. **翻译**：先接一个云端引擎跑通链路，再加离线模型兜底
5. 图标 / 启动页 / 免责声明

---

## 七、免责声明

本项目是个人使用的第三方客户端，与 OTW / AO3 官方无关；
不内置、不分发任何作品内容；请遵守 AO3 使用条款，控制请求频率。
