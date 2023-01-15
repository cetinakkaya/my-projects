variable "instance_name" {
  default = "Web Server of Phonebook App"
}

variable "ec2_ami" {
  default = "ami-09d3b3274b6c5d4aa"
}

variable "az" {
  default = "us-east-1"
}

variable "github_token" {
  default = "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"
}

variable "github_repo_name" {
  default = "phonebook-flask-app"
}

variable "github_repo_branch_name" {
  default = "main"
}