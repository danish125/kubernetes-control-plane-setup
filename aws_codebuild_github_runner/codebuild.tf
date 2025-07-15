resource "aws_codebuild_project" "github_runner" {
  name          = "runner"
  description   = "CodeBuild project acting as GitHub Actions self-hosted runner"
  service_role  = aws_iam_role.codebuild_role.arn

  source {
    type            = "GITHUB"
    location        = var.repository_location
    git_clone_depth = 1
    auth {
        type = "CODECONNECTIONS"
        resource = var.connector_arn
    }
  }
#   secondary_sources {
#     type = "GITHUB"
#     source_identifier = "demo"
#     location = var.repository_location

#     auth {
#         type = "CODECONNECTIONS"
#         resource = "arn:aws:codeconnections:eu-west-2:339713106964:connection/5cc1a0c0-9374-4a9b-a838-0a6ed31d5bac"
#     }
#   }
  environment {
    # compute_type                = "BUILD_GENERAL1_MEDIUM"
    # image                       = "aws/codebuild/standard:5.0"
    # type                        = "LINUX_CONTAINER"
    # privileged_mode             = false
    

    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "339713106964.dkr.ecr.eu-west-2.amazonaws.com/codebuild-custom-image:latest"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "TFC_AGENT_TOKEN"
      type = "SECRETS_MANAGER"
      value = "arn:aws:secretsmanager:eu-west-2:339713106964:secret:tf-agent-token-mtGd8K:TFC_AGENT_TOKEN::"
    }
    environment_variable {
      name  = "TFC_AGENT_NAME"
      value = "agent"
    #   type  = "PARAMETER_STORE"

    }


    # environment_variables = [
    #   {
    #     name  = "TFC_AGENT_TOKEN"
    #     value = "<your-github-token>"
    #     type  = ""
    #   },
    #   {
    #     name  = "TFC_AGENT_NAME"
    #     value = "agent"
    #   }
    # ]
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
#   vpc_config {
#     vpc_id = data.aws_vpc.selected.id

#     subnets = var.subnet_ids

#     security_group_ids = [
#       aws_security_group.allow_tls.id
#     ]
#   }
  tags = {
    Environment = "Dev"
  }
}
