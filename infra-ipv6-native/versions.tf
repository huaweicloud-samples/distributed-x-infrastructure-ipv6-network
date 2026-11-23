terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "= 1.96.0"
    }
  }

  backend "local" {}
}

provider "huaweicloud" {
  region = var.region
  # 凭据从环境变量读取：
  #   export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
  #   export HW_SECRET_KEY="<HW_SECRET_KEY>"
}
