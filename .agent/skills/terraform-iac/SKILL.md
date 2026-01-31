---
name: Terraform & Infrastructure as Code
description: Expert patterns for Infrastructure as Code using Terraform, multi-cloud deployments, state management, and infrastructure testing
category: DevOps & Infrastructure
difficulty: Advanced
last_updated: 2026-01-16
---

# Terraform & Infrastructure as Code (IaC)

Expert patterns for managing infrastructure as code với Terraform and modern IaC practices.

---

## When to Use This Skill

- Infrastructure provisioning
- Multi-cloud deployments
- Infrastructure versioning
- Team collaboration on infrastructure
- Disaster recovery setup
- Environment replication

---

## Quick Reference

### Terraform Workflow

```
terraform init    # Initialize working directory
terraform plan    # Preview changes
terraform apply   # Apply changes
terraform destroy # Destroy infrastructure
```

---

### Basic Terraform Configuration

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Resources
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
  }
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
```

---

### Terraform Modules

```hcl
# modules/web-server/main.tf
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  user_data = file("${path.module}/user_data.sh")
  
  tags = {
    Name = var.server_name
  }
}

# modules/web-server/variables.tf
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "server_name" {
  type = string
}

# modules/web-server/outputs.tf
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
```

```hcl
# main.tf (using module)
module "web_server" {
  source = "./modules/web-server"
  
  ami_id        = "ami-12345678"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public[0].id
  server_name   = "production-web"
}

output "web_server_ip" {
  value = module.web_server.public_ip
}
```

---

### Multi-Cloud Example

```hcl
# AWS + Google Cloud
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "google" {
  project = "my-project"
  region  = "us-central1"
}

# AWS resources
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

# GCP resources
resource "google_storage_bucket" "backup" {
  name     = "my-backup-bucket"
  location = "US"
}
```

---

### State Management

```hcl
# Remote state (S3 backend)
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# State locking with DynamoDB
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

---

### Workspaces (Multi-Environment)

```bash
# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select prod

# List workspaces
terraform workspaceist
```

```hcl
# Use workspace in config
resource "aws_instance" "app" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
  
  tags = {
    Environment = terraform.workspace
  }
}
```

---

### Testing Infrastructure

```hcl
# Using Terratest (Go)
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformWebServer(t *testing.T) {
    opts := &terraform.Options{
        TerraformDir: "../modules/web-server",
        Vars: map[string]interface{}{
            "ami_id":     "ami-12345678",
            "subnet_id":  "subnet-123",
            "server_name": "test-server",
        },
    }
    
    defer terraform.Destroy(t, opts)
    terraform.InitAndApply(t, opts)
    
    instanceID := terraform.Output(t, opts, "instance_id")
    // Assert instance exists
}
```

---

### Import Existing Resources

```bash
# Import existing AWS instance
terraform import aws_instance.web i-1234567890abcdef0

# Import into module
terraform import module.web_server.aws_instance.web i-1234567890abcdef0
```

---

## Best Practices

✅ **Use remote state** - Team collaboration, state locking  
✅ **Module everything** - Reusable, testable components  
✅ **Version providers** - Avoid breaking changes  
✅ **Separate environments** - Workspaces or separate configs  
✅ **Use variables** - No hardcoded values  
✅ **Tag all resources** - Resource management  
✅ **Plan before apply** - Review changes

---

## Anti-Patterns

❌ **Manual changes** → State drift  
❌ **No state locking** → Concurrent modification  
❌ **Hardcoded values** → Not reusable  
❌ **No modules** → Duplicate code  
❌ **Local state only** → No collaboration  
❌ **No versioning** → Breaking changes

---

## Related Skills

- `kubernetes-patterns` - K8s infrastructure
- `monitoring-observability` - Infrastructure monitoring
- `deployment-procedures` - Deployment automation

---

## Official Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [Terratest](https://terratest.gruntwork.io/)
