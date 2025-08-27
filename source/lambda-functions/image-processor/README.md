# Image Processing Lambda Function

This AWS Lambda function processes images uploaded to an S3 bucket by resizing them and storing the processed images in an output bucket.

## Features

- **Automatic Triggering**: Triggered by S3 PUT events when images are uploaded
- **Image Resizing**: Resizes images while maintaining aspect ratio
- **Format Support**: Supports JPG, PNG, GIF, BMP, TIFF, and WebP formats
- **Error Handling**: Comprehensive error handling and logging
- **Environment Configuration**: Configurable resize dimensions and output bucket

## Environment Variables

- `OUTPUT_BUCKET`: The S3 bucket where processed images will be stored
- `RESIZE_WIDTH`: Target width for resized images (default: 800)
- `RESIZE_HEIGHT`: Target height for resized images (default: 600)

## Dependencies

- `Pillow`: For image processing operations
- `boto3`: AWS SDK for Python

## Deployment

1. Package the function with its dependencies
2. Create a Lambda function in AWS Console
3. Set up S3 trigger for the input bucket
4. Configure environment variables
5. Set appropriate IAM permissions

## IAM Permissions Required

The Lambda function needs the following permissions:
- `s3:GetObject` on the input bucket
- `s3:PutObject` on the output bucket
- Basic Lambda execution role permissions

