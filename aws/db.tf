# Security Group that only allows TCP 5432 from the internal VPC
resource "aws_security_group" "allow_postgres_home" {
  vpc_id      = data.aws_vpc.default.id
  name        = "allow-postgres-home"
  description = "postgres from home"
  ingress {
    from_port = 5432 # Postgres port
    to_port   = 5432
    protocol  = "tcp"
    # gives access to the whole VPC. Restrict this more, if possible.
    cidr_blocks = ["172.16.0.0/12"] # change this to your VPC's IPs
  }
}

# make the Postgres DB
resource "aws_db_instance" "sausage_rds" {
  identifier             = "sausage-rds"
  db_name                = "sausage"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "14.2"
  skip_final_snapshot    = true
  publicly_accessible    = false # you do not want public access
  vpc_security_group_ids = [aws_security_group.allow_postgres_home.id]
  username               = "psql" # admin username here
  password               = data.aws_ssm_parameter.sausage_rds_password.value
}


# load the secret password here INSTEAD OF writing passwords to source
# save the password to SSM with a command like this on
# aws ssm put-parameter --name "sausage.rds.password.prod" --type SecureString --value "PASSWORD_GOES_HERE" 
data "aws_ssm_parameter" "sausage_rds_password" {
  name = "sausage.rds.password.prod"
}
