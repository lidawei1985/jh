# LDW TVBox 配置仓库

## 应用远程更新

- `update.json`：APP 版本与 APK 下载清单
- `source-update.json`：APP 数据源同步清单
- `combined.json`：APP 当前正式内置/远程同步配置
- `releases/`：已发布 APK

## 历史与候选配置

- `综合影视配置一.json`、`综合影视配置二.json`：综合影视候选配置
- `影视综合配置-豆包整理版.json`：原豆包改版综合配置
- `TVBox多仓线路汇总.json`：多仓地址汇总
- `成人点播配置一.json`、`成人点播配置二.json`：成人点播候选配置
- `成人直播订阅列表.json`：成人直播订阅候选列表
- `直播与影视综合配置.json`：直播与影视混合配置
- `综合配置清理稿.json`：历史清理稿，未作为正式配置使用
- `影视接口地址汇总.txt`：历史接口地址记录

正式 APP 只读取 `combined.json`，其他文件不会自动进入客户端，需验证后再合并。

### 手机版稳定版

- 当前版本：`1.0.60-mobile`（versionCode 60）
- 安装包：`releases/mobile/LDW-Cinema-Mobile-v60.apk`
- 手机版独立读取 `update-mobile.json`，不影响电视版 `update.json`。
- SHA-256：`2A1ED8C41965E3E6BFC339F196FA7300BC68D3660B1EF3E00DB3D861F63C4477`

