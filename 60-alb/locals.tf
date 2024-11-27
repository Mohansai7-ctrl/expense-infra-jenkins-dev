locals {
    #ingress_alb_sg_id = data.aws_ssm_parameter.ingress_alb_sg_id.value
    public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    resource_name = "${var.project_name}-${var.environment}"
    https_certificate_arn = data.aws_ssm_parameter.https_certificate_arn.value
}