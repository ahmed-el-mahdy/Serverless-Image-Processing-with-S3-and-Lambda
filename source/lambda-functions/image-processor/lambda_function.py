import json
import boto3
import os
from PIL import Image
import io
from urllib.parse import unquote_plus

# Initialize AWS clients
s3_client = boto3.client('s3')

# Environment variables
OUTPUT_BUCKET = os.environ.get('OUTPUT_BUCKET')
RESIZE_WIDTH = int(os.environ.get('RESIZE_WIDTH', '800'))
RESIZE_HEIGHT = int(os.environ.get('RESIZE_HEIGHT', '600'))

def lambda_handler(event, context):
    """
    AWS Lambda function to process images uploaded to S3.
    Triggered by S3 PUT events, resizes images and stores them in output bucket.
    """
    
    try:
        # Parse the S3 event
        for record in event['Records']:
            # Get bucket and object key from the event
            source_bucket = record['s3']['bucket']['name']
            source_key = unquote_plus(record['s3']['object']['key'])
            
            # Skip if not an image file
            if not is_image_file(source_key):
                print(f"Skipping non-image file: {source_key}")
                continue
            
            print(f"Processing image: {source_key} from bucket: {source_bucket}")
            
            # Download the image from S3
            response = s3_client.get_object(Bucket=source_bucket, Key=source_key)
            image_content = response['Body'].read()
            
            # Process the image
            processed_image = resize_image(image_content)
            
            # Generate output key (add 'processed-' prefix)
            output_key = f"processed-{source_key}"
            
            # Upload processed image to output bucket
            s3_client.put_object(
                Bucket=OUTPUT_BUCKET,
                Key=output_key,
                Body=processed_image,
                ContentType=get_content_type(source_key)
            )
            
            print(f"Successfully processed and uploaded: {output_key}")
            
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Images processed successfully',
                'processed_count': len(event['Records'])
            })
        }
        
    except Exception as e:
        print(f"Error processing image: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }

def is_image_file(filename):
    """Check if the file is an image based on its extension."""
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp']
    return any(filename.lower().endswith(ext) for ext in image_extensions)

def resize_image(image_content):
    """Resize image to specified dimensions while maintaining aspect ratio."""
    # Open image with PIL
    image = Image.open(io.BytesIO(image_content))
    
    # Convert RGBA to RGB if necessary (for JPEG compatibility)
    if image.mode == 'RGBA':
        image = image.convert('RGB')
    
    # Calculate new dimensions maintaining aspect ratio
    original_width, original_height = image.size
    aspect_ratio = original_width / original_height
    
    if aspect_ratio > (RESIZE_WIDTH / RESIZE_HEIGHT):
        # Width is the limiting factor
        new_width = RESIZE_WIDTH
        new_height = int(RESIZE_WIDTH / aspect_ratio)
    else:
        # Height is the limiting factor
        new_height = RESIZE_HEIGHT
        new_width = int(RESIZE_HEIGHT * aspect_ratio)
    
    # Resize the image
    resized_image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # Save to bytes
    output_buffer = io.BytesIO()
    resized_image.save(output_buffer, format='JPEG', quality=85, optimize=True)
    output_buffer.seek(0)
    
    return output_buffer.getvalue()

def get_content_type(filename):
    """Get the appropriate content type based on file extension."""
    extension = filename.lower().split('.')[-1]
    content_types = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'bmp': 'image/bmp',
        'tiff': 'image/tiff',
        'webp': 'image/webp'
    }
    return content_types.get(extension, 'image/jpeg')

