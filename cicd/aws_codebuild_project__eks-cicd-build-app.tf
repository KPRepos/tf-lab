# File generated by aws2tf see https://github.com/aws-samples/aws2tf
# aws_codebuild_project.eks-cicd-build-app:
resource "aws_codebuild_project" "eks-cicd-build-app" {
  badge_enabled  = false
  build_timeout  = 60
  encryption_key = data.aws_kms_alias.s3.arn
  name           = "eks-cicd-build-app"
  queued_timeout = 480
  depends_on     = [aws_iam_role.codebuild-eks-cicd-build-app-service-role]
  service_role   = aws_iam_role.codebuild-eks-cicd-build-app-service-role.arn
  source_version = "refs/heads/master"
  tags           = {}

  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }

  cache {
    modes = []
    type  = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0" 
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.flask-web-app.name}"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    
    environment_variable {
      name  = "db_host_ip"
      value = "${data.terraform_remote_state.infra.outputs.mongo_host_ip}"
    }
    
    environment_variable {
      name  = "eks_alb_sg"
      value = "${data.terraform_remote_state.infra.outputs.eks_alb_sg}"
    }
   
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = aws_codecommit_repository.eksworkshop-app.clone_url_http
    report_build_status = false
    type                = "CODECOMMIT"

    git_submodules_config {
      fetch_submodules = false
    }
  }

  vpc_config {
    security_group_ids = [
      # data.aws_security_group.cicd.id,
      aws_security_group.eks-cicd-sg.id,
    ]
    subnets = [
      # data.aws_subnet.cicd.id,
      "${data.terraform_remote_state.infra.outputs.private_subnets [0]}",
    ]
    # vpc_id = data.aws_vpc.cicd.id
    vpc_id = "${data.terraform_remote_state.infra.outputs.vpc_id}"
  }
}


resource "aws_codebuild_project" "eks-cicd-delete-apps" {
  badge_enabled  = false
  build_timeout  = 60
  encryption_key = data.aws_kms_alias.s3.arn
  name           = "eks-cicd-delete-apps"
  queued_timeout = 480
  depends_on     = [aws_iam_role.codebuild-eks-cicd-build-app-service-role]
  service_role   = aws_iam_role.codebuild-eks-cicd-build-app-service-role.arn
  source_version = "refs/heads/master"
  tags           = {}

  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }

  cache {
    modes = []
    type  = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    buildspec = "buildspec-delete.yml"
    location            = aws_codecommit_repository.eksworkshop-app.clone_url_http
    report_build_status = false
    type                = "CODECOMMIT"

    git_submodules_config {
      fetch_submodules = false
    }
  }

  vpc_config {
    security_group_ids = [
      # data.aws_security_group.cicd.id,
      aws_security_group.eks-cicd-sg.id,
    ]
    subnets = [
      # data.aws_subnet.cicd.id,
      "${data.terraform_remote_state.infra.outputs.private_subnets [0]}",
    ]
    # vpc_id = data.aws_vpc.cicd.id
    vpc_id = "${data.terraform_remote_state.infra.outputs.vpc_id}"
  }
}
