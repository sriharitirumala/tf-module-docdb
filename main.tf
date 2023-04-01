resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${var.env}-docdb"
  engine                  =  var.engine
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.user.value
  master_password         = data.aws_ssm_parameter.pass.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = true
  kms_key_id              = data.aws_kms_key.key.arn
  storage_encrypted       = var.storage_encrypted

}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count                 = var.no_of_instances
  identifier            = "${var.env}-docdb-${count.index}"
  cluster_identifier    = aws_docdb_cluster.main.id
  instance_class        = var.instance_class
}


resource "aws_docdb_subnet_group" "main" {
  name = "${var.env}-docdb"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    { Name = "${var.env}-subnet-group" }
  )
}


resource "aws_ssm_parameter" "docdb_url_catalogue" {
  name  = "${var.env}.docdb.catalogue"
  type  = "string"
  value = "mongodb://${data.aws_ssm_parameter.user.value}:${data.aws_ssm_parameter.pass.value}@dev-docdb.cluster-cbvsbeoyxek4.us-east-1.docdb.amazonaws.com:27017/catalogue?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

resource "aws_ssm_parameter" "docdb_url_user" {
  name  = "${var.env}.docdb.catalogue"
  type  = "string"
  value = "mongodb://${data.aws_ssm_parameter.user.value}:${data.aws_ssm_parameter.pass.value}@dev-docdb.cluster-cbvsbeoyxek4.us-east-1.docdb.amazonaws.com:27017/users?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}


resource "aws_ssm_parameter" "docdb_endpoint" {
  name  = "${var.env}.docdb.endpoint"
  type  = "string"
  value = aws_docdb_cluster.main.endpoint
}

resource "aws_ssm_parameter" "docdb_user" {
  name  = "${var.env}.docdb.user"
  type  = "string"
  value = data.aws_ssm_parameter.user.value
}

resource "aws_ssm_parameter" "docdb_pass" {
  name  = "${var.env}.docdb.pass"
  type  = "string"
  value = data.aws_ssm_parameter.pass.value
}
