# ============================================================================
# PROVIDER AWS - CONFIGURATION
# ============================================================================

# variable "aws_access_key" {
#  description = "AWS Access Key"
#  type        = string
#  sensitive   = true
# }

# variable "aws_secret_key" {
#  description = "AWS Secret Key"
# type        = string
#  sensitive   = true
#}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  
  default_tags {
    tags = var.common_tags
  }
}