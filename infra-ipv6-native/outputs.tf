output "vpc_id" {
  description = "VPC ID"
  value       = huaweicloud_vpc.main.id
}

output "public_subnet_ids" {
  description = "公网子网 ID 列表（双栈）"
  value       = huaweicloud_vpc_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "私网子网 ID 列表（面向 IPv6-only 工作负载）"
  value       = huaweicloud_vpc_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "NAT 网关 ID 列表（IPv4 出网 + NAT64）"
  value       = huaweicloud_nat_gateway.main[*].id
}

output "nat64_route_destination" {
  description = "NAT64 路由目标（IPv6-only 子网经此访问 IPv4 互联网）"
  value       = huaweicloud_vpc_route.nat64.destination
}
