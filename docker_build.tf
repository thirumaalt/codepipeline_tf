# Docker Build & Push using null_resource
resource "null_resource" "docker_build_push" {
  depends_on = [aws_ecr_repository.facebook_repo]

  provisioner "local-exec" {
    command = <<EOT
      # Authenticate with ECR
      aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.facebook_repo.repository_url}

      # Build and Tag Docker Image
      docker build -t ${aws_ecr_repository.facebook_repo.repository_url}:latest .

      # Push Image to ECR
      docker push ${aws_ecr_repository.facebook_repo.repository_url}:latest
    EOT
  }

  triggers = {
    dockerfile_sha = filebase64sha256("Dockerfile") # Triggers build only if Dockerfile changes
  }
}
