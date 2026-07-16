variable "region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance. Defaults to the latest Amazon Linux 2 AMI."
  type        = string
  default     = ""
}

variable "name" {
  description = "Name tag applied to the instance."
  type        = string
  default     = "example-instance"
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
