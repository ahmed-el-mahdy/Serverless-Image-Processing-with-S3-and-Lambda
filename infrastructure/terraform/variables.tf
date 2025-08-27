variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
  default     = "serverless-image-processing"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "resize_width" {
  description = "Target width for resized images"
  type        = number
  default     = 800
}

variable "resize_height" {
  description = "Target height for resized images"
  type        = number
  default     = 600
}

