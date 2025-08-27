# Terraform Infrastructure for Serverless Image Processing

This directory contains Terraform configuration files to deploy the serverless image processing infrastructure on AWS.

## Architecture

The Terraform configuration creates:
- Input S3 bucket for original images
- Output S3 bucket for processed images
- Lambda function for image processing
- IAM roles and policies
- S3 bucket notifications
- DynamoDB table for metadata (optional)
- CloudWatch log groups

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (version >= 1.0)
3. Lambda function code in `../../lambda-functions/image-processor/`

## Usage

### Initialize Terraform
```bash
terraform init
```

### Plan the deployment
```bash
terraform plan
```

### Deploy the infrastructure
```bash
terraform apply
```

### Destroy the infrastructure
```bash
terraform destroy
```

## Configuration

### Variables

You can customize the deployment by modifying variables in `variables.tf` or by creating a `terraform.tfvars` file:

```hcl
aws_region = "us-west-2"
project_name = "my-image-processor"
environment = "prod"
resize_width = 1024
resize_height = 768
```

### Outputs

After deployment, Terraform will output:
- Input bucket name
- Output bucket name
- Lambda function ARN and name
- DynamoDB table name

## Security Features

- S3 buckets have public access blocked
- Server-side encryption enabled on S3 buckets
- Versioning enabled on S3 buckets
- IAM roles follow least privilege principle
- DynamoDB table has encryption at rest enabled

## Monitoring

- CloudWatch logs are automatically created for the Lambda function
- Log retention is set to 14 days by default
- DynamoDB streams are enabled for the metadata table

