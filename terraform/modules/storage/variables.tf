# ============================================================================
# VARIABLES MODULE STORAGE
# ============================================================================

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "enable_versioning" {
  description = "Activer le versioning S3"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Activer le chiffrement S3"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}