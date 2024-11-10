variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
variable "github_token" {
  description = "GitHub token for CodePipeline"
  type        = string
  sensitive   = true
}
