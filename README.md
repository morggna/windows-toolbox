# 自用脚本集合

个人常用的 Windows 配置和管理脚本集合。

## 📁 脚本列表

### Windows 配置脚本 (`windows-config.bat`)

一键配置 Windows 系统的批处理脚本，支持以下功能：

- **Windows 激活**：支持多个常用版本的 KMS 激活
  - Windows 11/10 专业版
  - Windows 企业版 LTSC (2024/2021/2019)
  - Windows Server 2025 数据中心版
  - Windows Server 2022 数据中心版

- **恢复经典右键菜单**：一键恢复 Windows 11 的经典右键菜单样式

## 🚀 使用方法

### Windows 配置脚本

1. 下载 `windows-config.bat` 文件
2. 右键点击文件，选择"以管理员身份运行"
3. 根据菜单提示选择需要的功能

```batch
请选择要执行的操作:

[1] Windows 激活
[2] 恢复经典右键菜单
[3] 执行全部操作
[4] 退出
```

## ⚠️ 注意事项

1. **管理员权限**：所有脚本都需要以管理员身份运行
2. **编码问题**：批处理文件使用 UTF-8 编码保存，开头包含 `chcp 65001` 命令
3. **KMS 激活**：激活密钥来自 [微软官方 GVLK 文档](https://learn.microsoft.com/zh-cn/windows-server/get-started/kms-client-activation-keys)
4. **仅供个人使用**：这些脚本仅用于个人学习和合法使用场景

## 📝 密钥说明

脚本中使用的所有产品密钥均为微软官方提供的通用批量许可证密钥 (GVLK)，用于 KMS 客户端激活。

| 版本 | 密钥 |
|------|------|
| Windows 11/10 专业版 | W269N-WFGWX-YVC9B-4J6C9-T83GX |
| Windows 企业版 LTSC | M7XTQ-FN8P6-TTKYV-9D4CC-J462D |
| Windows Server 2025 数据中心版 | D764K-2NDRG-47T6Q-P8T8W-YP6DF |
| Windows Server 2022 数据中心版 | WX4NM-KYWYW-QJJR4-XV3QB-6VM33 |

## 🔧 故障排除

### 脚本出现乱码或命令无法识别

- 原因：文件编码问题
- 解决：用记事本打开文件，另存为时选择 **ANSI** 编码

### 激活失败

- 检查是否以管理员身份运行
- 确认 Windows 版本与选择的密钥匹配
- 检查网络连接到 KMS 服务器

## 📜 许可证

本仓库仅供个人学习和研究使用。使用者需遵守微软软件许可条款。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这些脚本。

## 📮 联系方式

如有问题或建议，请通过 GitHub Issues 反馈。

---

**免责声明**：本仓库提供的脚本仅用于合法授权的系统激活。请确保你拥有相应的 Windows 许可证。
