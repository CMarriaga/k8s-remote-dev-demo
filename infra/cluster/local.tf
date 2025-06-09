locals {
  identifier   = random_id.this.id
  cluster_name = var.common_name

  rds_password = var.rds_password # Later add possibility to pull from secrets-manager
  # postgresql://demo:demo@db:5432/demo
  app_auth_db_url = format("postgresql://%s:%s@%s:%s/%s", var.rds_username, local.rds_password, module.data.rds_db_url, var.rds_port, var.rds_db_name)
}
