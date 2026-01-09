# VARIABLES MODULE COMPUTE

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

variable "public_subnet_ids" {
  description = "IDs des subnets publics"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs des subnets privés"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID du security group ALB"
  type        = string
}

variable "ec2_security_group_id" {
  description = "ID du security group EC2"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "ID de l'AMI"
  type        = string
}

variable "key_name" {
  description = "Nom de la clé SSH"
  type        = string
}

variable "min_size" {
  description = "Taille minimum ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Taille maximum ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Capacité désirée ASG"
  type        = number
  default     = 2
}

variable "rds_endpoint" {
  description = "Endpoint RDS"
  type        = string
}

variable "s3_bucket_name" {
  description = "Nom du bucket S3"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
}

variable "db_username" {
  description = "Username base de données"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password base de données"
  type        = string
  sensitive   = true
}

variable "iam_instance_profile_name" {
  description = "Nom de l'instance profile IAM"
  type        = string
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}