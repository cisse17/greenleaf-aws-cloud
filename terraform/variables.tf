# VARIABLES - CONFIGURATION GREENLEAF

# Variables Générales
variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "greenleaf"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-1"
}

variable "common_tags" {
  description = "Tags communs à appliquer à toutes les ressources"
  type        = map(string)
  default = {
    Project     = "GreenLeaf"
    Environment = "Production"
    ManagedBy   = "Terraform"
    Team        = "DevOps"
  }
}

# Variables Réseau (VPC)
variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Liste des zones de disponibilité"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks pour les subnets publics"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks pour les subnets privés"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Variables Compute (EC2 / Auto Scaling)
variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.medium"
  
  validation {
    condition     = can(regex("^t3\\.(small|medium|large)$", var.instance_type))
    error_message = "Type d'instance doit être t3.small, t3.medium ou t3.large pour optimiser les coûts."
  }
}

variable "key_name" {
  description = "Nom de la clé SSH pour accéder aux instances EC2"
  type        = string
  default     = "greenleaf-key"
}

variable "ami_id" {
  description = "ID de l'AMI (laisser vide pour utiliser Ubuntu 22.04 automatiquement)"
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Nombre minimum d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Nombre maximum d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Nombre désiré d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 2
}

# Variables Base de Données (RDS)
variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Stockage alloué pour RDS (en GB)"
  type        = number
  default     = 100
}

variable "db_engine_version" {
  description = "Version de MySQL"
  type        = string
  default     = "8.0.35"
}

variable "db_name" {
  description = "Nom de la base de données Magento"
  type        = string
  default     = "magento"
}

variable "db_username" {
  description = "Nom d'utilisateur de la base de données"
  type        = string
  default     = "magento_admin"
  sensitive   = true
}

variable "db_password" {
  description = "Mot de passe de la base de données"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 12
    error_message = "Le mot de passe doit contenir au moins 12 caractères."
  }
}

variable "db_backup_retention" {
  description = "Période de rétention des backups (en jours)"
  type        = number
  default     = 7
}

# Variables Sécurité
variable "allowed_ssh_cidr" {
  description = "CIDR autorisé pour l'accès SSH (votre IP publique)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # À CHANGER pour mon IP uniquement 
}

# Variables CloudFront
variable "enable_cloudfront" {
  description = "Activer CloudFront CDN"
  type        = bool
  default     = true
}

# Variables Monitoring
variable "alarm_email" {
  description = "Email pour recevoir les alertes CloudWatch"
  type        = string
  default     = "bassiroucisse1711@gmail.com"
}

# Variables FinOps
variable "enable_cost_allocation_tags" {
  description = "Activer les tags d'allocation de coûts"
  type        = bool
  default     = true
}

variable "monthly_budget_limit" {
  description = "Budget mensuel limite en USD"
  type        = number
  default     = 500
}



# Variables pour Credentials AWS
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}


