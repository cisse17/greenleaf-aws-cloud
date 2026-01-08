# ============================================================================
# MODULE DATABASE - RDS MySQL
# ============================================================================

# ----------------------------------------------------------------------------
# Subnet Group pour RDS (Multi-AZ)
# ----------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-"
  description = "Subnet group for RDS MySQL"
  subnet_ids  = var.db_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

# ----------------------------------------------------------------------------
# Parameter Group MySQL (Optimisations Magento)
# ----------------------------------------------------------------------------
resource "aws_db_parameter_group" "magento" {
  name_prefix = "${var.project_name}-${var.environment}-"
  family      = "mysql8.0"
  description = "Custom parameter group for Magento"

  # Optimisations pour Magento
  parameter {
    name  = "max_connections"
    value = "500"
  }

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-db-params"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------------------------------
# Instance RDS MySQL
# ----------------------------------------------------------------------------
resource "aws_db_instance" "magento" {
  identifier     = "${var.project_name}-${var.environment}-db"
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Stockage
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2  # Auto-scaling du stockage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Base de données
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  # Réseau et Sécurité
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  # Configuration
  parameter_group_name = aws_db_parameter_group.magento.name
  multi_az             = var.enable_multi_az
  
  # Backup et Maintenance
  backup_retention_period   = var.backup_retention_period
  backup_window             = "03:00-04:00"  # 3h-4h du matin (UTC)
  maintenance_window        = "Mon:04:00-Mon:05:00"
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null
  
  # Monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  monitoring_interval             = 60
  monitoring_role_arn            = aws_iam_role.rds_monitoring.arn

  # Performance Insights (pour optimisation)
  performance_insights_enabled    = false
  # performance_insights_retention_period = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-mysql"
    }
  )

  lifecycle {
    prevent_destroy = false  # Mettre à true en production !
    ignore_changes  = [password]  # Ne pas recréer si le mot de passe change
  }
}

# ----------------------------------------------------------------------------
# IAM Role pour Enhanced Monitoring
# ----------------------------------------------------------------------------
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${var.project_name}-rds-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ----------------------------------------------------------------------------
# Alarme CloudWatch - CPU élevé
# ----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "RDS CPU utilization is too high"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.magento.id
  }

  tags = var.tags
}

# ----------------------------------------------------------------------------
# Alarme CloudWatch - Connexions élevées
# ----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.project_name}-${var.environment}-db-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "400"
  alarm_description   = "RDS database connections are too high"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.magento.id
  }

  tags = var.tags
}