# src/

本仓库为**纯网络基础设施**示例（仅含 基础设施编排 模板，无应用代码、无函数 / 模型调用）。

因此本目录**无需放置应用程序代码**（无 `adapter/`、`functions/`、`frontend/` 内容可生成）。本实践的全部产物均为 Terraform（`infra/` 与 `infra-ipv6-native/`），涵盖完整的 IPv6 网络能力。

若后续在此网络之上部署应用（如 CCE 工作负载、FunctionGraph 函数），请在此目录按各服务约定补充代码，并复用本目录上级的 VPC / 子网 / 路由输出。
