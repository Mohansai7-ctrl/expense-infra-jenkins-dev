# this is eks cluster and blue-green nodes creation/setup, 
# first create vpc, sg, bastion and then eks.

# once cluster is done and nodes are created, now connect via bastion public ip, do aws configure and do aws eks update-kubeconfig

# then clone expense-k8, apply mysql,backend and frontend manifest files so that website will be run inside blue green nodes.



#to connect by terraform to aws to create the eks cluster and manged group nodes by eks, it needs key pair authentication:

resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = file("~/.ssh/eks.pub")
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3pqvQPbcZR7JEYdlRXQ69FNULyCD73rpdShVdeh9VX HP@LAPTOP-I097EHJB"
  # ~ means windows home directory
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  
  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.31"    #we can use 1.31 to upgrade the cluster using blue-green deployemnt

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids   #for managed node groups
  control_plane_subnet_ids = local.private_subnet_ids   #for control plane, we can create control plane and managed nodes in different subnets across the avialability_zones for the isolation, security, network ACL's

  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id = local.node_sg_id


    
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {

    # blue = {
    #   min_size      = 2
    #   max_size      = 10
    #   desired_size  = 2
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }

    green = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }

  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = var.common_tags
}