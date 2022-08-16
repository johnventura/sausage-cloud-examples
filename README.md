# Introduction
This is a repository of example code for [Terraform](https://www.terraform.io/).
When rendered, it will create the following:

* An Autoscaler/”Auto Scaling Group” with a single instance
* A storage bucket
* A PostgreSQL server
* Various supporting resources, like IAM policies

This code is for AWS and GCP. The infrastructure it creates should be roughly equivalent between the two. Sorry, there are no Azure examples.

# Basic Terraform Commands

* `terraform fmt` Format Terraform code
* `terraform plan` View planned changes based on code 
* `terraform apply` Render cloud resources from code
* `terraform state list` Describe what resources are being tracked
* `terraform destroy` Destroy the infrastructure being tracked
