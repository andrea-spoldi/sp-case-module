# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-30

### Added

- Initial release of the AWS Container Application Infrastructure Module
- Core Features:
  - Amazon ECR repository with automatic image building and pushing
  - ECS Fargate cluster and service setup
  - Application Load Balancer with security groups
  - CloudFront CDN integration (optional)
  - CloudWatch logging configuration
  - Docker image building with content-based triggers
  - Header-based request routing
  - VPC networking integration

### Infrastructure Components

- ECR
  - Repository creation
  - Docker image build and push automation
  - Content hash-based rebuild triggers

- ECS
  - Fargate cluster
  - Service deployment
  - Task definition with ARM64 architecture
  - CloudWatch log group configuration
  - IAM roles and policies

- Networking
  - Application Load Balancer
  - Security groups for ALB and ECS tasks
  - Public and private subnet support
  - Header-based routing rules

- CDN
  - Optional CloudFront distribution
  - Custom origin configuration
  - Access logging capability
  - Header forwarding

### Security

- Implemented security best practices:
  - Private subnet deployment for ECS tasks
  - Restricted security group rules
  - Header-based request filtering
  - Least privilege IAM policies
  - HTTPS redirection in CloudFront

### Documentation

- Comprehensive README with:
  - Usage examples
  - Variable definitions
  - Architecture overview
  - Security considerations
  - Implementation notes

[1.0.0]: https://github.com/andrea-spoldi/sp-case-module/releases/tag/v1.0.0
