# ============================================================================
# 网络 ACL
# 公网 NACL 全放通；私网 NACL 仅放行 VPC 内流量 + 被动响应端口(1024-65535)，
# 实现「仅出网、无主动入站」语义。
# ============================================================================

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
  name       = "${var.name_prefix}-public-nacl"
  subnets    = huaweicloud_vpc_subnet.public[*].id
  inbound_rules  = [huaweicloud_network_acl_rule.pub_in_v4.id, huaweicloud_network_acl_rule.pub_in_v6.id]
  outbound_rules = [huaweicloud_network_acl_rule.pub_out_v4.id, huaweicloud_network_acl_rule.pub_out_v6.id]
}

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
resource "huaweicloud_network_acl_rule" "pri_in_v4_ephem" {
  name                = "${var.name_prefix}-pri-in-v4-ephem"
  action              = "allow"
  protocol            = "tcp"
  ip_version          = 4
  source_ip_address   = "0.0.0.0/0"
  source_port         = "1024-65535"
}
resource "huaweicloud_network_acl_rule" "pri_in_v6_ephem" {
  name                = "${var.name_prefix}-pri-in-v6-ephem"
  action              = "allow"
  protocol            = "tcp"
  ip_version          = 6
  source_ip_address   = "::/0"
  source_port         = "1024-65535"
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
  name       = "${var.name_prefix}-private-nacl"
  subnets    = huaweicloud_vpc_subnet.private[*].id
  inbound_rules = [
    huaweicloud_network_acl_rule.pri_in_v4.id,
    huaweicloud_network_acl_rule.pri_in_v6.id,
    huaweicloud_network_acl_rule.pri_in_v4_ephem.id,
    huaweicloud_network_acl_rule.pri_in_v6_ephem.id,
  ]
  outbound_rules = [
    huaweicloud_network_acl_rule.pri_out_v4.id,
    huaweicloud_network_acl_rule.pri_out_v6.id,
  ]
}
