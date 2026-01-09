# VARIABLES MODULE VPC

variable "project_name" {
  description = "Nom du projet : GreenLeaf"
  type        = string
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
}

variable "availability_zones" {
  description = "Liste des zones de disponibilité"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks pour les subnets publics"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks pour les subnets privés"
  type        = list(string)
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}



