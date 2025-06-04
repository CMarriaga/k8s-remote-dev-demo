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

  db_name = "demo"
  port    = 5432

  manage_master_user_password = true
  username                    = "demo"
  delete_automated_backups    = true

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
