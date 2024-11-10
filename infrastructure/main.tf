provider "aws" {
  region = var.region
}

module "ecr" {
  source = "./ecr"
}
module "eks" {
  source = "./eks"
}
# Подключение модуля CodeBuild и передача ему URL репозитория из модуля ECR
module "codebuild" {
  source         = "./codebuild"
  repository_url = module.ecr.repository_url
  region = var.region
}

# Подключение модуля CodePipeline и передача ему имени CodeBuild проекта
module "codepipeline" {
  source                = "./codepipeline"
  codebuild_project_name = module.codebuild.codebuild_project_name
  github_token           = var.github_token
}
module "codebuild_deploy" {
  source       = "./codebuild-deploy"
  cluster_name = module.eks.cluster_name  # Передаем имя кластера
}