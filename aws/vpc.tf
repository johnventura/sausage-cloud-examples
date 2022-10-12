# define the VPC here.
# You can make a new VPC here, but this is a "data" block
# it is intended to allow you to use the VPC that came with the account
data "aws_vpc" "default" {
  default = true
}
