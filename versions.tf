terraform {
  required_version = ">= 1.9.5"

  required_providers {
    aws = {
      version = "5.84.0"
      source  = "aws"
    }
    docker = {
      version = "3.0.2"
      source  = "kreuzwerker/docker"
    }
  }
}
