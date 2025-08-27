# Contributing to Serverless Image Processing

We welcome contributions to the Serverless Image Processing project! This document provides guidelines for contributing to the project.

## Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow. Please read and follow our [Code of Conduct](./CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. Check if the issue already exists in our [issue tracker](https://github.com/ahmed-el-mahdy/serverless-image-processing/issues)
2. Search through [closed issues](https://github.com/ahmed-el-mahdy/serverless-image-processing/issues?q=is%3Aissue+is%3Aclosed) to see if it was already addressed
3. If you find a similar issue, add a comment with your specific details

When creating a new issue, please include:

- A clear and descriptive title
- A detailed description of the problem
- Steps to reproduce the issue
- Expected vs actual behavior
- Environment details (AWS region, Lambda runtime, etc.)
- Relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:

1. Check if the enhancement has already been suggested
2. Create an issue with the "enhancement" label
3. Provide a clear description of the enhancement
4. Explain why this enhancement would be useful
5. Include examples of how it would work

### Pull Requests

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Add or update tests as needed
5. Update documentation
6. Ensure all tests pass
7. Submit a pull request

#### Pull Request Guidelines

- Use a clear and descriptive title
- Reference any related issues
- Provide a detailed description of changes
- Include screenshots for UI changes
- Ensure code follows project conventions
- Add appropriate tests
- Update documentation as needed

## Development Setup

### Prerequisites

- AWS CLI configured with appropriate permissions
- Python 3.9+
- Node.js 18.x+
- Terraform 1.0+ (optional)

### Local Development

1. Clone the repository:
```bash
git clone https://github.com/ahmed-el-mahdy/serverless-image-processing.git
cd serverless-image-processing
```

2. Set up Python virtual environment:
```bash
cd source/lambda-functions/image-processor
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. Run tests:
```bash
python -m pytest tests/
```

### Testing

#### Unit Tests

Run unit tests for the Lambda function:

```bash
cd source/lambda-functions/image-processor
python -m pytest tests/unit/
```

#### Integration Tests

Run integration tests (requires AWS credentials):

```bash
cd source/lambda-functions/image-processor
python -m pytest tests/integration/
```

#### Infrastructure Tests

Test infrastructure templates:

```bash
# CloudFormation
cd infrastructure/cloudformation
sam validate

# Terraform
cd infrastructure/terraform
terraform validate
terraform plan
```

### Code Style

- Follow PEP 8 for Python code
- Use meaningful variable and function names
- Add docstrings for all functions and classes
- Keep functions focused and small
- Use type hints where appropriate

### Documentation

- Update README.md for user-facing changes
- Update inline code documentation
- Add examples for new features
- Update the comprehensive documentation in `docs/`

## Project Structure

```
serverless-image-processing/
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── deployment/             # Deployment scripts and utilities
├── docs/                   # Comprehensive documentation
├── infrastructure/         # Infrastructure as Code
│   ├── cloudformation/     # CloudFormation templates
│   └── terraform/          # Terraform configurations
├── source/                 # Source code
│   └── lambda-functions/   # Lambda function code
├── tests/                  # Test files
├── CHANGELOG.md           # Change log
├── CODE_OF_CONDUCT.md     # Code of conduct
├── CONTRIBUTING.md        # This file
├── LICENSE                # License file
├── README.md              # Main project README
└── VERSION.txt            # Version information
```

## Release Process

1. Update version in `VERSION.txt`
2. Update `CHANGELOG.md` with new features and fixes
3. Create a pull request with version updates
4. After merge, create a release tag
5. GitHub Actions will automatically build and deploy

## Community

- Join our [discussions](https://github.com/ahmed-el-mahdy/serverless-image-processing/discussions)
- Follow us on [Twitter](https://twitter.com/ahmed-el-mahdy)
- Read our [blog posts](https://blog.ahmed-el-mahdy.com)

## Questions?

If you have questions about contributing, please:

1. Check the [FAQ](./docs/FAQ.md)
2. Search existing [discussions](https://github.com/ahmed-el-mahdy/serverless-image-processing/discussions)
3. Create a new discussion
4. Contact the maintainers

Thank you for contributing to Serverless Image Processing!

