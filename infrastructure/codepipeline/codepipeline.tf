variable "codebuild_project_name" {
  description = "Название CodeBuild проекта для использования в CodePipeline"
  type        = string
}

variable "github_token" {
  description = "GitHub token for CodePipeline"
  type        = string
  sensitive   = true
}


# Добавляем data для получения ID текущего аккаунта
data "aws_caller_identity" "current" {}

# Создание S3 бакета для артефактов CodePipeline
resource "aws_s3_bucket" "artifact_store" {
  bucket = "myapp-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

# Создание IAM роли для CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# Политика доступа для CodePipeline
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${aws_s3_bucket.artifact_store.arn}",
          "${aws_s3_bucket.artifact_store.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects"
        ]
        Resource = "*"
      }
    ]
  })
}

# Конфигурация CodePipeline
resource "aws_codepipeline" "app_pipeline" {
  name     = "demo-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  # Этап Source для подключения к GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "ArtemFedotov12"      # Ваш GitHub username
        Repo       = "demo-aws-deploy"     # Название вашего репозитория
        Branch     = "main"                # Ветка, которую нужно отслеживать
        OAuthToken = var.github_token      # GitHub OAuth токен
      }
    }
  }

  # Этап Build для сборки Docker-образа и загрузки в ECR
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name  # Использование переменной вместо отсутствующего ресурса
      }
    }
  }

  # (Опционально) Этап Deploy для деплоя в EKS
  # Добавьте, если необходимо автоматически деплоить приложение в EKS
  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"  # Или используйте EKS, если требуется
      version          = "1"
      input_artifacts  = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.deploy_project.name
/*        ClusterName = "your-cluster-name"
        ServiceName = "your-service-name"
        FileName    = "imagedefinitions.json"*/
      }
    }
  }
}
