# VARIABLES MODULE DATABASE

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "db_subnet_ids" {
  description = "IDs des subnets pour RDS"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "ID du security group RDS"
  type        = string
}

variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Stockage alloué (GB)"
  type        = number
  default     = 100
}

variable "db_engine_version" {
  description = "Version MySQL"
  type        = string
  default     = "8.0.35"
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
}

variable "db_username" {
  description = "Nom d'utilisateur"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Mot de passe"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "Période de rétention des backups (jours)"
  type        = number
  default     = 7
}

variable "enable_multi_az" {
  description = "Activer Multi-AZ"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}