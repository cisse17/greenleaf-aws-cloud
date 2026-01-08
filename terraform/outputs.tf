# ============================================================================
# OUTPUTS - INFORMATIONS DE DÉPLOIEMENT
# ============================================================================

# ----------------------------------------------------------------------------
# URLs d'Accès
# ----------------------------------------------------------------------------
output "website_url" {
  description = "🌐 URL principale pour accéder au site Magento"
  value       = "http://${module.compute.alb_dns_name}"
}

output "alb_dns_name" {
  description = "DNS du Load Balancer"
  value       = module.compute.alb_dns_name
}

# output "cloudfront_url" {
#  description = "🚀 URL CloudFront (CDN)"
#  value       = var.enable_cloudfront ? "http://${module.cdn[0].cloudfront_domain_name}" : "CloudFront non activé"
#}

# output "magento_admin_url" {
#  description = "🔐 URL de l'interface d'administration Magento"
#  value       = "http://${module.compute.alb_dns_name}/admin"
# }

# ----------------------------------------------------------------------------
# Informations Infrastructure
# ----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID du VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs des subnets privés"
  value       = module.vpc.private_subnet_ids
}

output "rds_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = module.database.rds_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Nom du bucket S3 pour les médias"
  value       = module.storage.s3_bucket_name
}

output "asg_name" {
  description = "Nom de l'Auto Scaling Group"
  value       = module.compute.asg_name
}

# ----------------------------------------------------------------------------
# Informations pour Ansible
# ----------------------------------------------------------------------------
# output "ansible_inventory_created" {
#  description = "Confirmation de création de l'inventaire Ansible"
#  value       = "✅ Inventaire créé dans ansible/inventory/hosts"
#}

# output "ansible_extra_vars" {
#  description = "Variables à passer à Ansible"
#  value = {
#    rds_endpoint  = module.database.rds_endpoint
#    s3_bucket     = module.storage.s3_bucket_name
#    alb_dns_name  = module.compute.alb_dns_name
#  }
#  sensitive = true
# }

# ----------------------------------------------------------------------------
# Message de Succès
# ----------------------------------------------------------------------------
output "deployment_success" {
  description = "Message de succès du déploiement"
  value       = <<-EOT
  
  ╔══════════════════════════════════════════════════════════════════╗
  ║         🎉 DÉPLOIEMENT RÉUSSI - GREENLEAF E-COMMERCE            ║
  ╚══════════════════════════════════════════════════════════════════╝
  
  📌 Infrastructure AWS déployée avec succès !
  
  🌐 URL principale (à ouvrir dans votre navigateur) :
     http://${module.compute.alb_dns_name}
  
  🔐 Interface d'administration Magento :
     http://${module.compute.alb_dns_name}/admin
     Username: admin
     Password: (configuré dans Ansible)
  
  📊 Ressources déployées :
     • VPC avec 2 zones de disponibilité
     • ${var.asg_desired_capacity} instances EC2 (Auto Scaling)
     • RDS MySQL ${var.db_engine_version}
     • Application Load Balancer
     • Bucket S3 pour les médias
     ${var.enable_cloudfront ? "• CloudFront CDN activé" : ""}
  
  🔧 Prochaines étapes :
  
     1. Configurer Magento avec Ansible :
        cd ../ansible
        ansible-playbook -i inventory/hosts playbooks/magento-setup.yml
  
     2. Vérifier le site :
        curl -I http://${module.compute.alb_dns_name}
  
     3. Surveiller les coûts :
        aws ce get-cost-and-usage --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics BlendedCost
  
  💡 Notes importantes :
     • Il peut falloir 2-3 minutes pour que le site soit opérationnel
     • Les Health Checks de l'ALB doivent passer au vert
     • Vérifiez CloudWatch pour le monitoring
  
  📚 Documentation complète : docs/deployment-guide.md
  
  EOT
}

# ----------------------------------------------------------------------------
# Coûts Estimés
# ----------------------------------------------------------------------------
output "estimated_monthly_cost" {
  description = "💰 Estimation des coûts mensuels"
  value       = <<-EOT
  
  Estimation des coûts mensuels (région ${var.aws_region}) :
  
  • EC2 (${var.instance_type} x${var.asg_desired_capacity})     : ~${var.asg_desired_capacity * 60}$/mois
  • RDS (${var.db_instance_class})             : ~50$/mois
  • ALB                                : ~25$/mois
  • S3 + CloudFront                    : ~20$/mois
  • Data Transfer (500 GB)             : ~45$/mois
  • CloudWatch                         : ~15$/mois
  ────────────────────────────────────────────────
  TOTAL ESTIMÉ                         : ~${var.asg_desired_capacity * 60 + 215}$/mois
  
  Budget cible : ${var.monthly_budget_limit}$/mois
  ${var.asg_desired_capacity * 60 + 205 <= var.monthly_budget_limit ? "✅ Budget respecté" : "⚠️  Budget dépassé - Optimisation nécessaire"}
  
  💡 Consultez docs/finops-report.md pour des stratégies d'optimisation
  
  EOT
}