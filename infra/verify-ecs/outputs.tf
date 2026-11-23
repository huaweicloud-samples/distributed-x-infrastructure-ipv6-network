output "ecs_id" {
  description = "验证 ECS ID"
  value       = huaweicloud_compute_instance.verify.id
}

output "ecs_ipv4_private" {
  description = "ECS 私有 IPv4（用于 DNS 解析，不出公网）"
  value       = huaweicloud_compute_instance.verify.network[0].fixed_ip_v4
}

output "ecs_ipv6" {
  description = "ECS IPv6 地址（ping6 测试源地址）"
  value       = huaweicloud_compute_instance.verify.network[0].fixed_ip_v6
}

output "ecs_password" {
  description = "ECS 登录密码（控制台 VNC 远程登录用）"
  value       = var.ecs_password
  sensitive   = true
}

output "console_url" {
  description = "ECS 控制台地址"
  value       = "https://console.huaweicloud.com/ecm/?region=cn-north-4#/ecs"
}

output "ecs2_id" {
  description = "第二台验证 ECS（私网子网）ID"
  value       = huaweicloud_compute_instance.verify2.id
}

output "ecs2_ipv6" {
  description = "第二台验证 ECS 的 IPv6 地址（与第一台互 ping 用）"
  value       = huaweicloud_compute_instance.verify2.network[0].fixed_ip_v6
}

output "ping_commands" {
  description = "验证 VPC 内 IPv6 互通的 ping 命令（在两台 ECS 终端分别执行）"
  value = <<-EOT
    在 ECS1（公网子网）终端执行：
      ping6 ${huaweicloud_compute_instance.verify2.network[0].fixed_ip_v6}
    在 ECS2（私网子网）终端执行：
      ping6 ${huaweicloud_compute_instance.verify.network[0].fixed_ip_v6}
  EOT
}
