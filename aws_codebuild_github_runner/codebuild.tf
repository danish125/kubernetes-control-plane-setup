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
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    # environment_variables = [
    #   {
    #     name  = "GITHUB_TOKEN"
    #     value = "<your-github-token>"
    #     type  = "PLAINTEXT"
    #   }
    # ]
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  tags = {
    Environment = "Dev"
  }
}
