# ################################################################################
# # VPC Module
# ################################################################################

module "vpc" {
  source      = "./../modules/vpc"
  main_region = var.main_region
}

# ################################################################################
# # EKS Cluster Module
# ################################################################################

module "eks" {
  source = "./../modules/eks-cluster"

  cluster_name = var.cluster_name
  rolearn      = var.rolearn
  cni_role_arn = module.iam.cni_role_arn

  security_group_ids = [module.eks-client-node.eks_client_sg]
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets

  # Enables EKS to bootstrap and manage the core addons

  tags     = local.common_tags
  env_name = var.env_name
}



# ################################################################################
# # AWS ALB Controller
# ################################################################################

module "aws_alb_controller" {
  source = "./../modules/aws-alb-controller"

  main_region       = var.main_region
  cluster_name      = var.cluster_name
  vpc_id            = module.vpc.vpc_id
  account_id        = var.aws_account_id
  oidc_provider_arn = module.eks.oidc_provider_arn

  depends_on = [module.eks]
}


module "acm" {
  source          = "./../modules/acm"
  domain_name     = var.domain_name
  san_domains     = var.san_domains
  route53_zone_id = var.route53_zone_id
  tags            = local.common_tags
}


module "ecr" {
  source         = "./../modules/ecr"
  aws_account_id = var.aws_account_id
  repositories   = var.repositories
  tags           = local.common_tags
}

module "iam" {
  source            = "./../modules/iam"
  environment       = var.env_name
  aws_region        = var.aws_region
  aws_account_id    = var.aws_account_id
  eks_oidc_provider = local.eks_oidc_provider
  cluster_name      = var.cluster_name
  tags              = local.common_tags
}



##############################################
# EKS TOOLS
##############################################
# module "jenkins-server" {
#   source            = "./../modules/jenkins-server"
#   ami_id            = local.final_ami_id
#   instance_type     = var.instance_type
#   key_name          = var.key_name
#   main_region       = var.main_region
#   security_group_id = module.eks-client-node.eks_client_sg
#   subnet_id         = module.vpc.public_subnets[0]
# }


module "github-self-hosted-runner" {
  source            = "./../modules/github-self-hosted-runner"
  ami_id            = local.final_ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  main_region       = var.main_region
  security_group_id = module.eks-client-node.eks_client_sg
  subnet_id         = module.vpc.public_subnets[0]
  cluster_name      = module.eks.cluster_name
}

module "maven-sonarqube-server" {
  source            = "./../modules/maven-sonarqube-server"
  ami_id            = local.final_ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  security_group_id = module.eks-client-node.eks_client_sg
  subnet_id         = module.vpc.public_subnets[0]
  # main_region   = var.main_region

  #   db_name              = var.db_name
  #   db_username          = var.db_username
  #   db_password          = var.db_password
  #   db_subnet_group      = var.db_subnet_group
  #   db_security_group_id = var.db_security_group_id
}





# ################################################################################
# # Managed Grafana Module
# ################################################################################

# module "managed_grafana" {
#   source             = "./modules/grafana"
#   env_name           = var.env_name
#   main_region        = var.main_region
#   private_subnets    = module.vpc.private_subnets
#   sso_admin_group_id = var.sso_admin_group_id
# }



# # ################################################################################
# # # Managed Prometheus Module
# # ################################################################################

# module "prometheus" {
#   source            = "./modules/prometheus"
#   env_name          = var.env_name
#   main_region       = var.main_region
#   cluster_name      = var.cluster_name
#   oidc_provider_arn = module.eks.oidc_provider_arn
#   vpc_id            = module.vpc.vpc_id
#   private_subnets   = module.vpc.private_subnets
# }



# # ################################################################################
# # # VPC Endpoints for Prometheus and Grafana Module
# # ################################################################################

# module "vpcendpoints" {
#   source                    = "./modules/vpcendpoints"
#   env_name                  = var.env_name
#   main_region               = var.main_region
#   vpc_id                    = module.vpc.vpc_id
#   private_subnets           = module.vpc.private_subnets
#   grafana_security_group_id = module.managed_grafana.security_group_id
# }

