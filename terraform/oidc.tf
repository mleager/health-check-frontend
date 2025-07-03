data "aws_caller_identity" "current" {}

locals {
  account_id        = data.aws_caller_identity.current.account_id
  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

# Terraform Apply on Main Brach
data "aws_iam_policy_document" "assume_github_oidc_apply" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:mleager/${var.project_name}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_oidc_role_apply" {
  name               = "oidc-${var.environment}-${var.project_name}-apply"
  assume_role_policy = data.aws_iam_policy_document.assume_github_oidc_apply.json
  description        = "Allows GH Actions from ${var.project_name} to deploy frontend assets to S3 + CloudFront"
}

# Terraform Plan and Destroy on any Branch
data "aws_iam_policy_document" "assume_github_oidc_plan" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:mleager/${var.project_name}:*"]
    }
  }
}

resource "aws_iam_role" "github_oidc_role_plan" {
  name               = "oidc-${var.environment}-${var.project_name}-plan"
  assume_role_policy = data.aws_iam_policy_document.assume_github_oidc_plan.json
  description        = "Allows GH Actions from ${var.project_name} to plan and destroy frontend assets"
}

data "aws_iam_policy_document" "oidc_permissions" {
  statement {
    sid    = "AllowUploadAndGetForS3"
    effect = "Allow"
    actions = [
      "s3:*"
      # "s3:GetObject",
      # "s3:PutObject",
      # "s3:ListBucket",
      # "s3:GetBucketLocation",
      # "s3:ListBucketVersions",
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket.bucket}",
      "arn:aws:s3:::${local.s3_bucket.bucket}/*"
    ]
  }

  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"
    actions = [
      "cloudfront:*"
      # "cloudfront:AssociateAlias",
      # "cloudfront:CreateCloudFrontOriginAccessIdentity",
      # "cloudfront:CreateDistribution",
      # "cloudfront:CreateInvalidation",
      # "cloudfront:DeleteCloudFrontOriginAccessIdentity",
      # "cloudfront:DeleteDistribution",
      # "cloudfront:GetDistribution",
      # "cloudfront:TagResource",
      # "cloudfront:UntagResource",
      # "cloudfront:UpdateDistribution",
    ]
    resources = ["arn:aws:cloudfront::${local.account_id}:distribution/*"]
  }

  statement {
    sid    = "AllowACMCertPermissions"
    effect = "Allow"
    actions = [
      "acm:*"
      # "acm:RequestCertificate",
      # "acm:RevokeCertificate",
      # "acm:DeleteCertificate",
      # "acm:DescribeCertificate",
      # "acm:GetCertificate",
      # "acm:ListCertificates",
      # "acm:UpdateCertificate",
      # "acm:UpdateCertificateOptions",
      # "acm:DescribeCertificateOptions",
      # "acm:AddTagsToCertificate",
      # "acm:ListTagsForCertificate",
      # "acm:RemoveTagsFromCertificate"
    ]
    resources = ["arn:aws:acm:${var.region}:${local.account_id}:certificate/*"]
  }

  statement {
    sid    = "AllowRoute53Permissions"
    effect = "Allow"
    actions = [
      "route53:*"
      # "route53:GetHostedZone",
      # "route53:ListHostedZones",
      # "route53:ChangeResourceRecordSets",
      # "route53:ListResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.primary.zone_id}"]
  }
}

resource "aws_iam_policy" "github_oidc_role_policy" {
  name   = "github-oidc-permissions-policy-${var.project_name}"
  policy = data.aws_iam_policy_document.oidc_permissions.json
}

resource "aws_iam_role_policy_attachment" "attach_github_oidc_role_policy_apply" {
  role       = aws_iam_role.github_oidc_role_apply.id
  policy_arn = aws_iam_policy.github_oidc_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_github_oidc_role_policy_plan" {
  role       = aws_iam_role.github_oidc_role_plan.id
  policy_arn = aws_iam_policy.github_oidc_role_policy.arn
}

