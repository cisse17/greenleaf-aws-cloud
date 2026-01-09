#  Guide de déploiement de l’infrastructure Greenleaf Ecommerce

## 1. Objectif du document
Ce document décrit l’ensemble des étapes permettant de déployer l’infrastructure Cloud du projet **Greenleaf Ecommerce** sur AWS.  
Il couvre le provisioning réseau, les ressources compute, la base de données et les mécanismes d’accès. 

Une section dédiée au **déploiement automatisé via Ansible** sera ajoutée ultérieurement.

---

## 2. Prérequis techniques

### 2.1 Accès et comptes nécessaires
- Compte AWS actif
- Droits IAM administrateur ou équivalents :
  - EC2
  - VPC
  - RDS
  - IAM
  - ELB
  - S3
- Terminal avec :
  - Git
  - Terraform ≥ 1.5
  - AWS CLI configurée

### 2.2 Informations d’environnement
- Région AWS : `eu-west-3 (Paris)`
- Multi-AZ : **activé**
- Nom du projet : `greenleaf`
- Environnement : `prod`

---

## 3. Architecture réseau (VPC)

### 3.1 Création du VPC
- CIDR VPC : `10.0.0.0/16`
- Nom : `greenleaf-prod-vpc`

### 3.2 Sous-réseaux
| Type | CIDR | AZ |
|------|------|----|
| Public 1 | 10.0.1.0/24 | eu-west-3a |
| Public 2 | 10.0.2.0/24 | eu-west-3b |
| Private 1 | 10.0.11.0/24 | eu-west-3a |
| Private 2 | 10.0.12.0/24 | eu-west-3b |

### 3.3 Passerelles
- Internet Gateway attachée au VPC
- **2 NAT Gateways** (Multi-AZ), une par AZ privée

### 3.4 Tables de routage
- Public → IGW
- Privé → NAT

---

## 4. Sécurité (Security Groups)

### 4.1 Web / ALB
- TCP 80, 443 depuis `0.0.0.0/0`

### 4.2 Instances applicatives
- TCP 22 depuis IP admin
- TCP 80 depuis ALB

### 4.3 Base de données RDS
- TCP 3306 **uniquement depuis SG applicatif**

---

## 5. Compute – Instances applicatives

### 5.1 Type d’instance
Pour projet scolaire → optimisation coût :

- **Recommandé :**
  - `t3.small` ou `t3.medium`
- Minimum pour Magento :
  - 2 vCPU
  - 2–4 Go RAM

### 5.2 Auto Scaling Group
- Min : 1
- Max : 2
- Lancement dans **subnets privés**

### 5.3 AMI
- Linux 2 / Ubuntu 22.04

---

## 6. Load Balancer

- Type : Application Load Balancer (ALB)
- Subnets : publics
- Listeners :
  - HTTP 80
  - HTTPS 443 (si certificat ACM)
- Health checks : `/`

---

## 7. Base de données RDS

| Paramètre | Valeur |
|----------|--------|
| Moteur | MySQL 8.0 |
| Instance | db.t3.small |
| vCPU | 2 |
| RAM | 2 Go |
| Multi-AZ | Oui |
| Stockage | gp3 – 100 GiB |
| Chiffrement | Activé |
| DB name | magento |
| Admin user | magento_admin |

⚠️ **Accès uniquement depuis les instances applicatives**

---

## 8. Déploiement via Terraform

L’infrastructure est déployée à l’aide de Terraform.  
Les variables sensibles (mots de passe, clés, endpoints…) sont stockées dans le fichier :

``secrets.tfvars``

> Ce fichier **ne doit pas être versionné dans Git**.

### 8.1 Initialisation de Terraform
Permet de télécharger les providers et d’initialiser le backend :

```bash
terraform init
8.2 Vérification du plan de déploiement
bash
Copier le code
terraform plan -var-file="secrets.tfvars"
Cela permet :

d’utiliser les variables contenues dans secrets.tfvars

de vérifier les ressources créées/modifiées/supprimées

de valider qu’il n’y a pas d’erreur avant déploiement

8.3 Déploiement de l’infrastructure

bash
Copier le code
terraform apply -var-file="secrets.tfvars"
Puis confirmer avec yes lorsque demandé.

8.4 Destruction de l’infrastructure ( si nécessaire)

bash
Copier le code
terraform destroy -var-file="secrets.tfvars"
À utiliser uniquement en fin de projet pour éviter les coûts AWS.


9. Vérifications post-déploiement
ALB → healthy targets

Instances EC2 accessibles par SSH

DB RDS en status Available

Connection test :

bash
Copier le code
mysql -h <endpoint> -u magento_admin -p
SG corrects

NAT fonctionne depuis subnets privés

10. Déploiement applicatif – Ansible ( à compléter)
🔜 Cette section sera complétée lorsque les playbooks seront finalisés.

Elle contiendra :

structure du repository Ansible

rôles :

Nginx / Apache

PHP

Magento

inventaire dynamique AWS

commandes d’exécution :

bash
Copier le code
ansible-playbook -i inventory site.yml
11. Résolution des problèmes courants
ALB cible en unhealthy
port incorrect

SG bloquant trafic

health check path mauvais

EC2 sans Internet en privé
NAT non associé

route table invalide

RDS inaccessible
SG ne permet pas trafic 3306

mauvais endpoint (privé/public)

12. Conclusion
L’infrastructure Greenleaf est conçue pour :

haute disponibilité (Multi-AZ)

séparation réseau sécurisée

coûts maîtrisés pour un projet scolaire

compatibilité Magento

La partie automatisation Ansible sera ajoutée prochainement.