variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "name_prefix" {
  description = "资源名称前缀"
  type        = string
  default     = "IPv6Sample"
}

variable "vpc_name" {
  description = "已部署的 VPC 名称"
  type        = string
  default     = "IPv6Sample-vpc"
}

variable "public_subnet_name" {
  description = "用于验证的公网子网名称（双栈，含 IPv4 私网 + IPv6）"
  type        = string
  default     = "IPv6Sample-public-subnet-az1"
}

variable "private_subnet_name" {
  description = "用于验证的私网子网名称（双栈，含 IPv4 私网 + IPv6），第二台验证 ECS 落在此子网"
  type        = string
  default     = "IPv6Sample-private-subnet-az1"
}

variable "flavor_name" {
  description = "ECS 规格（通用型，验证用最小够用即可）"
  type        = string
  default     = "s6.large.2"
}

variable "image_name_regex" {
  description = "公共镜像名称正则（取最新版）。注意要排除带 Graphic driver 的 GPU 镜像，否则需配 GPU 规格。"
  type        = string
  default     = "^Ubuntu 22.04 server 64bit$"
}

variable "ecs_password" {
  description = "ECS 登录密码（控制台 VNC 远程登录用）。验证完成后请尽快修改或删除 ECS。"
  type        = string
  default     = "IPv6Demo@2026!"
  sensitive   = true
}
