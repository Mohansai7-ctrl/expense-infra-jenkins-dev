#Root module is terraform-aws-security-group

module "mysql_sg" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    vpc_id = local.vpc_id
    common_tags = var.common_tags
    #sg_tags = var.mysql_sg_tags
}




#creating bastion server security group, bastion server is for internal/organization employees/users to connect to servers via bastion via organization network instead of public network:
module "bastion_sg" {
    source = "git::https://github.com/Mohansai7-ctrl/terraform-aws-security-group.git?ref=main"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "bastion"
    sg_tags = var.bastion_sg_tags
}

#creating sg fro ingress_alb:
module "ingress_alb_sg" {
    source = "git::https://github.com/Mohansai7-ctrl/terraform-aws-security-group.git?ref=main"
    vpc_id = local.vpc_id
    sg_name = "ingress-alb"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
}

module "eks_control_plane_sg" {
    source = "git::https://github.com/Mohansai7-ctrl/terraform-aws-security-group.git?ref=main"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "eks-control-plane"
}

module "node_sg" {
    source = "git::https://github.com/Mohansai7-ctrl/terraform-aws-security-group.git?ref=main"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "node"
}


#Here to troubleshoot any issues, organization employees can connect via bastion to access servers, here the actual cidr block should be organization IP.
resource "aws_security_group_rule" "bastion_public" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  #As source here is Public, we need to use cidr block instead of security group
    security_group_id = module.bastion_sg.id
}

resource "aws_security_group_rule" "eks_control_plane_bastion" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.eks_control_plane_sg.id
}


resource "aws_security_group_rule" "node_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.node_sg.id
}

resource "aws_security_group_rule" "ingress_alb_https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.ingress_alb_sg.id

}

#for node-node communication, as nodes will gets deleted and created it uses local communication, means used vpc cidr block:
resource "aws_security_group_rule" "node_vpc" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
    security_group_id = module.node_sg.id
}


resource "aws_security_group_rule" "node_ingress_alb" {
    type = "ingress"
    from_port = 30000   #it opens the worker node that is range 30000-32767
    to_port = 32767
    protocol = "tcp"
    source_security_group_id = module.ingress_alb_sg.id
    security_group_id = module.node_sg.id

}


resource "aws_security_group_rule" "eks_control_plane_node" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = module.node_sg.id
    security_group_id = module.eks_control_plane_sg.id
}

resource "aws_security_group_rule" "node_eks_control_plane" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = module.eks_control_plane_sg.id
    security_group_id = module.node_sg.id
}

# Here as we are using RDS instead of Mysql, we need to open the port 3306 instead of opening server port 22

resource "aws_security_group_rule" "mysql_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.id
    security_group_id = module.mysql_sg.id
}



