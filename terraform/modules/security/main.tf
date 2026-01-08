# ============================================================================
# MODULE SECURITY - SECURITY GROUPS
# ============================================================================

# ----------------------------------------------------------------------------
# Security Group pour ALB (Application Load Balancer)
# ----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Autoriser HTTP depuis Internet
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser HTTPS depuis Internet
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser tout le trafic sortant
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------------------------------
# Security Group pour Instances EC2 (Magento)
# ----------------------------------------------------------------------------
resource "aws_security_group" "ec2" {
  name_prefix = "${var.project_name}-${var.environment}-ec2-"
  description = "Security group for EC2 instances running Magento"
  vpc_id      = var.vpc_id

  # Autoriser HTTP depuis ALB uniquement
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Autoriser HTTPS depuis ALB uniquement
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Autoriser SSH depuis IPs spécifiques (pour administration)
  ingress {
    description = "SSH from specific IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  # Autoriser tout le trafic sortant
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------------------------------
# Security Group pour RDS (Base de données MySQL)
# ----------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  description = "Security group for RDS MySQL database"
  vpc_id      = var.vpc_id

  # Autoriser MySQL depuis les instances EC2 uniquement
  ingress {
    description     = "MySQL from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  # Autoriser tout le trafic sortant
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-rds-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------------------------------
# Security Group pour ElastiCache (Redis/Memcached - Optionnel)
# ----------------------------------------------------------------------------
resource "aws_security_group" "cache" {
  name_prefix = "${var.project_name}-${var.environment}-cache-"
  description = "Security group for ElastiCache"
  vpc_id      = var.vpc_id

  # Autoriser Redis depuis les instances EC2
  ingress {
    description     = "Redis from EC2 instances"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-cache-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}