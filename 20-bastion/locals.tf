locals {
    resource_name = "${var.project_name}-${var.environment}"
    ami = data.aws_ami.ami_info.id
    bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
    public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]  #If 2 zones are there then include [0] at the end of this line
}