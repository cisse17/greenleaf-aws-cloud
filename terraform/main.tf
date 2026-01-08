# ============================================================================
# GREENLEAF E-COMMERCE - INFRASTRUCTURE AWS
# ============================================================================
# Description: Infrastructure complète pour héberger Magento Open Source
# Auteurs: Équipe GreenLeaf
# Date: Janvier 2025
# ============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# ============================================================================
# MODULE VPC - Réseau Virtuel
# ============================================================================
module "vpc" {
  source = "./modules/vpc"
  
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  tags = var.common_tags
}

# ============================================================================
# MODULE SECURITY - Security Groups
# ============================================================================
module "security" {
  source = "./modules/security"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  
  # Autoriser votre IP pour l'accès SSH (à personnaliser)
  allowed_ssh_cidr = var.allowed_ssh_cidr
  
  tags = var.common_tags
}

# ============================================================================
# MODULE DATABASE - RDS MySQL
# ============================================================================
module "database" {
  source = "./modules/database"
  
  project_name           = var.project_name
  environment            = var.environment
  
  # Configuration RDS
  db_instance_class      = var.db_instance_class
  db_allocated_storage   = var.db_allocated_storage
  db_engine_version      = var.db_engine_version
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  
  # Réseau
  vpc_id                 = module.vpc.vpc_id
  db_subnet_ids          = module.vpc.private_subnet_ids
  db_security_group_id   = module.security.db_security_group_id
  
  # Backup
  backup_retention_period = var.db_backup_retention
  
  tags = var.common_tags
}

# ============================================================================
# MODULE STORAGE - S3 pour les médias Magento
# ============================================================================
module "storage" {
  source = "./modules/storage"
  
  project_name = var.project_name
  environment  = var.environment
  
  enable_versioning = true
  enable_encryption = true
  
  tags = var.common_tags
}

# ============================================================================
# MODULE COMPUTE - EC2, Auto Scaling, ALB
# ============================================================================
module "compute" {
  source = "./modules/compute"
  
  project_name = var.project_name
  environment  = var.environment
  
  # Configuration EC2
  instance_type      = var.instance_type
  key_name           = var.key_name
  ami_id             = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  
  # Auto Scaling
  min_size           = var.asg_min_size
  max_size           = var.asg_max_size
  desired_capacity   = var.asg_desired_capacity
  
  # Réseau
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  
  # Security Groups
  alb_security_group_id = module.security.alb_security_group_id
  ec2_security_group_id = module.security.ec2_security_group_id
  
  # Dépendances (variables d'environnement pour EC2)
  rds_endpoint       = module.database.rds_endpoint
  s3_bucket_name     = module.storage.s3_bucket_name
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  iam_instance_profile_name = module.storage.ec2_instance_profile_name
  
  tags = var.common_tags
}


# ============================================================================ 
# MODULE CLOUDFRONT - CDN (Optionnel)
# ============================================================================
# module "cdn" {
#   source = "./modules/cdn"
#   count  = var.enable_cloudfront ? 1 : 0
#   
#   project_name       = var.project_name
#   environment        = var.environment
#   alb_dns_name       = module.compute.alb_dns_name
#   s3_bucket_domain   = module.storage.s3_bucket_domain_name
#   
#   tags = var.common_tags
# }

# ============================================================================ 
# MODULE MONITORING - CloudWatch
# ============================================================================
# module "monitoring" {
#   source = "./modules/monitoring"
#   
#   project_name = var.project_name
#   environment  = var.environment
#   
#   # Ressources à surveiller
#   alb_arn            = module.compute.alb_arn
#   asg_name           = module.compute.asg_name
#   rds_instance_id    = module.database.rds_instance_id
#   
#   # Alertes
#   alarm_email        = var.alarm_email
#   
#   tags = var.common_tags
# }

# ============================================================================ 
# GÉNÉRATION INVENTAIRE ANSIBLE
# ============================================================================
# resource "local_file" "ansible_inventory" {
#   content = templatefile("${path.module}/templates/inventory.tpl", {
#     alb_dns_name = module.compute.alb_dns_name
#     rds_endpoint = module.database.rds_endpoint
#     s3_bucket    = module.storage.s3_bucket_name
#   })
#   filename = "${path.module}/../ansible/inventory/hosts"
# }


# ============================================================================
# DATA SOURCES - AMI Ubuntu
# ============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}