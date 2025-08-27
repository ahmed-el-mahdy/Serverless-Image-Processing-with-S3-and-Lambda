output "input_bucket_name" {
  description = "Name of the input S3 bucket"
  value       = aws_s3_bucket.input_bucket.bucket
}

output "output_bucket_name" {
  description = "Name of the output S3 bucket"
  value       = aws_s3_bucket.output_bucket.bucket
}

output "lambda_function_arn" {
  description = "ARN of the image processing Lambda function"
  value       = aws_lambda_function.image_processor.arn
}

output "lambda_function_name" {
  description = "Name of the image processing Lambda function"
  value       = aws_lambda_function.image_processor.function_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for metadata"
  value       = aws_dynamodb_table.image_metadata.name
}

output "input_bucket_arn" {
  description = "ARN of the input S3 bucket"
  value       = aws_s3_bucket.input_bucket.arn
}

output "output_bucket_arn" {
  description = "ARN of the output S3 bucket"
  value       = aws_s3_bucket.output_bucket.arn
}

