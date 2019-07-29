###############################
##   AWS  Connection config ##
##############################

provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/var/jenkins_home/workspace/Test-Job/terraform-test/credentials"
  profile                 = "default"
}

