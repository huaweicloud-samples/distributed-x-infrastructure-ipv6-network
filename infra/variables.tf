variable "region" {
  description = "华为云区域（与 AZ 前缀一致，例如 cn-north-4）"
  type        = string
  default     = "cn-north-4"
}

variable "name_prefix" {
  description = "资源命名前缀（统一标识本套 IPv6 双栈实践）"
  type        = string
  default     = "IPv6Sample"
}

variable "vpc_cidr" {
  description = "VPC 的 IPv4 CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "两个可用区（与 region 前缀一致）"
  type        = list(string)
  default     = ["cn-north-4a", "cn-north-4b"]
}

variable "public_subnet_cidrs" {
  description = "两个公网子网 IPv4 CIDR（双栈，启用 IPv6）"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "两个私网子网 IPv4 CIDR（双栈，启用 IPv6）"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

# 华为云子网的 IPv6 CIDR 由平台在启用 IPv6 后自动分配，
# 因此无法在规划期预知具体值；此处用变量承接「私网 IPv6 入站放行来源」，
# 默认放行整个 IPv6 公网（演示用），生产可收紧为实际 VPC IPv6 CIDR。
variable "private_ipv6_inbound_cidr" {
  description = "私网 NACL 入站 IPv6 放行来源（默认 ::/0 仅做演示，生产应改为 VPC 实际 IPv6 CIDR）"
  type        = string
  default     = "::/0"
}
