# ============================================================================
# 华为云 IPv6 双栈 VPC — Terraform 入口标记文件
#
# 本文件仅作 IaC 入口标记。实际资源按职责拆分到：
#   - versions.tf   ：Terraform / Provider 版本约束
#   - variables.tf  ：输入变量（region / name_prefix / CIDR / AZ / IPv6 入站 CIDR）
#   - vpc.tf        ：VPC + 公网 / 私网子网（双栈）
#   - network.tf    ：IPv6 互联网网关 + 路由（::/0 出口）
#   - nacl.tf       ：公网 / 私网 NACL
#   - outputs.tf    ：输出 VPC / 子网 / IGW ID
#
# verify-ecs/ 子模块：临时验证 ECS（验证完用 `terraform destroy` 释放）
#
# Terraform 会自动加载同目录全部 .tf，因此这里不写实际资源，只放入口注释。
# ============================================================================
