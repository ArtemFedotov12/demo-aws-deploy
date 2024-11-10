variable "cluster_name" {
  description = "Имя кластера EKS"
  type        = string
}

resource "aws_codebuild_project" "deploy_project" {
  name          = "myapp-deploy"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }

    environment_variable {
      name  = "KUBECONFIG"
      value = "/root/.kube/config"
    }
  }

  source {
    type      = "S3"
    location  = "build_output"
    buildspec = "buildspec-deploy.yml"
  }
}
