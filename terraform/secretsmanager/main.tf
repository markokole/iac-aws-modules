resource aws_secretsmanager_secret secret {
  name = var.secret_id
}

resource aws_secretsmanager_secret_version credentials {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_string
}