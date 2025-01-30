resource "aws_ecr_repository" "myApp_repo_AEBBD088" {
  name = var.registry_name
}
resource "docker_image" "myApp_image_B9B3BFB2" {
  name = aws_ecr_repository.myApp_repo_AEBBD088.repository_url
  triggers = {
    dirHash = "${var.context_hash}"
  }
  build {
    context    = var.build_context
    dockerfile = var.build_dockerfile
    no_cache   = true
  }
}
data "aws_caller_identity" "myApp_aws-caller-identity_61C4B62C" {
}
data "aws_ecr_authorization_token" "myApp_token_20261978" {
  registry_id = data.aws_caller_identity.myApp_aws-caller-identity_61C4B62C.account_id
  depends_on = [
    aws_ecr_repository.myApp_repo_AEBBD088,
  ]
}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.myApp_token_20261978.proxy_endpoint
    password = data.aws_ecr_authorization_token.myApp_token_20261978.password
    username = data.aws_ecr_authorization_token.myApp_token_20261978.user_name
  }
}
resource "docker_registry_image" "myApp_registryImage_5C4C5B07" {
  name = docker_image.myApp_image_B9B3BFB2.name
  triggers = {
    dirHash = "${docker_image.myApp_image_B9B3BFB2.repo_digest}"
  }
}

output "repoUrl" {
  value = aws_ecr_repository.myApp_repo_AEBBD088.repository_url
}
resource "aws_ecs_cluster" "workload_cluster_9BB60661" {
  name = var.cluster_name
}
resource "aws_ecs_cluster_capacity_providers" "workload_capacity_B111F4DB" {
  capacity_providers = [
    "FARGATE"
  ]
  cluster_name = aws_ecs_cluster.workload_cluster_9BB60661.name
  default_capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }
}
data "aws_region" "workload_region_F6F57590" {
}
resource "aws_iam_role" "workload_execution_role_B020DBFE" {
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Sid\":\"\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"}}]}"
}
resource "aws_iam_role_policy" "workload_execution_role_policy_60EB49A9" {
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"ecr:GetAuthorizationToken\",\"ecr:BatchCheckLayerAvailability\",\"ecr:GetDownloadUrlForLayer\",\"ecr:BatchGetImage\",\"logs:CreateLogStream\",\"logs:PutLogEvents\"],\"Resource\":\"*\"}]}"
  role   = aws_iam_role.workload_execution_role_B020DBFE.name
}
resource "aws_iam_role" "workload_task_role_983624F2" {
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Sid\":\"\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"}}]}"
}
resource "aws_iam_role_policy" "workload_task_role_policy_A4276A60" {
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"logs:CreateLogStream\",\"logs:PutLogEvents\"],\"Resource\":\"*\"}]}"
  role   = aws_iam_role.workload_task_role_983624F2.name
}
resource "aws_cloudwatch_log_group" "workload_loggroup_9D7BE7E1" {
  name              = "${aws_ecs_cluster.workload_cluster_9BB60661.name}/${var.container_name}"
  retention_in_days = 30
}
resource "aws_ecs_task_definition" "workload_task_D14CB3AA" {
  container_definitions = jsonencode([{ "name" = var.container_name, "image" = aws_ecr_repository.myApp_repo_AEBBD088.repository_url, "cpu" = 256, "memory" = 512, "environment" = [], "essential" = true, "portMappings" = [{ "protocol" = "tcp", "containerPort" = 3000 }], "logConfiguration" = { "logDriver" = "awslogs", "options" = { "awslogs-group" = aws_cloudwatch_log_group.workload_loggroup_9D7BE7E1.name, "awslogs-region" = data.aws_region.workload_region_F6F57590.name, "awslogs-stream-prefix" = var.container_name } } }])
  cpu                   = "256"
  execution_role_arn    = aws_iam_role.workload_execution_role_B020DBFE.arn
  family                = "service"
  memory                = "512"
  network_mode          = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  task_role_arn = aws_iam_role.workload_task_role_983624F2.arn
  runtime_platform {
    cpu_architecture = "ARM64"
  }
}
resource "aws_security_group" "alb_lb-security-group_44BBEC62" {
  egress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = null
    from_port   = 0
    ipv6_cidr_blocks = [
      "::/0"
    ]
    prefix_list_ids = null
    protocol        = "-1"
    security_groups = null
    self            = null
    to_port         = 0
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = null
    from_port   = 80
    ipv6_cidr_blocks = [
      "::/0"
    ]
    prefix_list_ids = null
    protocol        = "TCP"
    security_groups = null
    self            = null
    to_port         = 80
  }
  vpc_id = var.vpc_id
}
resource "aws_lb" "alb_7A364839" {
  internal           = false
  load_balancer_type = "application"
  name               = "alb"
  security_groups = [
    "${aws_security_group.alb_lb-security-group_44BBEC62.id}"
  ]
  subnets = var.public_subnet_ids
  dynamic "access_logs" {
    for_each = var.is_alb_logging_enabled ? [1] : []
    content {
      bucket  = var.cdn_logging_bucket
      enabled = var.is_alb_logging_enabled
    }
  }
}
resource "aws_lb_listener" "alb_lb-listener_A1DFDAB3" {
  load_balancer_arn = aws_lb.alb_7A364839.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}
resource "aws_lb_target_group" "alb_target-group_8180AAF8" {
  name        = "${var.service_name}-target-group"
  port        = var.service_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    enabled = true
    path    = "/"
  }
  depends_on = [
    aws_lb_listener.alb_lb-listener_A1DFDAB3,
  ]
}
resource "aws_lb_listener_rule" "alb_rule_69CE26D1" {
  listener_arn = aws_lb_listener.alb_lb-listener_A1DFDAB3.arn
  priority     = 100
  action {
    target_group_arn = aws_lb_target_group.alb_target-group_8180AAF8.arn
    type             = "forward"
  }
  condition {
    path_pattern {
      values = [
        "/*"
      ]
    }
  }
  condition {
    http_header {
      http_header_name = "x-my-header"
      values = [
        "letMeIn"
      ]
    }
  }
}
resource "aws_ecs_service" "alb_service_A77A0FB4" {
  cluster         = aws_ecs_cluster.workload_cluster_9BB60661.id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = var.service_name
  task_definition = aws_ecs_task_definition.workload_task_D14CB3AA.arn
  load_balancer {
    container_name   = var.container_name
    container_port   = var.service_port
    target_group_arn = aws_lb_target_group.alb_target-group_8180AAF8.arn
  }
  network_configuration {
    assign_public_ip = false
    security_groups = [
      "${aws_security_group.service-security-group.id}"
    ]
    subnets = var.private_subnet_ids
  }
  depends_on = [
    aws_lb_listener.alb_lb-listener_A1DFDAB3,
  ]
}
resource "aws_security_group" "service-security-group" {
  egress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = null
    from_port   = 0
    ipv6_cidr_blocks = [
      "::/0"
    ]
    prefix_list_ids = null
    protocol        = "-1"
    security_groups = null
    self            = null
    to_port         = 0
  }
  ingress {
    cidr_blocks      = null
    description      = null
    from_port        = var.service_port
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "TCP"
    security_groups  = tolist(aws_lb.alb_7A364839.security_groups)
    self             = null
    to_port          = var.service_port
  }
  vpc_id = var.vpc_id
}
resource "aws_cloudfront_distribution" "main_cdn_727A99AA" {
  enabled = true
  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]
    cached_methods = [
      "GET",
      "HEAD"
    ]
    target_origin_id       = "app"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }
  dynamic "logging_config" {
    for_each = var.is_cdn_logging_enabled ? [1] : []
    content {
      bucket = var.cdn_logging_bucket
    }
  }
  origin {
    domain_name = aws_lb.alb_7A364839.dns_name
    origin_id   = "app"
    custom_header {
      name  = "X-My-Header"
      value = "letMeIn"
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
