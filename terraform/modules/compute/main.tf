# MODULE COMPUTE - EC2, Auto Scaling, ALB

# Application Load Balancer
resource "aws_lb" "main" {
  name_prefix        = substr("${var.project_name}-", 0, 6)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

# Target Group pour les instances EC2
resource "aws_lb_target_group" "magento" {
  name_prefix = substr("${var.project_name}-", 0, 6)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health.php"
    matcher             = "200,301,302"
  }

  deregistration_delay = 30

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-tg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Listener HTTP (port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.magento.arn
  }
}

# User Data Script pour installation initiale
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Logs
    exec > >(tee /var/log/user-data.log)
    exec 2>&1
    
    echo "========================================="
    echo "GreenLeaf EC2 Instance Setup"
    echo "========================================="
    
    # Mise à jour du système
    apt-get update
    apt-get upgrade -y
    
    # Installation des dépendances de base
    apt-get install -y \
      python3 \
      python3-pip \
      curl \
      wget \
      git \
      unzip
    
    # Installation d'Ansible (pour configuration automatique)
    pip3 install ansible
    
    # Créer un fichier de santé pour l'ALB
    mkdir -p /var/www/html
    echo "<?php http_response_code(200); echo 'OK'; ?>" > /var/www/html/health.php
    
    # Variables d'environnement
    export RDS_ENDPOINT="${var.rds_endpoint}"
    export DB_NAME="${var.db_name}"
    export DB_USER="${var.db_username}"
    export S3_BUCKET="${var.s3_bucket_name}"
    
    echo "RDS_ENDPOINT=$RDS_ENDPOINT" >> /etc/environment
    echo "DB_NAME=$DB_NAME" >> /etc/environment
    echo "S3_BUCKET=$S3_BUCKET" >> /etc/environment
    
    echo "========================================="
    echo "Instance ready for Ansible configuration"
    echo "========================================="
  EOF
}

# Launch Template pour Auto Scaling
resource "aws_launch_template" "magento" {
  name_prefix   = "${var.project_name}-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.ec2_security_group_id]

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = base64encode(local.user_data)

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-${var.environment}-magento"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "magento" {
  name_prefix         = "${var.project_name}-${var.environment}-"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  health_check_type   = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.magento.arn]

  launch_template {
    id      = aws_launch_template.magento.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Auto Scaling Policy - Scale UP (CPU élevé)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-${var.environment}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.magento.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.magento.name
  }

  alarm_description = "Scale up if CPU > 70%"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# Auto Scaling Policy - Scale DOWN (CPU faible)
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-${var.environment}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.magento.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.magento.name
  }

  alarm_description = "Scale down if CPU < 30%"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}