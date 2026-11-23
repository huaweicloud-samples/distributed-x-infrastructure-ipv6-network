# ============================================================================
# 网关与路由（IPv6 互联网出口，无公网 NAT）
# ----------------------------------------------------------------------------
# 设计要点：
#   - 公网 IPv6 出口：huaweicloud_vpc_internet_gateway(enable_ipv6=true)
#   - 「仅出网」语义：由「私网 NACL 拒绝非受邀入站」实现
#   - 公网 NAT 网关：按设计移除，IPv6 资源经 IGW 直出公网，
#                    不依赖 NAT；私网子网改为 IPv6-only 出网。
#   - 路由表：华为云每 VPC 默认仅 1 张路由表，统一收敛到默认表
# ============================================================================

# IPv6 互联网网关（VPC 级 IPv6 出口）。
# add_route=true 会在默认路由表自动写入 ::/0 出口路由，IPv6 资源由此直连公网。
resource "huaweicloud_vpc_internet_gateway" "main" {
  vpc_id      = huaweicloud_vpc.main.id
  enable_ipv6 = true
  add_route   = true
  # 等待子网就绪，避免 IGW 创建时序竞争（华为云 IGW 校验 VPC 内子网存在性）。
  depends_on = [
    huaweicloud_vpc_subnet.public,
    huaweicloud_vpc_subnet.private,
  ]
}

# 说明：本配置不创建任何公网 NAT 网关 / EIP / SNAT 规则。
# add_route=true 会自动写入 0.0.0.0/0 → igw（IPv4 默认路由），
# 但华为云不会同时写入 ::/0，因此需要显式补充 IPv6 默认路由。
# 私网子网为 IPv6-only 出网，公网子网保持双栈（实例如需 IPv4 入站可绑定 EIP）。

resource "huaweicloud_vpc_route" "ipv6_default" {
  vpc_id      = huaweicloud_vpc.main.id
  destination = "::/0"
  type        = "igw"
  nexthop     = huaweicloud_vpc_internet_gateway.main.id
  depends_on  = [huaweicloud_vpc_internet_gateway.main]
}
