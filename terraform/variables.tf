variable "environment" {
  type        = string
  default     = "development"
  description = "Environment for the project (development, staging, or production)"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region where resources will be created"
}

variable "project_name" {
  type        = string
  default     = "s3-cloudfront"
  description = "The name of the project"
}

variable "bucket_name" {
  type        = string
  default     = "frontend-assets"
  description = "The name of the S3 bucket to store the frontend code"
}

variable "suffix" {
  type        = string
  default     = "8864"
  description = "First 4 digits of the AWS account ID"
}
