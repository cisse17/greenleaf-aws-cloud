greenleaf-aws/
│
├── terraform/                          # Infrastructure as Code
│   ├── modules/                        # Modules réutilisables
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── compute/
│   │   │   ├── main.tf                 # EC2, Auto Scaling, ALB
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── database/
│   │   │   ├── main.tf                 # RDS MySQL
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── storage/
│   │       ├── main.tf                 # S3, CloudFront
│   │       ├── variables.tf
│   │       └── outputs.tf
│   ├── templates/
│   │   └── inventory.tpl               # Template inventaire Ansible
│   ├── main.tf                         # Fichier principal
│   ├── variables.tf                    # Variables globales
│   ├── outputs.tf                      # Outputs (IPs, DNS, etc.)
│   ├── terraform.tfvars                # Valeurs des variables (ne pas commit!)
│   ├── provider.tf                     # Configuration AWS provider
│   └── README.md
│
├── ansible/                            # Configuration Management
│   ├── playbooks/
│   │   ├── magento-setup.yml           # Playbook principal
│   │   └── monitoring-setup.yml        # Setup CloudWatch agent
│   ├── roles/
│   │   ├── common/                     # Configuration système de base
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   └── handlers/
│   │   │       └── main.yml
│   │   ├── webserver/                  # Installation Nginx
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   ├── templates/
│   │   │   │   └── nginx.conf.j2
│   │   │   └── handlers/
│   │   │       └── main.yml
│   │   ├── php/                        # Installation PHP
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   └── templates/
│   │   │       └── php-fpm.conf.j2
│   │   └── magento/                    # Installation Magento
│   │       ├── tasks/
│   │       │   └── main.yml
│   │       ├── templates/
│   │       │   ├── env.php.j2
│   │       │   └── config.php.j2
│   │       └── vars/
│   │           └── main.yml
│   ├── inventory/
│   │   └── hosts                       # Généré par Terraform
│   ├── group_vars/
│   │   └── all.yml                     # Variables communes
│   ├── ansible.cfg                     # Configuration Ansible
│   └── README.md
│
├── docs/                               # Documentation
│   ├── architecture.md                 # Document Architecture Technique
│   ├── finops-report.md                # Rapport FinOps
│   ├── deployment-guide.md             # Guide de déploiement

