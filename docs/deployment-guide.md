# 华为云 IPv6 VPC 实践部署指南

> 本文档指导如何在华为云上部署本实践的 IPv6 双栈 / IPv6-native VPC。部署前请先阅读 `architecture.md` 了解架构。

## 1. 前置条件

| 项目 | 要求 |
|------|------|
| 华为云账号 | 具备 VPC、NAT 网关、EIP、IPv6 网关的创建权限（VPC Administrator 或等效策略） |
| 区域 | 目标区域需已开通 IPv6（如 `cn-north-4`、`cn-north-1` 等，以控制台为准） |
| Terraform | >= 1.5（本实践以 huaweicloud provider `1.96.0` 校验通过） |
| 凭据 | `HW_ACCESS_KEY` / `HW_SECRET_KEY`（临时凭证加 `HW_SECURITY_TOKEN`），请经环境变量注入 |

```bash
# 凭据仅经环境变量注入
export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
export HW_SECRET_KEY="<HW_SECRET_KEY>"
# export HW_SECURITY_TOKEN="<TOKEN>" # 临时凭证时

terraform version # 确认 >= 1.5
```

## 2. 快速开始（双栈 VPC）

```bash
cd infra
terraform init
terraform validate # 预期：Success! The configuration is valid.
terraform plan # 核对将创建的资源
terraform apply # 创建资源
```

## 3. IPv6-native VPC（可选）

```bash
cd ../infra-ipv6-native
terraform init && terraform validate && terraform apply
```

> IPv6-native 变体还需在 NAT 网关开启 **NAT64** 能力（控制台/API），并在私网子网开启 **DNS64**，这两项 Terraform 暂未直接暴露参数，需 apply 后在控制台确认。

## 4. 验证部署成功

`apply` 完成后：

```bash
terraform state list # 列出已创建资源
terraform output # 输出 VPC / 子网 / NAT / IGW ID
```

控制台核对要点：
- VPC 详情显示已分配 IPv6 CIDR；公网/私网子网均显示 IPv6 CIDR（`/64`）。
- 默认路由表含 `0.0.0.0/0 → NAT` 与 `::/0 → IPv6 互联网网关`。
- IPv6-native 变体默认路由表额外含 `64:ff9b::/96 → NAT`。
- 公网/私网 NACL 已分别关联对应子网。

连通性自测（在 VPC 内发射 ECS 后）：
- 双栈私网子网内 ECS：`ping` 公网 IPv4 地址应通（经 NAT）；`ping6` 公网 IPv6 地址应通（经 IPv6 互联网网关）。
- IPv6-native 私网子网内 ECS：`ping6` 一个仅 IPv4 的域名（经 DNS64 + NAT64）应解析并通。

> 本实践涉及的云服务规格以实际部署资源为准。

## 5. 清理资源

```bash
terraform destroy # 删除全部资源
```

> 销毁后建议到控制台 API 直查 EIP / NAT / 子网 / VPC 无残留（尤其状态为 `available` 的孤儿资源）。

## 6. 已知约束与人工步骤

| 约束 | 处理 |
|------|------|
| 每 VPC 仅 1 张默认路由表 | 公网/私网路由已收敛到默认表；如需分离，申请配额提升后自建路由表 |
| `add_route` 行为差异 | 若 apply 后默认表缺 `::/0`，请手动在控制台为 IPv6 互联网网关补一条 `::/0` 路由 |
| DNS64 / NAT64 无独立 TF 参数 | apply 后在控制台开启；属运行期配置，不在 Terraform 生命周期内 |
| IPv6 CIDR 自动分配 | 无法在规划期预知，私网 NACL 入站 IPv6 来源默认 `::/0`（演示），生产请改为实际 VPC IPv6 CIDR |
