resource aws_iam_policy policy {
	name        = "dms-full-access-test-bucket"
	path        = "/"
	description = "Policy gives full access to the bucket used for testing AWS DMS"

	policy = jsonencode({
		"Version": "2012-10-17",
		"Statement": [
			{
				"Sid": "VisualEditor0",
				"Effect": "Allow",
				"Action": "s3:*",
				"Resource": ["arn:aws:s3:::${var.target_bucket_name}", "arn:aws:s3:::${var.target_bucket_name}/*"]
			}
		]
	})
}

resource aws_iam_role role {
	name = "dms_role"

	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
		{
			Action = "sts:AssumeRole"
			Effect = "Allow"
			Sid    = ""
			Principal = {
			Service = "dms.amazonaws.com"
			}
		},
		]
	})
	permissions_boundary = var.permissions_boundary
}

resource aws_iam_policy_attachment attach {
  name       = "dms-role-attach-s3-policy"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

# to-do
# arn:aws:iam::831354200784:role/dms-cloudwatch-logs-role
# https://aws.amazon.com/premiumsupport/knowledge-center/dms-cloudwatch-logs-not-appearing/

data aws_iam_policy_document dms_assume_role {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource aws_iam_role dms-cloudwatch-logs-role {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
  permissions_boundary = var.permissions_boundary
}

resource aws_iam_role_policy_attachment dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}