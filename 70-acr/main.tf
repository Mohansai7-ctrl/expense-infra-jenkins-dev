resource "aws_ecr_repository" "backend" {
    name = "${var.project_name}/${var.environment}/backend"   # namespace/repository
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}


resource "aws_ecr_repository" "frontend" {
    name = "${var.project_name}/${var.environment}/frontend"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
        scan_on_push = true
    }
}

# As we are using RDS here, not creating and pushing image of mysql




