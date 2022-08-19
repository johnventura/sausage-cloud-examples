# define who can assume the role. here, it's any EC2 in the account
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# API calls the role is allowed to execute 
resource "aws_iam_policy" "tracker_instance_policy" {
  name = "tracker-instance-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # difficult to restrict the resource here
      {
        Action   = ["s3:ListAllMyBuckets"]
        Effect   = "Allow"
        Resource = "*" # has to be a wildcard
      },
      # we are only allowed to read/write/list to one bucket
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::sausage-bucket"
      },
      # only allowed to access files sausage*.csv files to bucket's root directory 
      {
        Action   = ["s3:PutObject", "s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::sausage-bucket/sausage*.csv"
      },
      # only access sausage related secrets 
      {
        Action   = ["ssm:GetParameter"]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:*:*:parameter/sausage-*"
      },
      # only needed if we are using KMS
      #{
      #  Action   = ["kms:Decrypt", "kms:Encrypt"]
      #  Effect   = "Allow"
      #  Resource = aws_kms_key.sausage_key.arn
      #},
    ]
  })
}

# attach both parts of the policy and make the role
resource "aws_iam_role" "tracker_instance_role" {
  name                = "tracker-instance-role"
  path                = "/system/"
  assume_role_policy  = data.aws_iam_policy_document.instance-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.tracker_instance_policy.arn]
}

# create the role
resource "aws_iam_instance_profile" "tracker_instance_profile" {
  name = "sausage-tracker"
  role = aws_iam_role.tracker_instance_role.name
}
