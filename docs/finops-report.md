#  Rapport d'Analyse FinOps
## Projet GreenLeaf - Plateforme E-commerce sur AWS

**Projet :** GreenLeaf E-commerce Éco-responsable  
**Date :** 08 Janvier 2026  
**Analyste :** Bassirou, Valence, Ibrahima et Herby  
**Version :** 1.0  
**Période d'Analyse :** Janvier 2026

---

##  Table des Matières

1. [Executive Summary](#executive-summary)
2. [Coûts Mensuels Détaillés](#coûts-mensuels-détaillés)
3. [Analyse par Service](#analyse-par-service)
4. [Opportunités d'Optimisation](#opportunités-doptimisation)
5. [Prévisions & Scalabilité](#prévisions--scalabilité)
6. [Recommandations](#recommandations)

---

##  1. Executive Summary

### 1.1 Coût Total Mensuel (Révisé)

```
┌─────────────────────────────────────────┐
│   COÛT MENSUEL TOTAL : ~273 USD/mois    │
│   (~ 250 EUR/mois au taux actuel)       │
└─────────────────────────────────────────┘
```

### 1.2 Répartition des Coûts

```
RDS (Database)       : 120 USD (44%)  ██████████████
NAT Gateway          : 70 USD  (26%)  ████████░░░░░░
EC2 (Compute)        : 50 USD  (18%)  ██████░░░░░░░░
ALB (Load Balancer)  : 20 USD  (7%)   ██░░░░░░░░░░░░
CloudWatch           : 10 USD  (4%)   █░░░░░░░░░░░░░
S3 Storage           : 3 USD   (1%)   ░░░░░░░░░░░░░░
                       ──────
Total                : 273 USD (100%)
```

### 1.3 Points Clés

✅ **Infrastructure Production** : Multi-AZ pour haute disponibilité  
✅ **Scalabilité** : Capable de gérer 2x-3x le trafic actuel  
✅ **Sécurité** : RDS Multi-AZ, chiffrement activé  
⚠️ **Point d'Attention** : RDS + NAT = 70% du coût total  
💡 **Opportunités** : Économies possibles de 60-90 USD/mois (22-33%)

---

##  2. Coûts Mensuels Détaillés

### 2.1 Compute (EC2)

| Composant | Détails | Coût Mensuel |
|-----------|---------|--------------|
| **Instances EC2** | 2× t3.small (730h/mois) | $30.37 |
| **Stockage EBS** | 2× 50GB gp3 SSD | $8.00 |
| **IOPS gp3** | 3000 IOPS/volume (inclus) | $0.00 |
| **Throughput gp3** | 125 MB/s (inclus) | $0.00 |
| **Snapshots EBS** | ~50GB/mois | $2.50 |
| **Data Transfer OUT** | 50GB/mois @ $0.09/GB | $4.50 |
| **Monitoring détaillé** | CloudWatch | $4.63 |
| | **Sous-Total EC2** | **≈ $50** |

**Calcul Détaillé :**
```
t3.small (2 vCPU, 2GB RAM)
Prix On-Demand : $0.0208/heure
2 instances × 730h/mois × $0.0208 = $30.37

EBS gp3 : $0.08/GB-mois
2 volumes × 50GB × $0.08 = $8.00

Snapshots : $0.05/GB-mois
50GB × $0.05 = $2.50
```

---

### 2.2 Database (RDS MySQL)

| Composant | Détails | Coût Mensuel |
|-----------|---------|--------------|
| **Instance RDS Multi-AZ** | db.t3.small × 2 (Primary + Standby) | $99.28 |
| **Stockage gp3** | 100GB × 2 (Multi-AZ) | $23.00 |
| **IOPS inclus** | 3000 IOPS/volume | $0.00 |
| **Backup automatique** | 100GB (= taille DB, gratuit) | $0.00 |
| **Enhanced Monitoring** | Métriques détaillées | $1.44 |
| | **Sous-Total RDS** | **≈ $120** |

**Calcul Détaillé :**
```
db.t3.small Multi-AZ (2 vCPU, 2GB RAM)
Prix : $0.068/h × 2 (Multi-AZ) = $0.136/h
$0.136 × 730h = $99.28

Stockage gp3 Multi-AZ : $0.115/GB-mois
100GB × 2 × $0.115 = $23.00

Enhanced Monitoring : $1.50/instance × 730h/mois
= $1.44/mois
```

**Note :** Multi-AZ double le coût mais assure :
- ✅ Failover automatique < 2 minutes
- ✅ Synchronisation synchrone des données
- ✅ 99.95% SLA (vs 99.5% Single-AZ)

---

### 2.3 Réseau (NAT Gateway)

| Composant | Détails | Coût Mensuel |
|-----------|---------|--------------|
| **NAT Gateway (Zone A)** | Coût fixe 730h | $32.85 |
| **NAT Gateway (Zone B)** | Coût fixe 730h | $32.85 |
| **Data Processing** | 100GB/mois @ $0.045/GB | $4.50 |
| | **Sous-Total NAT** | **≈ $70** |

**Calcul Détaillé :**
```
NAT Gateway : $0.045/heure (eu-west-3)
2 NAT × $0.045/h × 730h = $65.70

Data Processing : $0.045/GB
100GB × $0.045 = $4.50

Total : $70.20/mois
```

**Pourquoi 2 NAT Gateways ?**
- ✅ Haute disponibilité (pas de SPOF)
- ✅ Si Zone A tombe, Zone B continue
- ⚠️ Coût : +$35/mois vs 1 seul NAT

---

### 2.4 Load Balancer (ALB)

| Composant | Détails | Coût Mensuel |
|-----------|---------|--------------|
| **ALB - Coût fixe** | Application Load Balancer | $16.43 |
| **LCU (Capacity Units)** | ~0.5 LCU/h (trafic modéré) | $2.92 |
| **Health Checks** | Inclus | $0.00 |
| **Sticky Sessions** | Inclus | $0.00 |
| | **Sous-Total ALB** | **≈ $20** |

**Calcul LCU :**
```
ALB : $0.0225/heure
$0.0225 × 730h = $16.43

LCU : $0.008/LCU-heure
~0.5 LCU × 730h × $0.008 = $2.92

Total : $19.35/mois
```

---

### 2.5 Stockage (S3)

| Composant | Détails | Coût Mensuel |
|-----------|---------|--------------|
| **Stockage Standard** | 100GB médias Magento | $2.30 |
| **Requests PUT/POST** | 10,000 uploads/mois | $0.05 |
| **Requests GET** | 100,000 lectures/mois | $0.04 |
| **Data Transfer OUT** | 10GB/mois vers Internet | $0.90 |
| **Versioning** | Inclus | $0.00 |
| | **Sous-Total S3** | **≈ $3** |

---

### 2.6 Monitoring (CloudWatch)

| Composant | Détails | Coût Mensuel |
|-----------|---------|--------------|
| **Alarmes Standard** | 5 alarmes (CPU, connexions...) | $0.50 |
| **Logs Ingestion** | 5GB/mois | $2.50 |
| **Logs Storage** | 5GB stockés | $0.25 |
| **Métriques détaillées EC2** | 2 instances | $4.20 |
| **Métriques RDS** | Enhanced Monitoring | $1.44 |
| **Dashboards** | 3 dashboards personnalisés | $9.00 |
| | **Sous-Total CloudWatch** | **≈ $10** |

---

### 2.7 Autres Services

| Composant | Détails | Coût Mensuel |
|-----------|---------|--------------|
| **VPC** | Gratuit | $0.00 |
| **Internet Gateway** | Gratuit | $0.00 |
| **Route Tables** | Gratuit | $0.00 |
| **Security Groups** | Gratuit | $0.00 |
| **Auto Scaling** | Gratuit | $0.00 |
| **Data Transfer IN** | Gratuit | $0.00 |
| | **Sous-Total** | **$0** |

---

##  3. Récapitulatif Final

### 3.1 Tableau Récapitulatif

| Service | Coût Mensuel | % du Total | Priorité Optimisation |
|---------|--------------|------------|----------------------|
| **RDS MySQL Multi-AZ** | $120 | 44% | 🔴 Haute |
| **NAT Gateway (×2)** | $70 | 26% | 🔴 Haute |
| **EC2 (×2 t3.small)** | $50 | 18% | 🟡 Moyenne |
| **Application Load Balancer** | $20 | 7% | 🟢 Faible |
| **CloudWatch** | $10 | 4% | 🟢 Faible |
| **S3 Storage** | $3 | 1% | 🟢 Faible |
| **TOTAL** | **$273** | **100%** | |

### 3.2 Visualisation des Coûts

```
COÛT TOTAL : 273 USD/mois
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RDS (120 USD)        ████████████████████ (44%)
NAT (70 USD)         ████████████ (26%)
EC2 (50 USD)         █████████ (18%)
ALB (20 USD)         ███ (7%)
CloudWatch (10 USD)  ██ (4%)
S3 (3 USD)           █ (1%)
```

---

##  4. Opportunités d'Optimisation

### 4.1 🔴 PRIORITÉ HAUTE : Optimiser NAT Gateway

**Économie potentielle : 35-40 USD/mois (13-15%)**

#### Option 1 : Un seul NAT Gateway (Économie : ~$35/mois)

```yaml
Configuration Actuelle:
  NAT Gateway Zone A : $35/mois
  NAT Gateway Zone B : $35/mois
  Total : $70/mois

Configuration Optimisée:
  NAT Gateway centralisé (Zone A) : $35/mois
  Économie : $35/mois (50%)

Risque:
  - Single Point of Failure
  - Si NAT tombe, pas d'accès Internet sortant
  
Acceptable pour:
  - Phase de démarrage startup
  - Budget limité
  - Trafic non critique
```

#### Option 2 : VPC Endpoints pour S3 & CloudWatch (Économie : ~$15/mois)

```yaml
Problème:
  Trafic EC2 → S3/CloudWatch passe par NAT Gateway
  = Data Processing facturé

Solution:
  VPC Endpoints (Gateway & Interface)
  Trafic reste dans le VPC = Gratuit

Configuration:
  - S3 Gateway Endpoint : Gratuit
  - CloudWatch Interface Endpoint : $7.30/mois
  
Économie:
  Réduction Data Processing : ~$15-20/mois
  ROI : Positif si > 150GB/mois via NAT
```

---

### 4.2 🔴 PRIORITÉ HAUTE : Reserved Instances (RI)

**Économie potentielle : 30-40 USD/mois (11-15%)**

#### RDS Reserved Instances (1 an, No Upfront)

```yaml
RDS db.t3.small Multi-AZ On-Demand:
  Prix actuel : $0.136/h
  Coût mensuel : $99.28

RDS db.t3.small Multi-AZ Reserved (1 an):
  Prix RI : $0.099/h (27% de réduction)
  Coût mensuel : $72.27
  Économie : $27/mois (27%)
```

#### EC2 Reserved Instances (1 an, No Upfront)

```yaml
EC2 t3.small On-Demand:
  Prix actuel : $0.0208/h × 2 = $30.37/mois

EC2 t3.small Reserved (1 an):
  Prix RI : $0.0125/h × 2 = $18.25/mois
  Économie : $12/mois (40%)

Total RI EC2 + RDS:
  Économie : $27 + $12 = $39/mois (14%)
```

---

### 4.3 🟡 PRIORITÉ MOYENNE : Optimiser RDS

**Économie potentielle : 20-30 USD/mois (7-11%)**

#### Option 1 : Optimiser Stockage RDS

```yaml
Stockage Actuel:
  100GB gp3 Multi-AZ : $23/mois

Optimisation:
  Si < 50GB utilisés réellement
  → Réduire à 50GB : $11.50/mois
  Économie : $11.50/mois (50%)

Note:
  Vérifier utilisation réelle dans RDS Metrics
```

---

### 4.4 🟢 PRIORITÉ FAIBLE : Optimisations Mineures

#### S3 Intelligent-Tiering

```yaml
S3 Standard : $0.023/GB = $2.30/mois (100GB)

S3 Intelligent-Tiering:
  Frequent Access : $0.023/GB
  Infrequent Access : $0.0125/GB
  
Économie estimée : $0.50-1/mois
```

---

##  5. Prévisions & Scalabilité

### 5.1 Scénarios de Croissance

#### Scénario 1 : Croissance Normale (+50% trafic/an)

| Mois | Trafic | Instances EC2 | RDS | Coût Estimé |
|------|--------|---------------|-----|-------------|
| **M1** | 1000 users/j | 2× t3.small | db.t3.small | $273 |
| **M3** | 1500 users/j | 2-3× t3.small | db.t3.small | $310 |
| **M6** | 2000 users/j | 3× t3.small | db.t3.medium | $420 |
| **M12** | 3000 users/j | 4× t3.small | db.t3.medium | $500 |

#### Scénario 2 : Croissance Forte (+100% trafic/an)

| Mois | Trafic | Instances EC2 | RDS | Coût Estimé |
|------|--------|---------------|-----|-------------|
| **M1** | 1000 users/j | 2× t3.small | db.t3.small | $273 |
| **M3** | 2000 users/j | 3× t3.small | db.t3.small | $330 |
| **M6** | 4000 users/j | 4× t3.medium | db.t3.medium | $600 |
| **M12** | 8000 users/j | 6× t3.medium | db.m5.large | $950 |

---

### 5.2 Projections 12 Mois

```
PROJECTION COÛTS (Croissance Normale)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

M1-M3  : $273/mois  ████
M4-M6  : $320/mois  █████
M7-M9  : $380/mois  ██████
M10-M12: $450/mois  ███████

Coût Annuel Total : ~$4,200
Avec Optimisations : ~$3,500 (-17%)
```

---

##  6. Recommandations Actionnables

### 6.1  ACTION IMMÉDIATE (Semaine 1)

####  Étape 1 : Activer Cost Explorer & Budgets

```bash
# AWS Console → Cost Management → Cost Explorer
1. Activer Cost Explorer (gratuit)
2. Créer Budget mensuel : $300
   - Alerte 80% : $240
   - Alerte 100% : $300
   - Alerte 120% : $360
3. Activer Billing Alerts (SNS)
```

####  Étape 2 : Implémenter Tags Complets

```hcl
tags = {
  Project      = "GreenLeaf"
  Environment  = "Production"
  Owner        = "Bassirou"
  CostCenter   = "IT-Infrastructure"
  Application  = "E-commerce"
  ManagedBy    = "Terraform"
  CreatedDate  = "2026-01-08"
}
```

---

### 6.2  ACTION COURT TERME (1-3 mois)

####  Décision #1 : NAT Gateway Strategy

**Analyser pendant 30 jours :**
```yaml
Métriques à surveiller:
  - Data Processing NAT : Si < 50GB/mois → 1 seul NAT OK
  - Uptime requis : Si 99.5% OK → 1 seul NAT acceptable
  - Budget : Si serré → 1 seul NAT

Options:
  - Option A : Passer à 1 NAT → Économie $35/mois ✅
  - Option B : Garder 2 NAT + VPC Endpoints → Économie $15/mois
```

####  Décision #2 : Reserved Instances

**Prérequis (attendre 90 jours) :**
```yaml
Vérifier:
  - Usage stable EC2/RDS (pas de changements)
  - Prévisions trafic (croissance prévisible)
  - Trésorerie (engagement 1 an)

Si OUI → Acheter RI:
  - RDS db.t3.small Multi-AZ : -$27/mois
  - EC2 2× t3.small : -$12/mois
  - Total : -$39/mois (14%)
```

---

### 6.3  ACTION MOYEN TERME (3-6 mois)

####  Évolution #1 : Ajouter CloudFront CDN

```yaml
Objectif:
  - Réduire Data Transfer EC2/ALB
  - Améliorer performance utilisateur
  - Cache images/CSS/JS statiques

Coût additionnel : +$15-25/mois
Économie Data Transfer : -$10-15/mois
Performance : +50% temps chargement
```

####  Évolution #2 : Ajouter ElastiCache Redis

```yaml
Objectif:
  - Cache sessions utilisateurs
  - Cache Magento (Full Page Cache)
  - Réduire charge RDS de 40-60%

Configuration:
  cache.t3.micro (1 vCPU, 0.5GB)
  Coût : $12/mois

Bénéfices:
  - Temps réponse : -30%
  - Charge RDS : -50%
  - Retarde upgrade RDS
```

---

##  7. Tableau de Bord FinOps

### 7.1 KPIs à Suivre (Hebdomadaire)

| KPI | Cible | Alerte | Action |
|-----|-------|--------|--------|
| **Coût Total** | $273 | > $300 | Investiguer pics |
| **Coût par User** | $0.009 | > $0.012 | Optimiser |
| **CPU EC2 Moyen** | 30-50% | > 70% | Scale up |
| **CPU RDS Moyen** | 40-60% | > 80% | Upgrade |
| **Data Transfer OUT** | < 100GB | > 150GB | CloudFront |
| **NAT Data Processing** | < 50GB | > 100GB | VPC Endpoints |

---

### 7.2 Checklist Revue FinOps Mensuelle

```markdown
## Revue FinOps - [Mois]

### 1. Analyse Coûts
- [ ] Exporter rapport Cost Explorer
- [ ] Identifier variations > 10%
- [ ] Analyser services top 3 coûts
- [ ] Vérifier anomalies

### 2. Ressources
- [ ] Identifier ressources inutilisées
- [ ] Vérifier dimensionnement instances
- [ ] Analyser snapshots anciens

### 3. Optimisations
- [ ] Vérifier éligibilité RI
- [ ] Analyser opportunités Savings Plans
- [ ] Évaluer nouveaux services

### 4. Prévisions
- [ ] Mettre à jour prévisions 3 mois
- [ ] Ajuster budgets
- [ ] Planifier investissements

### 5. Reporting
- [ ] Présenter rapport équipe
- [ ] Documenter décisions
- [ ] Planifier actions mois prochain
```

---

##  8. Plan d'Action Priorisé

### 8.1 Roadmap Optimisation FinOps

```
PHASE 1 : QUICK WINS (Semaine 1-4)
┌─────────────────────────────────────────────┐
│ ✅ Activer Cost Explorer & Budgets          │
│ ✅ Implémenter tags complets                │
│ ✅ Créer dashboards CloudWatch              │
│ 💰 Économie : $0 (préparation)              │
└─────────────────────────────────────────────┘

PHASE 2 : OPTIMISATIONS RÉSEAUX (Mois 1-3)
┌─────────────────────────────────────────────┐
│ 🔧 Décision NAT Gateway (1 vs 2)            │
│ 🔧 Implémenter VPC Endpoints                │
│ 💰 Économie : $35-50/mois (13-18%)          │
└─────────────────────────────────────────────┘

PHASE 3 : RESERVED INSTANCES (Mois 3-4)
┌─────────────────────────────────────────────┐
│ 🔧 Vérifier usage stable 90 jours           │
│ 🔧 Acheter RI 1 an (no upfront)             │
│ 💰 Économie : $39/mois (14%)                │
└─────────────────────────────────────────────┘

PHASE 4 : PERFORMANCE & CACHE (Mois 4-6)
┌─────────────────────────────────────────────┐
│ 🚀 Implémenter CloudFront CDN               │
│ 🚀 Ajouter ElastiCache Redis                │
│ 💰 Coût : +$27/mois                         │
│ 💰 ROI : Performance + Base pour scale      │
└─────────────────────────────────────────────┘
```

---

### 8.2 Économies Cumulées Projetées

```
ÉCONOMIES PROJETÉES (12 MOIS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Mois 1-2  : Baseline              $273/mois
Mois 3    : NAT + VPC Endpoints   $223/mois (-$50)
Mois 4    : Reserved Instances    $184/mois (-$39)
Mois 6    : CloudFront + Cache    $196/mois (+$12 invest)

ÉCONOMIE ANNUELLE : ~$900/an (27%)
Coût Optimisé : $184/mois vs $273/mois initial
```

---

##  9. Conclusion & Synthèse

### 9.1 Récapitulatif Exécutif

```
┌────────────────────────────────────────────────────┐
│       ANALYSE FINOPS - GREENLEAF E-COMMERCE        │
├────────────────────────────────────────────────────┤
│ Coût Actuel           : $273/mois                  │
│ Coût Optimisé (6 mois): $184/mois                  │
│ Économie Potentielle  : $89/mois (33%)             │
│                                                    │
│ Efficacité Budget     : ★★★★☆ (Très Bon)         │
│ Scalabilité           : ★★★★★ (Excellente)       │
│ Sécurité              : ★★★★★ (Multi-AZ)         │
│ Optimisation Possible : ★★★★☆ (Opportunités)     │
└────────────────────────────────────────────────────┘
```

### 9.2 Top 3 Recommandations Immédiates

```
 PRIORITÉ #1 : Activer Cost Management
   → Cost Explorer + Budgets + Alertes
   → Action : Semaine 1
   → Coût : $0
   → Gain : Visibilité complète coûts

 PRIORITÉ #2 : Décision NAT Gateway
   → Analyser trafic 30 jours
   → Décider : 1 NAT vs 2 NAT + VPC Endpoints
   → Action : Mois 1-2
   → Gain : $35-50/mois

 PRIORITÉ #3 : Reserved Instances
   → Attendre 90 jours d'usage stable
   → Acheter RI EC2 + RDS (1 an)
   → Action : Mois 3-4
   → Gain : $39/mois (14%)
```

---

##  10. Contact & Support

### Équipe FinOps

**Analyse Coûts :**  
👤 Bassirou  
📧 bassirou@greenleaf.com  
🎯 Responsable : Architecture & Infrastructure

**Optimisation Cloud :**  
👤 [Bassirou]  
🎯 Responsable : Reserved Instances & Savings Plans

**Budgets & Reporting :**  
👤 [Bassirou]  
🎯 Responsable : Dashboards & Alertes

---

### Prochaines Échéances

```
📅 Revue FinOps Hebdomadaire : Tous les lundis 10h
📅 Revue FinOps Mensuelle    : 1er de chaque mois
📅 Décision NAT Gateway      : 15 Février 2026
📅 Achat Reserved Instances  : 15 Mars 2026
📅 Audit Architecture        : Tous les 6 mois
```

---

### Documentation Complémentaire

- 📄 Document Architecture Technique : `docs/architecture.md`
- 📄 Guide Déploiement Terraform : `docs/deployment-guide.md`
- 📄 Playbooks Ansible : `ansible/playbooks/`
- 📊 Dashboards CloudWatch : AWS Console
- 💰 Cost Explorer : AWS Billing Console

---

**Document créé le :** 08 Janvier 2026  
**Version :** 1.0 (Révisée avec coûts réels)  
**Prochaine révision :** 08 Février 2026 (après 30 jours)  
**Validé par :** Bassirou - DevOps Engineer

---

