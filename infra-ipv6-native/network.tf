# ============================================================================
# 网关与路由（IPv6-native 变体）
# ----------------------------------------------------------------------------
# 相比双栈变体，额外提供 NAT64 路由 64:ff9b::/96 → NAT，
# 使 IPv6-only 私网子网能够访问 IPv4 互联网。
# ============================================================================

resource "huaweicloud_vpc_internet_gateway" "main" {
  vpc_id      = huaweicloud_vpc.main.id
  enable_ipv6 = true
  add_route   = true
}

resource "huaweicloud_vpc_eip" "nat" {
  count = var.nat_count

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "${var.name_prefix}-nat-bw-az${count.index + 1}"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_nat_gateway" "main" {
  count       = var.nat_count
  name        = "${var.name_prefix}-nat-az${count.index + 1}"
  spec        = "1"
  vpc_id      = huaweicloud_vpc.main.id
  subnet_id   = huaweicloud_vpc_subnet.public[count.index].id
  description = "私网出网 + NAT64（AZ ${count.index + 1}）"
}

resource "huaweicloud_nat_snat_rule" "private" {
  count            = length(huaweicloud_vpc_subnet.private)
  nat_gateway_id   = huaweicloud_nat_gateway.main[count.index].id
  subnet_id        = huaweicloud_vpc_subnet.private[count.index].id
  floating_ip_id   = huaweicloud_vpc_eip.nat[count.index].id
  source_type      = 0
}

# NAT64：IPv6-only 私网子网访问 IPv4 互联网。
# 需在 NAT 网关开启 NAT64 能力（控制台/API）；路由 nexthop 指向 NAT 网关。
resource "huaweicloud_vpc_route" "nat64" {
  vpc_id      = huaweicloud_vpc.main.id
  destination = "64:ff9b::/96"
  type        = "nat"
  nexthop     = huaweicloud_nat_gateway.main[0].id
  description = "NAT64：IPv6-only 子网访问 IPv4 互联网"
}

# IPv4 默认出网路由（所有子网经 NAT）。
resource "huaweicloud_vpc_route" "ipv4_default" {
  vpc_id      = huaweicloud_vpc.main.id
  destination = "0.0.0.0/0"
  type        = "nat"
  nexthop     = huaweicloud_nat_gateway.main[0].id
  description = "IPv4 互联网出网（经 NAT 网关）"
}
