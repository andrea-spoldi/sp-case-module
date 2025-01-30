# AWS Container Application Infrastructure Module

This Terraform module sets up a complete infrastructure for running containerized applications on AWS using ECS Fargate, including container registry, load balancer, and optional CloudFront CDN.

## Features

- Amazon ECR repository for container images
- ECS Fargate cluster and service
- Application Load Balancer with security groups
- CloudFront distribution (optional)
- Docker image building and pushing
- CloudWatch logging
- VPC networking integration
- Header-based routing

## Requirements

- Terraform >= 1.9.5
- AWS provider >= 5.84.0
- Docker provider >= 3.0.2
- Docker daemon running locally
- AWS credentials configured

## Usage

### Context Hash Calculation

The module requires a context hash to trigger rebuilds when source files change. Here's how to calculate it:

```hcl
locals {
  # Calculate hash of all files in build context to trigger rebuilds when files change
  context_hash = sha1(join("", [
    for f in fileset("${var.build_context}", "**/*") :
    filesha1("${var.build_context}/${f}")
  ]))
}
```

This calculation:
1. Uses `fileset` to get all files in the build context directory
2. Calculates SHA1 hash for each file
3. Joins all hashes and creates a final SHA1 hash
4. Changes to any source file will result in a new hash, triggering a rebuild

### With Existing VPC Resources

```hcl
locals {
  context_hash = sha1(join("", [
    for f in fileset("${var.build_context}", "**/*") :
    filesha1("${var.build_context}/${f}")
  ]))
}

module "application" {
  source = "path/to/module"

  # Required VPC variables - using existing resources
  vpc_id             = "vpc-123456"
  private_subnet_ids = ["subnet-private1", "subnet-private2"]
  public_subnet_ids  = ["subnet-public1", "subnet-public2"]

  # Other required variables
  registry_name      = "my-app-registry"
  cluster_name       = "my-ecs-cluster"
  build_context      = "./app"
  build_dockerfile   = "Dockerfile"
  container_name     = "my-container"
  service_name       = "my-service"
  service_port       = 3000
  context_hash       = local.context_hash  # Pass the calculated hash

  # Optional CDN configuration
  is_cdn_logging_enabled = false
  cdn_logging_bucket     = ""

  # Optional ALB configuration
  is_alb_logging_enabled = false
  alb_logging_bucket = ""
}
```

### With VPC Module Integration

```hcl
locals {
  context_hash = sha1(join("", [
    for f in fileset("${var.build_context}", "**/*") :
    filesha1("${var.build_context}/${f}")
  ]))
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

module "application" {
  source = "path/to/module"

  # Required VPC variables - using VPC module outputs
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  # Other required variables
  registry_name      = "my-app-registry"
  cluster_name       = "my-ecs-cluster"
  build_context      = "./app"
  build_dockerfile   = "Dockerfile"
  container_name     = "my-container"
  service_name       = "my-service"
  service_port       = 3000
  context_hash       = local.context_hash  # Pass the calculated hash

  # Optional CDN configuration
  is_cdn_logging_enabled = false
  cdn_logging_bucket     = ""

  # Optional ALB configuration
  is_alb_logging_enabled = false
  alb_logging_bucket = ""
}
```

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| vpc_id | ID of the VPC where resources will be created. Can be provided directly or via VPC module output | string | yes |
| registry_name | Name for the ECR repository | string | yes |
| cluster_name | Name for the ECS cluster | string | yes |
| build_context | Path to the Docker build context | string | yes |
| build_dockerfile | Path to the Dockerfile | string | yes |
| container_name | Name for the container | string | yes |
| service_name | Name for the ECS service | string | yes |
| service_port | Port the container service listens on | number | yes |
| private_subnet_ids | List of private subnet IDs. Can be provided directly or via VPC module output | list(string) | yes |
| public_subnet_ids | List of public subnet IDs. Can be provided directly or via VPC module output | list(string) | yes |
| context_hash | SHA1 hash of all files in build context to trigger rebuilds when source files change | string | yes |
| is_cdn_logging_enabled | Enable CloudFront access logging | bool | no |
| cdn_logging_bucket | S3 bucket for CloudFront logs | string | no |
| is_alb_logging_enabled | Enable Application LoadBalancer access logging | bool | no |
| alb_logging_bucket | S3 bucket for Application LoadBalancer logs | string | no |

## Outputs

| Name | Description |
|------|-------------|
| repoUrl | URL of the created ECR repository |

## Architecture

The module creates:
1. ECR repository for container images
2. ECS Fargate cluster
3. ECS task definition with CloudWatch logging
4. Application Load Balancer with security groups
5. ECS service integrated with the ALB
6. CloudFront distribution (if enabled)

## Security

- Private subnets for ECS tasks
- Security groups controlling access
- Header-based request filtering
- HTTPS redirect for CloudFront
- IAM roles with least privilege

## Notes

1. The container runs on ARM64 architecture
2. ALB requires header `x-my-header: letMeIn` for access
3. CloudFront is configured to forward this header
4. Container is deployed in private subnets
5. Load balancer is in public subnets
6. VPC infrastructure can be provided either directly or through a VPC module

## Troubleshooting

### Common Issues

#### .docker/config.json not found

**Error:**
```
Error: Error building image: exit status 1: Error: Cannot perform an interactive login from a non TTY device; ensure ~/.docker/config.json exists
```

**Solution:**
Create an empty Docker config file:
```bash
mkdir -p ~/.docker
touch ~/.docker/config.json
```

This error typically occurs when Docker can't find its configuration file. Creating an empty config file usually resolves the issue.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Create a pull request

## License

This module is licensed under the MIT License.
