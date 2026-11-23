output "vpc_id" {
  description = "VPC ID"
  value       = huaweicloud_vpc.main.id
}

output "vpc_ipv4_cidr" {
  description = "VPC IPv4 CIDR"
  value       = huaweicloud_vpc.main.cidr
}

output "public_subnet_ids" {
  description = "公网子网 ID 列表（双栈）"
  value       = huaweicloud_vpc_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "私网子网 ID 列表（双栈）"
  value       = huaweicloud_vpc_subnet.private[*].id
}

output "ipv6_internet_gateway_id" {
  description = "IPv6 互联网网关 ID（::/0 出口由 add_route 自动写入默认路由表）"
  value       = huaweicloud_vpc_internet_gateway.main.id
}
