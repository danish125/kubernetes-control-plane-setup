aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 339713106964.dkr.ecr.eu-west-2.amazonaws.com
docker buildx build --platform linux/amd64 -t terraform-image . --load
docker tag terraform-image:latest 339713106964.dkr.ecr.eu-west-2.amazonaws.com/codebuild-custom-image:latest
docker push 339713106964.dkr.ecr.eu-west-2.amazonaws.com/codebuild-custom-image:latest