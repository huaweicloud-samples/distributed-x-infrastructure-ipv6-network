# ============================================================================
# 华为云 IPv6-native VPC — Terraform 入口标记文件
#
# 本文件仅作 IaC 入口标记。实际资源按职责拆分到：
#   - versions.tf   ：Terraform / Provider 版本约束
#   - variables.tf  ：输入变量（region / name_prefix / CIDR / AZ / NAT 数量 / IPv6 入站 CIDR）
#   - vpc.tf        ：VPC + 公网 / 私网子网（公网双栈、私网 IPv6-only）
#   - network.tf    ：IPv6 互联网网关 + NAT 网关 + NAT64（64:ff9b::/96）+ 默认路由
#   - nacl.tf       ：公网 / 私网 NACL（含被动响应端口 1024-65535）
#   - outputs.tf    ：输出 VPC / 子网 / NAT 网关 / NAT64 路由目标
#
# Terraform 会自动加载同目录全部 .tf，因此这里不写实际资源，只放入口注释。
# ============================================================================
