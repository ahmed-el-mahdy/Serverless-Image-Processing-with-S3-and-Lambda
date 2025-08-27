#!/bin/bash

# Serverless Image Processing Deployment Script
# This script automates the deployment of the serverless image processing solution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEPLOYMENT_TYPE="cloudformation"
STACK_NAME="serverless-image-processing"
AWS_REGION="us-east-1"
PROJECT_NAME="serverless-image-processing"
RESIZE_WIDTH=800
RESIZE_HEIGHT=600

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE           Deployment type: cloudformation or terraform (default: cloudformation)"
    echo "  -s, --stack-name NAME     CloudFormation stack name (default: serverless-image-processing)"
    echo "  -r, --region REGION       AWS region (default: us-east-1)"
    echo "  -p, --project-name NAME   Project name for resource naming (default: serverless-image-processing)"
    echo "  -w, --width WIDTH         Resize width (default: 800)"
    echo "  -h, --height HEIGHT       Resize height (default: 600)"
    echo "  --help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --type cloudformation --region us-west-2"
    echo "  $0 --type terraform --project-name my-image-processor"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            DEPLOYMENT_TYPE="$2"
            shift 2
            ;;
        -s|--stack-name)
            STACK_NAME="$2"
            shift 2
            ;;
        -r|--region)
            AWS_REGION="$2"
            shift 2
            ;;
        -p|--project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -w|--width)
            RESIZE_WIDTH="$2"
            shift 2
            ;;
        -h|--height)
            RESIZE_HEIGHT="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate deployment type
if [[ "$DEPLOYMENT_TYPE" != "cloudformation" && "$DEPLOYMENT_TYPE" != "terraform" ]]; then
    print_error "Invalid deployment type: $DEPLOYMENT_TYPE"
    print_error "Supported types: cloudformation, terraform"
    exit 1
fi

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured"
        exit 1
    fi
    
    if [[ "$DEPLOYMENT_TYPE" == "cloudformation" ]]; then
        # Check SAM CLI
        if ! command -v sam &> /dev/null; then
            print_error "AWS SAM CLI is not installed"
            exit 1
        fi
    elif [[ "$DEPLOYMENT_TYPE" == "terraform" ]]; then
        # Check Terraform
        if ! command -v terraform &> /dev/null; then
            print_error "Terraform is not installed"
            exit 1
        fi
    fi
    
    print_success "Prerequisites check passed"
}

# Deploy using CloudFormation/SAM
deploy_cloudformation() {
    print_status "Deploying using CloudFormation/SAM..."
    
    cd infrastructure/cloudformation
    
    # Build the application
    print_status "Building SAM application..."
    sam build
    
    # Deploy the application
    print_status "Deploying SAM application..."
    sam deploy \
        --stack-name "$STACK_NAME" \
        --region "$AWS_REGION" \
        --parameter-overrides \
            ProjectName="$PROJECT_NAME" \
            ResizeWidth="$RESIZE_WIDTH" \
            ResizeHeight="$RESIZE_HEIGHT" \
        --capabilities CAPABILITY_IAM \
        --no-confirm-changeset \
        --no-fail-on-empty-changeset
    
    # Get outputs
    print_status "Retrieving stack outputs..."
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$AWS_REGION" \
        --query 'Stacks[0].Outputs' \
        --output table
    
    cd ../..
}

# Deploy using Terraform
deploy_terraform() {
    print_status "Deploying using Terraform..."
    
    cd infrastructure/terraform
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan the deployment
    print_status "Planning Terraform deployment..."
    terraform plan \
        -var="aws_region=$AWS_REGION" \
        -var="project_name=$PROJECT_NAME" \
        -var="resize_width=$RESIZE_WIDTH" \
        -var="resize_height=$RESIZE_HEIGHT" \
        -out=tfplan
    
    # Apply the deployment
    print_status "Applying Terraform deployment..."
    terraform apply tfplan
    
    # Show outputs
    print_status "Terraform outputs:"
    terraform output
    
    cd ../..
}

# Main deployment function
main() {
    print_status "Starting deployment of Serverless Image Processing solution"
    print_status "Deployment type: $DEPLOYMENT_TYPE"
    print_status "AWS Region: $AWS_REGION"
    print_status "Project name: $PROJECT_NAME"
    
    check_prerequisites
    
    case $DEPLOYMENT_TYPE in
        cloudformation)
            deploy_cloudformation
            ;;
        terraform)
            deploy_terraform
            ;;
    esac
    
    print_success "Deployment completed successfully!"
    print_status "You can now upload images to the input bucket to test the solution"
}

# Run main function
main

