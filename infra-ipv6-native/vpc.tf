# ============================================================================
# VPC 与子网（IPv6-native 变体）
# ----------------------------------------------------------------------------
# 设计要点：
#   - 公网子网：双栈（IPv4 + IPv6）。
#   - 私网子网：面向 IPv6-only 工作负载（启用 DNS64）。
#     华为云子网必须携带 IPv4 CIDR（平台限制），故此处仍给 IPv4 CIDR，
#     但业务上仅使用 IPv6 地址；DNS64 需在子网开启（控制台/API，无独立 TF 参数）。
# ============================================================================

resource "huaweicloud_vpc" "main" {
  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  name              = "${var.name_prefix}-public-subnet-az${count.index + 1}"
  vpc_id            = huaweicloud_vpc.main.id
  cidr              = var.public_subnet_cidrs[count.index]
  gateway_ip        = cidrhost(var.public_subnet_cidrs[count.index], 1)
  availability_zone = var.azs[count.index]

  ipv6_enable = true
}

resource "huaweicloud_vpc_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  name              = "${var.name_prefix}-private-subnet-az${count.index + 1}"
  vpc_id            = huaweicloud_vpc.main.id
  cidr              = var.private_subnet_cidrs[count.index]
  gateway_ip        = cidrhost(var.private_subnet_cidrs[count.index], 1)
  availability_zone = var.azs[count.index]

  # IPv6-only 工作负载：启用 IPv6；DNS64 请在子网开启以满足 EnableDns64 语义。
  ipv6_enable = true
}
