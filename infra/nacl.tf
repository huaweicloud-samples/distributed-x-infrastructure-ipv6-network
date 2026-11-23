# ============================================================================
# 华为云网络 ACL
# ----------------------------------------------------------------------------
# 华为云 NACL 规则由 huaweicloud_network_acl_rule 定义，再在 huaweicloud_network_acl
# 的 inbound_rules / outbound_rules 中按规则 ID 引用，并通过 subnets 关联子网。
#   - 公网 NACL：全放通。
#   - 私网 NACL：仅放行 VPC 内（含指定 IPv6 入站来源）流量，拒绝来自公网的
#     非受邀入站，实现「仅出网」语义。
#     注：华为云 NACL 的 source_port 仅接受单个端口、不支持端口区间，
#     「被动响应端口 1024-65535」模式无法直接复用；实例如需
#     出站并接收返回流量，应改用「有状态」的安全组（Security Group）实现。
# ============================================================================

# ---------------- 公网 NACL 规则 ----------------
resource "huaweicloud_network_acl_rule" "pub_in_v4" {
  name                = "${var.name_prefix}-pub-in-v4"
  action              = "allow"
  protocol            = "any"
  ip_version          = 4
  source_ip_address   = "0.0.0.0/0"
}
resource "huaweicloud_network_acl_rule" "pub_in_v6" {
  name                = "${var.name_prefix}-pub-in-v6"
  action              = "allow"
  protocol            = "any"
  ip_version          = 6
  source_ip_address   = "::/0"
}
resource "huaweicloud_network_acl_rule" "pub_out_v4" {
  name                  = "${var.name_prefix}-pub-out-v4"
  action                = "allow"
  protocol              = "any"
  ip_version            = 4
  destination_ip_address = "0.0.0.0/0"
}
resource "huaweicloud_network_acl_rule" "pub_out_v6" {
  name                  = "${var.name_prefix}-pub-out-v6"
  action                = "allow"
  protocol              = "any"
  ip_version            = 6
  destination_ip_address = "::/0"
}

resource "huaweicloud_network_acl" "public" {
  name = "${var.name_prefix}-public-nacl"
  subnets = huaweicloud_vpc_subnet.public[*].id
  inbound_rules  = [huaweicloud_network_acl_rule.pub_in_v4.id, huaweicloud_network_acl_rule.pub_in_v6.id]
  outbound_rules = [huaweicloud_network_acl_rule.pub_out_v4.id, huaweicloud_network_acl_rule.pub_out_v6.id]
}

# ---------------- 私网 NACL 规则 ----------------
resource "huaweicloud_network_acl_rule" "pri_in_v4" {
  name                = "${var.name_prefix}-pri-in-v4"
  action              = "allow"
  protocol            = "any"
  ip_version          = 4
  source_ip_address   = var.vpc_cidr
}
resource "huaweicloud_network_acl_rule" "pri_in_v6" {
  name                = "${var.name_prefix}-pri-in-v6"
  action              = "allow"
  protocol            = "any"
  ip_version          = 6
  source_ip_address   = var.private_ipv6_inbound_cidr
}
resource "huaweicloud_network_acl_rule" "pri_out_v4" {
  name                  = "${var.name_prefix}-pri-out-v4"
  action                = "allow"
  protocol              = "any"
  ip_version            = 4
  destination_ip_address = "0.0.0.0/0"
}
resource "huaweicloud_network_acl_rule" "pri_out_v6" {
  name                  = "${var.name_prefix}-pri-out-v6"
  action                = "allow"
  protocol              = "any"
  ip_version            = 6
  destination_ip_address = "::/0"
}

resource "huaweicloud_network_acl" "private" {
  name = "${var.name_prefix}-private-nacl"
  subnets = huaweicloud_vpc_subnet.private[*].id
  inbound_rules = [
    huaweicloud_network_acl_rule.pri_in_v4.id,
    huaweicloud_network_acl_rule.pri_in_v6.id,
  ]
  outbound_rules = [
    huaweicloud_network_acl_rule.pri_out_v4.id,
    huaweicloud_network_acl_rule.pri_out_v6.id,
  ]
}
