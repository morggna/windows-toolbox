# 自用脚本集合

个人常用的 Windows 配置和管理脚本集合。

## 📁 脚本列表

### KMS 客户端配置脚本 (`activate.bat`)

用于合法批量许可环境中的 Windows KMS 客户端配置：

- 自动检测当前 Windows 版本，避免手工选择错误密钥
- 验证 KMS 主机名、IPv4 地址和端口
- 修改授权配置前先测试 KMS TCP 连接
- 优先使用当前已安装的产品密钥尝试激活
- 当前密钥不适用时，再明确询问是否安装对应的微软 GVLK
- 支持 Windows 10/11 专业版、企业版 LTSC 和 Windows Server 2022/2025 数据中心版

> 该脚本只适用于已获得合法批量许可的设备。KMS 主机必须由你的组织运营或授权。

### 经典右键菜单脚本 (`classic-context-menu.bat`)

- 为当前用户恢复 Windows 经典右键菜单
- 不需要管理员权限
- 可选择仅写入设置，或只重启当前登录会话的 Explorer
- Explorer 启动检查具有超时限制，不会无限等待

### 软件自动安装脚本 (`Software install.bat`)

使用 Scoop 包管理器自动安装常用软件，支持以下功能：

- **自动安装 Scoop**：首次运行时自动安装和配置 Scoop
- **快速安装**：一键安装预设的开发者常用软件包
  - Git, 7-Zip, Aria2 (下载加速)
  - Everything, PowerToys
  - VS Code, Notepad++, Chrome

- **自定义选择**：从 38+ 款软件中自由选择安装
  - 开发工具：Git, VS Code, Python, Node.js, Go, Docker, OpenJDK
  - 浏览器：Chrome, Firefox, Brave, Edge
  - 实用工具：7-Zip, Everything, PowerToys, Notepad++, Typora, Ditto
  - 媒体工具：VLC, PotPlayer, OBS Studio, FFmpeg
  - 网络工具：Clash for Windows, Clash Verge, WinSCP, PuTTY, Terminus
  - 通讯工具：Telegram, Discord
  - 其他：TeamViewer, AnyDesk, Postman, Wireshark 等

- **软件更新**：一键更新 Scoop 和已安装的所有软件

## 🚀 使用方法

### 安全下载

建议从仓库页面下载并检查脚本内容后再运行。不要把下载和管理员执行连接在同一条命令中。

使用 CMD 下载时，应让 HTTP 错误直接导致下载失败：

```bat
curl.exe --fail --show-error --location --proto "=https" ^
  --output "%USERPROFILE%\Downloads\activate.bat" ^
  "https://raw.githubusercontent.com/morggna/windows-toolbox/main/activate.bat"
```

下载后可计算 SHA-256，并与可信渠道发布的校验值比较：

```bat
certutil -hashfile "%USERPROFILE%\Downloads\activate.bat" SHA256
```

### KMS 客户端配置脚本

1. 确认设备拥有合法的 Windows 批量许可证。
2. 确认 KMS 主机由你的组织运营或授权。
3. 以管理员身份打开 CMD。
4. 运行脚本并传入 KMS 主机，可省略默认的 `1688` 端口：

```bat
activate.bat kms.example.com:1688
```

查看帮助：

```bat
activate.bat --help
```

如需清除手工指定的 KMS 主机并恢复自动发现，可使用微软提供的命令：

```bat
cscript.exe //nologo "%SystemRoot%\System32\slmgr.vbs" /ckms
```

### 经典右键菜单脚本

直接运行，不需要管理员权限：

```bat
classic-context-menu.bat
```

### 软件自动安装脚本

1. 下载 `Software install.bat` 文件
2. **双击运行**（不需要管理员权限）
3. 首次运行时：
   - 会询问是否自定义安装路径
   - 可选择默认路径（`%USERPROFILE%\scoop`）或自定义路径（如 `D:\Scoop`）
   - 自动安装 Scoop（需要 1-2 分钟）
4. 选择安装方式：

```batch
[1] 快速安装（开发者常用软件包）
[2] 自定义选择
[3] 查看软件列表
[4] 更新 Scoop
[5] 查看 Scoop 信息
[6] 退出
```

**快速安装**将自动安装：Git, 7-Zip, Aria2, Everything, PowerToys, VS Code, Notepad++, Chrome

**自定义选择**可从 38+ 款软件中选择，输入编号即可（支持多选，用空格分隔）

**自定义安装路径注意事项**：
- 路径不要包含空格（如使用 `D:\Scoop` 而非 `D:\My Scoop`）
- 建议使用英文路径
- 不要使用系统保护的目录（如 `C:\Program Files`）
- 推荐安装到独立分区（如 D 盘），便于管理和备份

**Scoop 优势**：
- 绿色安装，软件安装在用户目录，不污染系统
- 支持自定义安装位置，可安装到任意盘符
- 自动配置环境变量
- 支持命令行管理：`scoop install/update/uninstall`
- 下载速度快（自动配置 aria2 多线程下载）

## ⚠️ 注意事项

### KMS 客户端配置脚本

1. **管理员权限**：`activate.bat` 必须从管理员 CMD 运行
2. **授权要求**：GVLK 不是许可证，只能用于合法的批量许可和 KMS 环境
3. **版本检测**：脚本不会为无法识别或不支持的 Windows 版本安装密钥
4. **网络检查**：脚本会在更改授权设置前测试 KMS 主机的 TCP 端口
5. **凭据安全**：不要在 `curl -u user:password` 等命令行参数中写入明文密码
6. **脚本来源**：激活密钥来自 [微软官方 GVLK 文档](https://learn.microsoft.com/zh-cn/windows-server/get-started/kms-client-activation-keys)

### 软件自动安装脚本

1. **系统要求**：Windows 7 SP1+ / Windows Server 2008+，支持 PowerShell 5.0+
2. **无需管理员**：Scoop 安装在用户目录，不需要管理员权限
3. **网络连接**：需要稳定的网络连接，首次安装 Scoop 约需 1-2 分钟
4. **自动安装**：如未安装 Scoop，脚本会自动安装
5. **下载加速**：自动配置 aria2 多线程下载，提升下载速度
6. **软件来源**：所有软件均从官方源下载，安全可靠
7. **便捷管理**：
   - 安装：`scoop install 软件名`
   - 更新：`scoop update 软件名` 或 `scoop update *` (全部)
   - 卸载：`scoop uninstall 软件名`
   - 搜索：`scoop search 关键词`
   - 查看：`scoop list` (已安装) / `scoop status` (可更新)

## 📝 密钥说明

脚本中使用的所有产品密钥均为微软官方提供的通用批量许可证密钥 (GVLK)，用于 KMS 客户端激活。

GVLK 仅用于配置 KMS 客户端，不会向设备授予 Windows 许可证。

| 版本 | 密钥 |
|------|------|
| Windows 11/10 专业版 | W269N-WFGWX-YVC9B-4J6C9-T83GX |
| Windows 企业版 LTSC | M7XTQ-FN8P6-TTKYV-9D4CC-J462D |
| Windows Server 2025 数据中心版 | D764K-2NDRG-47T6Q-P8T8W-YP6DF |
| Windows Server 2022 数据中心版 | WX4NM-KYWYW-QJJR4-XV3QB-6VM33 |

## 🔧 故障排除

### KMS 客户端配置脚本

**脚本出现乱码或命令无法识别**
- 从仓库重新下载原始文件，避免网页复制改变引号、换行或转义符
- 使用 CMD 而不是 PowerShell 直接运行 `.bat` 文件

**激活失败**
- 检查是否以管理员身份运行
- 确认设备拥有对应版本的合法批量许可证
- 确认 KMS 主机由你的组织授权，并允许客户端访问相应 TCP 端口
- 使用 `cscript.exe //nologo "%SystemRoot%\System32\slmgr.vbs" /dlv` 查看详细授权状态
- 如需清除手工指定的 KMS 主机，使用 `cscript.exe //nologo "%SystemRoot%\System32\slmgr.vbs" /ckms`

### 软件自动安装脚本

**Scoop 自动安装失败**
- 检查网络连接
- 确保 PowerShell 5.0 或更高版本
- 手动安装：在 PowerShell 中执行
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  irm get.scoop.sh | iex
  ```

**软件安装失败**
- 检查网络连接
- 某些软件可能需要先添加对应的 bucket：
  - `scoop bucket add extras` (常用软件)
  - `scoop bucket add versions` (特定版本)
  - `scoop bucket add java` (Java 相关)
- 查看详细错误：`scoop install 软件名 -v`

**下载速度慢**
- Scoop 会自动安装 aria2 加速下载
- 如未启用：`scoop config aria2-enabled true`
- 配置线程数：`scoop config aria2-split 16`
- 配置最大连接数：`scoop config aria2-max-connection-per-server 16`

**安装位置**
- Scoop 安装在：`%USERPROFILE%\scoop\`
- 软件安装在：`%USERPROFILE%\scoop\apps\`
- 不污染系统目录，卸载简单

**环境变量问题**
- Scoop 会自动配置环境变量
- 如未生效，重启命令行或重启 explorer.exe
- 手动刷新：`scoop reset *`

## 📜 许可证

本仓库仅供个人学习和研究使用。使用者需遵守微软软件许可条款。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这些脚本。

## 📮 联系方式

如有问题或建议，请通过 GitHub Issues 反馈。

---

**免责声明**：本仓库提供的脚本仅用于合法授权的系统激活。请确保你拥有相应的 Windows 许可证。
