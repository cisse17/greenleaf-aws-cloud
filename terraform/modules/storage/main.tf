# MODULE STORAGE - S3 pour Médias Magento

# Bucket S3 pour les médias (images produits, etc.)
resource "aws_s3_bucket" "media" {
  bucket_prefix = "${var.project_name}-${var.environment}-media-"

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-${var.environment}-media"
      Purpose = "Magento media storage"
    }
  )
}

# Configuration du versioning
resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Chiffrement du bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Pour Bloquer l'accès public (sécurité)
resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Politique de cycle de vie (optimisation coûts)
resource "aws_s3_bucket_lifecycle_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    filter {
      prefix = ""  # je l'ai ajouté pour éviter le warning
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }

  rule {
    id     = "delete-incomplete-uploads"
    status = "Enabled"

    filter {
      prefix = ""  
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# CORS pour accès depuis Magento
resource "aws_s3_bucket_cors_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Policy pour permettre l'accès depuis CloudFront et EC2
resource "aws_s3_bucket_policy" "media" {
  bucket = aws_s3_bucket.media.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2Access"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_s3_access.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.media.arn,
          "${aws_s3_bucket.media.arn}/*"
        ]
      }
    ]
  })
}

# IAM Role pour EC2 (accès S3)
resource "aws_iam_role" "ec2_s3_access" {
  name_prefix = "${var.project_name}-ec2-s3-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy pour accès S3
resource "aws_iam_role_policy" "ec2_s3_access" {
  name_prefix = "${var.project_name}-ec2-s3-policy-"
  role        = aws_iam_role.ec2_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.media.arn,
          "${aws_s3_bucket.media.arn}/*"
        ]
      }
    ]
  })
}

# Instance Profile pour EC2
resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${var.project_name}-ec2-profile-"
  role        = aws_iam_role.ec2_s3_access.name

  tags = var.tags
}