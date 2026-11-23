# ============================================================
# 临时验证 ECS
# 目的：在已部署的双栈子网中起 Ubuntu ECS 并开启 IPv6，验证 VPC 内双栈互通。
# ⚠️ 关键限制（实战结论）：华为云 IPv6 地址默认仅 VPC 内可达；访问真实
#       IPv6 公网需账号开通原生「IPv6 公网带宽（白名单制）」，本账号 cn-north-4
#       无此入口。「IPv6 转换(NAT64) EIP」仅做 IPv6↔IPv4、不能上 IPv6 公网，
#       故公网 ping6 必不通——属账号能力缺失，非部署错误。验收改做两台 ECS
#       跨子网 IPv6 互 ping（见 verify2）。验证完务必 terraform destroy 释放
#       本 ECS/安全组，并在控制台手动释放任何手动购买的 EIP。
# ============================================================

# 复用已部署的 VPC / 公网子网（按名称查找，避免硬编码 ID）
data "huaweicloud_vpc" "main" {
  name = var.vpc_name
}

data "huaweicloud_vpc_subnet" "public" {
  name = var.public_subnet_name
}

# 取最新的 Ubuntu 22.04 公共镜像（锁 x86_64，匹配 x86 规格 s6.*）
data "huaweicloud_images_image" "ubuntu" {
  name_regex   = var.image_name_regex
  most_recent  = true
  visibility   = "public"
  architecture = "x86_64"
}

# 验证专用安全组：放通 IPv6 全出 + ICMPv6 + SSH(IPv4)
resource "huaweicloud_networking_secgroup" "verify" {
  name = "${var.name_prefix}-verify-sg"
}

resource "huaweicloud_networking_secgroup_rule" "ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.verify.id
}

resource "huaweicloud_networking_secgroup_rule" "icmpv6_in" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "icmpv6"
  remote_ip_prefix  = "::/0"
  security_group_id = huaweicloud_networking_secgroup.verify.id
}

resource "huaweicloud_networking_secgroup_rule" "egress_v4_any" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.verify.id
}

resource "huaweicloud_networking_secgroup_rule" "egress_v6_any" {
  direction         = "egress"
  ethertype         = "IPv6"
  remote_ip_prefix  = "::/0"
  security_group_id = huaweicloud_networking_secgroup.verify.id
}

# IPv6 转换(NAT64)要求安全组放行转换前缀 198.19.0.0/16 的入站回包（华为云官方值）
resource "huaweicloud_networking_secgroup_rule" "nat64_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "198.19.0.0/16"
  security_group_id = huaweicloud_networking_secgroup.verify.id
}

resource "huaweicloud_compute_instance" "verify" {
  name              = "${var.name_prefix}-verify-ecs"
  image_id          = data.huaweicloud_images_image.ubuntu.id
  flavor_name       = var.flavor_name
  availability_zone = data.huaweicloud_vpc_subnet.public.availability_zone
  admin_pass        = var.ecs_password

  # 安全组放顶层（network 块不支持 security_group_ids）
  security_group_ids = [huaweicloud_networking_secgroup.verify.id]

  # 接入双栈公网子网，并显式开启 IPv6
  network {
    uuid        = data.huaweicloud_vpc_subnet.public.id
    ipv6_enable = true
  }

  system_disk_type = "GPSSD"
  system_disk_size = 40

  tags = {
    Purpose = "ipv6-connectivity-verify"
    Temp    = "delete-after-verify"
  }
}

# ⚠️ IPv6 公网访问限制（实战结论）：华为云 IPv6 默认仅 VPC 内可达。
#   访问真实 IPv6 公网需账号开通原生「IPv6 公网带宽」（白名单制，本账号无入口）；
#   「IPv6 转换(NAT64) EIP」仅做 IPv6↔IPv4、不能访问真实 IPv6 站点，
#   故公网 ping6 不通属预期，验收以 VPC 内双 ECS 跨子网 IPv6 互 ping 为准。

# ----------------------------------------------------------------------------
# 第二台临时验证 ECS（私网双栈子网）
# ----------------------------------------------------------------------------
# 用途：与上方公网子网中的第一台验证 ECS 通过各自分配的 IPv6 地址互 ping，
#       证明「VPC 内 IPv6 双栈互通」——这是本实践的核心验证目标，且不依赖
#       原生 IPv6 公网带宽 / NAT64。
# 私网子网 NACL 入站 IPv6 默认 ::/0 全放通，跨子网 IPv6 互 ping 不会被 ACL 拦截。
# ----------------------------------------------------------------------------

data "huaweicloud_vpc_subnet" "private" {
  name = var.private_subnet_name
}

resource "huaweicloud_compute_instance" "verify2" {
  name              = "${var.name_prefix}-verify-ecs-2"
  image_id          = data.huaweicloud_images_image.ubuntu.id
  flavor_name       = var.flavor_name
  availability_zone = data.huaweicloud_vpc_subnet.private.availability_zone
  admin_pass        = var.ecs_password

  # 复用同一验证安全组（已放通 icmpv6 入站 ::/0 与 IPv6 出站 ::/0）
  security_group_ids = [huaweicloud_networking_secgroup.verify.id]

  # 接入双栈私网子网，并显式开启 IPv6
  network {
    uuid        = data.huaweicloud_vpc_subnet.private.id
    ipv6_enable = true
  }

  system_disk_type = "GPSSD"
  system_disk_size = 40

  tags = {
    Purpose = "ipv6-connectivity-verify"
    Temp    = "delete-after-verify"
  }
}
