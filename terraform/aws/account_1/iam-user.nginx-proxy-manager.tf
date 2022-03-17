resource "aws_iam_user" "nginx-proxy-manager" {
  name = "nginx-proxy-manager"
}

resource "aws_iam_access_key" "nginx-proxy-manager" {
  user = aws_iam_user.nginx-proxy-manager.name
}

output "nginx-proxy-manager_access_key" {
  value = aws_iam_access_key.nginx-proxy-manager.id
}

output "nginx-proxy-manager_secret_key" {
  value = aws_iam_access_key.nginx-proxy-manager.secret
}

resource "aws_iam_policy" "nginx-proxy-manager-route53-nasreddine-com" {
  name        = "nginx-proxy-manager-route53-nasreddine-com"
  path        = "/"
  description = "Allow Nginx Proxy Manager to manage nasreddine.com in order to support Let's Encrypt via DNS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "route53:ListHostedZones",
          "route53:GetChange",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "route53:ChangeResourceRecordSets",
        ]
        Effect   = "Allow"
        Resource = aws_route53_zone.nasreddine-com.arn
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "nginx-proxy-manager-route53-nasreddine-com" {
  user       = aws_iam_user.nginx-proxy-manager.name
  policy_arn = aws_iam_policy.nginx-proxy-manager-route53-nasreddine-com.arn
}
