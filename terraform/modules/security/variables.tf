# ============================================================================
# VARIABLES MODULE SECURITY
# ============================================================================

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

variable "allowed_ssh_cidr" {
  description = "CIDR autorisés pour SSH"
  type        = list(string)
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}