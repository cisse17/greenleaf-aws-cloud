#  Document d'Architecture Technique (DAT)
## Projet GreenLeaf - Plateforme E-commerce sur AWS

**Projet :** GreenLeaf E-commerce Éco-responsable  
**Date :** 07 Janvier 2026  
**Équipe :** Bassirou, Valence, Herby, Ibrahima 
**Version :** 1.0  
**Statut :** Déployé en Production

---

## Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Architecture Globale](#architecture-globale)
3. [Composants Infrastructure](#composants-infrastructure)
4. [Sécurité](#sécurité)
5. [Haute Disponibilité](#haute-disponibilité)
6. [Scalabilité](#scalabilité)
7. [Monitoring](#monitoring)
8. [Flux de Données](#flux-de-données)

---

##  1. Vue d'Ensemble

### 1.1 Contexte

GreenLeaf est une startup française qui commercialise des produits éco-responsables. L'infrastructure AWS a été conçue pour héberger une plateforme e-commerce basée sur Magento Open Source, avec les objectifs suivants :

- ✅ Haute disponibilité (99.9% uptime)
- ✅ Scalabilité automatique (2-4 instances)
- ✅ Sécurité renforcée
- ✅ Optimisation des coûts (~273$/mois)
- ✅ Infrastructure as Code (Terraform)

### 1.2 Technologies Utilisées

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Cloud Provider** | Amazon Web Services | - |
| **IaC** | Terraform | 1.5+ |
| **Configuration** | Ansible | 2.14+ |
| **Application** | Magento Open Source | 2.4+ |
| **Base de données** | MySQL | 8.0 |
| **Serveur Web** | Nginx | 1.18+ |
| **Langage** | PHP | 8.1+ |

---

##  2. Architecture Globale

### 2.1 Schéma d'Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        INTERNET                             │
│                     (Utilisateurs)                          │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ↓
                  ┌──────────────────────┐
                  │   Route 53 (DNS)     │
                  │    (Optionnel)       │
                  └──────────┬───────────┘
                             │
                             ↓
┌────────────────────────────────────────────────────────────┐
│                    RÉGION: eu-west-3 (Paris)               │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              Application Load Balancer               │ │
│  │  DNS: greenl2026...67458224.eu-west-3.elb...com     │ │
│  │  Zones: eu-west-3a, eu-west-3b                       │ │
│  └───────────────────────┬──────────────────────────────┘ │
│                          │                                 │
│  ┌───────────────────────┴──────────────────────────────┐ │
│  │              VPC: 10.0.0.0/16                        │ │
│  │                                                      │ │
│  │  ┌──────────────────┐    ┌──────────────────┐      │ │
│  │  │  Zone A          │    │  Zone B          │      │ │
│  │  │  eu-west-3a      │    │  eu-west-3b      │      │ │
│  │  │                  │    │                  │      │ │
│  │  │ ┌──────────────┐ │    │ ┌──────────────┐ │      │ │
│  │  │ │ Subnet Public│ │    │ │ Subnet Public│ │      │ │
│  │  │ │ 10.0.1.0/24  │ │    │ │ 10.0.2.0/24  │ │      │ │
│  │  │ │              │ │    │ │              │ │      │ │
│  │  │ │ NAT Gateway  │ │    │ │ NAT Gateway  │ │      │ │
│  │  │ └──────────────┘ │    │ └──────────────┘ │      │ │
│  │  │                  │    │                  │      │ │
│  │  │ ┌──────────────┐ │    │ ┌──────────────┐ │      │ │
│  │  │ │Subnet Privé  │ │    │ │Subnet Privé  │ │      │ │
│  │  │ │10.0.11.0/24  │ │    │ │10.0.12.0/24  │ │      │ │
│  │  │ │              │ │    │ │              │ │      │ │
│  │  │ │┌───────────┐ │ │    │ │┌───────────┐ │ │      │ │
│  │  │ ││  EC2 #1   │ │ │    │ ││  EC2 #2   │ │ │      │ │
│  │  │ ││ t3.small  │ │ │    │ ││ t3.small  │ │ │      │ │
│  │  │ ││  Magento  │ │ │    │ ││  Magento  │ │ │      │ │
│  │  │ │└───────────┘ │ │    │ │└───────────┘ │ │      │ │
│  │  │ └──────────────┘ │    │ └──────────────┘ │      │ │
│  │  └──────────────────┘    └──────────────────┘      │ │
│  │                                                      │ │
│  │  ┌──────────────────────────────────────────────┐  │ │
│  │  │        RDS MySQL (Multi-AZ)                  │  │ │
│  │  │   greenleaf-prod-db.c5wym...rds.amazonaws... │  │ │
│  │  │   Type: db.t3.small                          │  │ │
│  │  └──────────────────────────────────────────────┘  │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │           S3 Bucket (Médias Magento)             │  │
│  │   greenleaf-prod-media-20260107215404...         │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘

        ┌──────────────────────────────────┐
        │      CloudWatch Monitoring       │
        │   - Alarmes CPU (EC2, RDS)       │
        │   - Alarmes Connexions DB        │
        │   - Logs Application             │
        └──────────────────────────────────┘
```

### 2.2 Principes d'Architecture

**Architecture 3-Tiers :**
1. **Tier Présentation** : Application Load Balancer
2. **Tier Application** : Instances EC2 avec Magento
3. **Tier Données** : RDS MySQL + S3

**Design Patterns Appliqués :**
- ✅ **Multi-AZ** : Déploiement sur 2 zones de disponibilité
- ✅ **Auto Scaling** : Adaptation automatique à la charge
- ✅ **Load Balancing** : Distribution du trafic
- ✅ **Infrastructure as Code** : Gestion par Terraform
- ✅ **Immutable Infrastructure** : Instances remplacées, non modifiées

---

##  3. Composants Infrastructure

### 3.1 Réseau (VPC)

| Composant | Configuration | Détails |
|-----------|---------------|---------|
| **VPC** | `vpc-012d999180852370e` | CIDR: 10.0.0.0/16 |
| **Subnets Publics** | 2 | 10.0.1.0/24, 10.0.2.0/24 |
| **Subnets Privés** | 2 | 10.0.11.0/24, 10.0.12.0/24 |
| **Internet Gateway** | 1 | Pour accès Internet public |
| **NAT Gateways** | 2 | Un par AZ (haute dispo) |
| **Route Tables** | 3 | 1 publique, 2 privées |

**Décisions de Conception :**
- 2 NAT Gateways (au lieu d'1) pour éviter un single point of failure
- Subnets privés pour EC2 et RDS (sécurité)
- Subnets publics pour ALB et NAT Gateways uniquement

### 3.2 Compute (EC2 & Auto Scaling)

**Auto Scaling Group :**
```yaml
Configuration:
  Min Size: 2 instances
  Desired: 2 instances
  Max Size: 4 instances
  Type: t3.small (2 vCPU, 2 GB RAM)
  AMI: Ubuntu 22.04 LTS
  Clé SSH: greenleaf-bassirou
```

**Politiques de Scaling :**
- **Scale Up** : Si CPU > 70% pendant 2 minutes → +1 instance
- **Scale Down** : Si CPU < 30% pendant 2 minutes → -1 instance
- **Cooldown** : 300 secondes entre chaque action

**Launch Template :**
- Stockage : 50 GB gp3 (SSD)
- Monitoring détaillé : Activé
- User Data : Installation Python3, Ansible
- IAM Role : Accès S3 pour médias

### 3.3 Load Balancing

**Application Load Balancer :**
```yaml
Type: Application Load Balancer
Scheme: Internet-facing
IP Type: IPv4
Zones: eu-west-3a, eu-west-3b
DNS: greenl20260107215430057900000011-67458224.eu-west-3.elb.amazonaws.com
```

**Target Group :**
- Protocole : HTTP:80
- Health Check Path : `/health.php`
- Healthy Threshold : 2 checks
- Unhealthy Threshold : 3 checks
- Timeout : 5 secondes
- Interval : 30 secondes
- Sticky Sessions : Activé (cookies, 24h)

### 3.4 Base de Données (RDS)

**Configuration RDS MySQL :**
```yaml
Engine: MySQL 8.0
Instance: db.t3.small (2 vCPU, 2 GB RAM)
Storage: 100 GB gp3 (auto-scaling jusqu'à 200 GB)
Multi-AZ: Activé
Backup:
  Retention: 7 jours
  Window: 03:00-04:00 UTC
  Auto Backup: Activé
Maintenance Window: Lundi 04:00-05:00 UTC
Encryption: AES-256
```

**Paramètres Optimisés pour Magento :**
- `max_connections` = 500
- `innodb_buffer_pool_size` = 75% RAM
- `slow_query_log` = Activé
- `long_query_time` = 2 secondes

### 3.5 Stockage (S3)

**Bucket Configuration :**
```yaml
Bucket: greenleaf-prod-media-20260107215404601400000004
Region: eu-west-3
Encryption: AES-256 (SSE-S3)
Versioning: Activé
Public Access: Bloqué
```

**Lifecycle Policy :**
- Versions anciennes → Standard-IA après 30 jours
- Versions anciennes → Glacier après 90 jours
- Suppression définitive après 180 jours

**CORS :**
- Autorisé depuis le domaine Magento
- Méthodes : GET, HEAD
- Headers : *

---

##  4. Sécurité

### 4.1 Security Groups

**ALB Security Group :**
```yaml
Ingress:
  - Port 80 (HTTP) depuis 0.0.0.0/0
  - Port 443 (HTTPS) depuis 0.0.0.0/0
Egress:
  - Tout le trafic autorisé
```

**EC2 Security Group :**
```yaml
Ingress:
  - Port 80 depuis ALB Security Group
  - Port 443 depuis ALB Security Group
  - Port 22 (SSH) depuis 0.0.0.0/0 (à restreindre)
Egress:
  - Tout le trafic autorisé
```

**RDS Security Group :**
```yaml
Ingress:
  - Port 3306 (MySQL) depuis EC2 Security Group
Egress:
  - Tout le trafic autorisé
```

### 4.2 IAM (Identity & Access Management)

**Rôles IAM Créés :**

1. **EC2 Instance Role** :
   - Accès S3 (lecture/écriture sur bucket médias)
   - Accès CloudWatch Logs
   - Accès SSM (Session Manager)

2. **RDS Monitoring Role** :
   - Enhanced Monitoring sur RDS
   - Publication métriques vers CloudWatch

**Policies Appliquées :**
- Principe du moindre privilège
- Pas de credentials en dur dans le code
- Rotation automatique des secrets (recommandé)

### 4.3 Chiffrement

| Ressource | Méthode | État |
|-----------|---------|------|
| **RDS** | AES-256 at rest | ✅ Activé |
| **S3** | SSE-S3 (AES-256) | ✅ Activé |
| **EBS** | Encrypted volumes | ✅ Activé |
| **Traffic ALB→EC2** | HTTP (HTTPS recommandé) | (attention À améliorer) |

**Recommandations :**
- Implémenter HTTPS avec certificat SSL/TLS (ACM)
- Activer encryption en transit pour RDS
- Utiliser AWS Secrets Manager pour les credentials DB

---

##  5. Haute Disponibilité

### 5.1 Stratégie Multi-AZ

**Déploiement sur 2 Zones :**
- Zone A (eu-west-3a) : 1 instance EC2 + RDS primary
- Zone B (eu-west-3b) : 1 instance EC2 + RDS standby

**Scénario de Panne :**
```
Zone A tombe en panne
     ↓
ALB détecte instances Zone A unhealthy
     ↓
Tout le trafic routé vers Zone B
     ↓
RDS bascule automatiquement sur standby
     ↓
Service continue sans interruption
     ↓
Auto Scaling relance instances dans Zone A
```

**RTO/RPO :**
- **RTO** (Recovery Time Objective) : ~5 minutes
- **RPO** (Recovery Point Objective) : 0 (synchronisation synchrone RDS Multi-AZ)

### 5.2 Auto-Healing

**Health Checks :**
- ALB vérifie `/health.php` toutes les 30 secondes
- Si 3 checks échouent → Instance marquée "unhealthy"
- Auto Scaling termine l'instance défaillante
- Nouvelle instance lancée automatiquement

**Métriques Surveillées :**
- Status Check (système + instance)
- HTTP Response Code (200, 301, 302)
- Latence de réponse

---

##  6. Scalabilité

### 6.1 Scalabilité Horizontale (Auto Scaling)

**Configuration :**
- Minimum : 2 instances (haute dispo)
- Maximum : 4 instances (gestion pics de charge)

**Déclencheurs :**
```yaml
Scale Up:
  Condition: CPU > 70% pendant 2 minutes
  Action: +1 instance
  Cooldown: 5 minutes

Scale Down:
  Condition: CPU < 30% pendant 2 minutes
  Action: -1 instance
  Cooldown: 5 minutes
```

**Capacité de Charge :**
- 2 instances : ~500 utilisateurs simultanés
- 4 instances : ~1000 utilisateurs simultanés

### 6.2 Scalabilité Verticale

**Options d'Évolution :**
| Ressource | Actuel | Évolution Possible |
|-----------|--------|-------------------|
| **EC2** | t3.small | t3.medium, t3.large |
| **RDS** | db.t3.small | db.t3.medium, db.m5.large |
| **Storage RDS** | 100 GB | Auto-scaling → 200 GB |

---

##  7. Monitoring

### 7.1 CloudWatch Alarmes

**Alarmes Configurées :**

1. **CPU Élevé (EC2)** :
   - Métrique : CPUUtilization
   - Seuil : > 70%
   - Période : 2 évaluations de 2 minutes
   - Action : Scale Up

2. **CPU Faible (EC2)** :
   - Métrique : CPUUtilization
   - Seuil : < 30%
   - Période : 2 évaluations de 2 minutes
   - Action : Scale Down

3. **CPU Élevé (RDS)** :
   - Métrique : CPUUtilization
   - Seuil : > 80%
   - Action : Notification (email)

4. **Connexions Élevées (RDS)** :
   - Métrique : DatabaseConnections
   - Seuil : > 400
   - Action : Notification (email)

### 7.2 Logs

**CloudWatch Logs :**
- RDS : Error logs, Slow query logs, General logs
- EC2 : Application logs (via CloudWatch Agent)

**Rétention :** 7 jours (configurable)

---

##  8. Flux de Données

### 8.1 Flux Utilisateur (Lecture)

```
1. Client envoie requête HTTP
   ↓
2. Route 53 résout DNS → ALB
   ↓
3. ALB reçoit requête
   ↓
4. ALB vérifie health check des instances
   ↓
5. ALB route vers instance EC2 healthy
   ↓
6. Nginx (EC2) traite la requête
   ↓
7. PHP-FPM exécute Magento
   ↓
8. Magento interroge RDS MySQL
   ↓
9. Magento charge images depuis S3
   ↓
10. Réponse renvoyée au client
```

### 8.2 Flux Écriture (Commande)

```
1. Client soumet formulaire (commande)
   ↓
2. ALB → Instance EC2
   ↓
3. Magento valide les données
   ↓
4. Transaction écrite dans RDS
   ↓
5. Images produits uploadées vers S3
   ↓
6. Email confirmation envoyé (SNS/SES)
   ↓
7. Confirmation affichée au client
```

---

##  9. Déploiement

### 9.1 Infrastructure as Code

**Terraform Structure :**
```
terraform/
├── main.tf              # Orchestration principale
├── variables.tf         # Déclaration variables
├── outputs.tf           # Exports (URLs, IPs)
├── provider.tf          # Configuration AWS
└── modules/
    ├── vpc/            # Réseau
    ├── security/       # Security Groups
    ├── compute/        # EC2, ALB, ASG
    ├── database/       # RDS
    └── storage/        # S3
```

**Commandes de Déploiement :**
```bash
terraform init
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars"
```

### 9.2 Configuration Management (Ansible)

**Rôles Ansible :**
- `common` : Mise à jour système, utilitaires
- `webserver` : Installation Nginx
- `php` : Installation PHP 8.1+
- `magento` : Installation et configuration Magento

---

## 🔮 10. Évolutions Futures

### 10.1 Améliorations Recommandées

**Court Terme (1-3 mois) :**
- ✅ Implémenter HTTPS avec certificat ACM
- ✅ Ajouter CloudFront CDN
- ✅ Configurer AWS WAF (pare-feu applicatif)
- ✅ Implémenter ElastiCache (Redis) pour le cache Magento

**Moyen Terme (3-6 mois) :**
- ✅ Migrer vers containers (ECS/Fargate)
- ✅ Implémenter CI/CD avec CodePipeline
- ✅ Ajouter AWS Backup pour sauvegardes automatisées
- ✅ Implémenter AWS Secrets Manager

**Long Terme (6-12 mois) :**
- ✅ Migration vers architecture serverless (partielle)
- ✅ Implémentation de Kubernetes (EKS)
- ✅ Déploiement multi-région

---

##  Contact & Support

**Équipe Projet :**
- Infrastructure (Terraform) : Bassirou
- Configuration (Ansible) : Valence et Ibrahima
- Monitoring/FinOps : Bassirou et Herby

**Documentation :**
- Guide de Déploiement : `docs/deployment-guide.md`
- Rapport FinOps : `docs/finops-report.md`

---

**Document approuvé le :** 07 Janvier 2026 par Bassirou 
**Prochaine révision :** Après déploiement Ansible par l'équipe ansible
