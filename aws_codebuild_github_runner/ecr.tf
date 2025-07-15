resource "aws_ecr_repository" "foo" {
  name                 = "codebuild-custom-image"
  image_tag_mutability = "MUTABLE"

}