# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Data source for current AWS region
data "aws_region" "current" {}

# Create a ZIP file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-functions/image-processor"
  output_path = "${path.module}/lambda-function.zip"
}

# Input S3 Bucket for original images
resource "aws_s3_bucket" "input_bucket" {
  bucket = "${var.project_name}-input-images-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "input_bucket_versioning" {
  bucket = aws_s3_bucket.input_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "input_bucket_encryption" {
  bucket = aws_s3_bucket.input_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "input_bucket_pab" {
  bucket = aws_s3_bucket.input_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output S3 Bucket for processed images
resource "aws_s3_bucket" "output_bucket" {
  bucket = "${var.project_name}-output-images-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "output_bucket_versioning" {
  bucket = aws_s3_bucket.output_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "output_bucket_encryption" {
  bucket = aws_s3_bucket.output_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "output_bucket_pab" {
  bucket = aws_s3_bucket.output_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda Function
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.input_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.output_bucket.arn}/*"
      }
    ]
  })
}

# Attach basic execution role policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "image_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-image-processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 512

  environment {
    variables = {
      OUTPUT_BUCKET  = aws_s3_bucket.output_bucket.bucket
      RESIZE_WIDTH   = var.resize_width
      RESIZE_HEIGHT  = var.resize_height
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-image-processor"
  retention_in_days = 14
}

# Lambda permission for S3 to invoke the function
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

# Optional: DynamoDB table for metadata storage
resource "aws_dynamodb_table" "image_metadata" {
  name           = "${var.project_name}-image-metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "image_id"
  range_key      = "upload_timestamp"

  attribute {
    name = "image_id"
    type = "S"
  }

  attribute {
    name = "upload_timestamp"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-image-metadata"
    Environment = var.environment
  }
}

