resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${var.env}-docdb"
  engine                  =  var.engine
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.user.value
  master_password         = data.aws_ssm_parameter.pass.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = true
  db_subnet_group_name = aws_docdb_subnet_group.main.name
  kms_key_id              = data.aws_kms_key.key.arn
  storage_encrypted       = var.storage_encrypted
  vpc_security_group_ids = [aws_security_group.main.id]

}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count                 = var.no_of_instances
  identifier            = "${var.env}-docdb-${count.index}"
  cluster_identifier    = aws_docdb_cluster.main.id
  instance_class        = var.instance_class
}


resource "aws_security_group" "main" {
  name        = "docdb-${var.env}"
  description = "docdb-${var.env}"
  vpc_id = var.vpc_id


  ingress {
    description      = "DOCDB"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.allow_subnets
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge (
    var.tags,
    { Name = "docdb-${var.env}" }
  )
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
  name  = "${var.env}.docdb.url.catalogue"
  type  = "String"
  value = "mongodb://${data.aws_ssm_parameter.user.value}:${data.aws_ssm_parameter.pass.value}@${aws_docdb_cluster.main.endpoint}:27017/catalogue?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

resource "aws_ssm_parameter" "docdb_url_user" {
  name  = "${var.env}.docdb.url.user"
  value = "mongodb://${data.aws_ssm_parameter.user.value}:${data.aws_ssm_parameter.pass.value}@${aws_docdb_cluster.main.endpoint}:27017/users?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
  type  = "String"
}

resource "aws_ssm_parameter" "docdb_endpoint" {
  name  = "${var.env}.docdb.endpoint"
  type  = "String"
  value = aws_docdb_cluster.main.endpoint
}