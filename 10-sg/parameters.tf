resource "aws_ssm_parameter" "mysql_sg_id" {
    name = "/${var.project_name}/${var.environment}/mysql_sg_id"
    value = module.mysql_sg.id
    type = "String"
}


resource "aws_ssm_parameter" "bastion_sg_id" {
    name = "/${var.project_name}/${var.environment}/bastion_sg_id"
    value = module.bastion_sg.id
    type = "String"
}

resource "aws_ssm_parameter" "ingress_alb_sg_id" {
    name = "/${var.project_name}/${var.environment}/ingress_alb_sg_id"
    value = module.ingress_alb_sg.id
    type = "String"
}

resource "aws_ssm_parameter" "eks_control_plane_sg_id" {
    name = "/${var.project_name}/${var.environment}/eks_control_plane_sg_id"
    value = module.eks_control_plane_sg.id
    type = "String"
}

resource "aws_ssm_parameter" "node_sg_id" {
    name = "/${var.project_name}/${var.environment}/node_sg_id"
    value = module.node_sg.id
    type = "String"
}
