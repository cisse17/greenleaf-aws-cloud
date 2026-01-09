# OUTPUTS MODULE DATABASE

output "rds_endpoint" {
  description = "Endpoint de connexion RDS"
  value       = aws_db_instance.magento.endpoint
}

output "rds_instance_id" {
  description = "ID de l'instance RDS"
  value       = aws_db_instance.magento.id
}

output "rds_arn" {
  description = "ARN de l'instance RDS"
  value       = aws_db_instance.magento.arn
}

output "rds_address" {
  description = "Adresse DNS de l'instance RDS"
  value       = aws_db_instance.magento.address
}

output "rds_port" {
  description = "Port de connexion"
  value       = aws_db_instance.magento.port
}