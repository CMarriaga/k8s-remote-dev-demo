resource "aws_db_subnet_group" "this" {
  name       = format("%s-subnet-group", var.common_name)
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-subnet-group", var.common_name),
      identifier = var.identifier,
    }
  )
}

resource "aws_db_instance" "this" {
  identifier        = format("%s-postgres", var.common_name)
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name             = var.rds_db_name
  username            = var.rds_username
  password_wo         = var.rds_managed_password ? null : var.rds_password
  password_wo_version = var.rds_managed_password ? null : var.rds_password_version
  port                = var.rds_port

  # TODO: Seems like both manage_master_user_password and password_ro cannot be supported at the time, find a way to do it
  # manage_master_user_password = var.rds_managed_password ? null : var.rds_managed_password
  delete_automated_backups = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false
  multi_az               = false
  deletion_protection    = false
  skip_final_snapshot    = true

  tags = merge(
    var.custom_tags,
    {
      Name       = format("%s-postgres", var.common_name),
      identifier = var.identifier,
    }
  )
}
