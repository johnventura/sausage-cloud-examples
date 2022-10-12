# define your local variables here
# change the project/zone/region as needed
locals {
  project = "staging-999999999"
  network = "default"
  subnet  = "default"
  zone    = "us-central1-a"
  region  = "us-central1"
  # your EC2's cloud-init data is here
  cloudinit_configure = <<EOT
#cloud-config
write_files:
  - path: /etc/description
    permissions: 0644
    content: |
      This file exists to demonstrate cloud-init.

bootcmd:
  - /bin/touch /etc/created_at_boot

runcmd:
  - /bin/touch /etc/created_after_boot

EOT
}

