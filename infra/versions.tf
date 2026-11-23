terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "= 1.96.0"
    }
  }

  # 状态文件默认存本地；生产环境建议改为 OBS 后端：
  # backend "s3" {
  #   endpoint   = "https://obs.<region>.myhuaweicloud.com"
  #   bucket     = "<your-tfstate-bucket>"
  #   key        = "ipv6-getting-started/terraform.tfstate"
  #   region     = "<region>"
  # }
  backend "local" {}
}

provider "huaweicloud" {
  region = var.region
  # 凭据从环境变量读取：
  #   export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
  #   export HW_SECRET_KEY="<HW_SECRET_KEY>"
  # 临时凭证再加：
  #   export HW_SECURITY_TOKEN="<TOKEN>"
}
