variable "region" {
  type    = string
  default = "cn-north-4"
}

variable "name_prefix" {
  type    = string
  default = "IPv6SampleNative"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["cn-north-4a", "cn-north-4b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

# 私网子网虽承载 IPv4 CIDR（华为云子网必须含 IPv4 CIDR），
# 但本变体面向「IPv6-only 工作负载」：启用 IPv6 + DNS64，并通过 NAT64 路由
# 让其访问 IPv4 互联网。
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "nat_count" {
  type    = number
  default = 2
  validation {
    condition     = var.nat_count == 1 || var.nat_count == 2
    error_message = "nat_count 只能为 1 或 2。"
  }
}

variable "private_ipv6_inbound_cidr" {
  type    = string
  default = "::/0"
}
