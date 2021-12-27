resource aws_iam_policy policy {
    
    name        = var.policy_name
    path        = "/"
    description = var.policy_description

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": var.policy_action,
                "Resource": var.policy_resource
            }
        ]
    })
}

resource aws_iam_user_policy_attachment attach {
    user       = var.user
    policy_arn = aws_iam_policy.policy.arn
}

resource aws_iam_role role {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "${var.principal_service}.amazonaws.com"
        }
      },
    ]
  })
}

# resource aws_iam_policy_attachment attach {
#   name       = "dms-role-attach-s3-policy"
#   roles      = [aws_iam_role.role.name]
#   policy_arn = aws_iam_policy.policy.arn
# }