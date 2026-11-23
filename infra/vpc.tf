# ============================================================================
# VPC 与子网（双栈：IPv4 + IPv6）
# ----------------------------------------------------------------------------
# 华为云说明：
#   - huaweicloud_vpc 没有 ipv6_enable 字段；IPv6 在「子网」上通过 ipv6_enable
#     启用，启用后平台自动为 VPC 分配一段 IPv6 CIDR，并为每个子网自动分配 /64。
#   - 因此无需（也无法）在 VPC 层声明 IPv6，子网 ipv6_enable=true 即可。
# ============================================================================

resource "huaweicloud_vpc" "main" {
  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr
}

# 公网子网（双栈）。平台自动为每个子网分配 IPv6 /64。
resource "huaweicloud_vpc_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  name              = "${var.name_prefix}-public-subnet-az${count.index + 1}"
  vpc_id            = huaweicloud_vpc.main.id
  cidr              = var.public_subnet_cidrs[count.index]
  gateway_ip        = cidrhost(var.public_subnet_cidrs[count.index], 1)
  availability_zone = var.azs[count.index]

  # 启用 IPv6：平台自动分配子网 IPv6 CIDR（/64）与 IPv6 网关地址。
  ipv6_enable = true
}

# 私网子网（双栈）。
resource "huaweicloud_vpc_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  name              = "${var.name_prefix}-private-subnet-az${count.index + 1}"
  vpc_id            = huaweicloud_vpc.main.id
  cidr              = var.private_subnet_cidrs[count.index]
  gateway_ip        = cidrhost(var.private_subnet_cidrs[count.index], 1)
  availability_zone = var.azs[count.index]

  ipv6_enable = true
}
