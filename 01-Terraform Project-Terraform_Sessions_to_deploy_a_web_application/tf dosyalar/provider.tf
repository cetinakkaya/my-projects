terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.38.0"
    }
    github = {
      source = "integrations/github"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.az
}

provider "github" {
  token = "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"
}

