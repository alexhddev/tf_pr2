resource "aws_iam_policy" "messages_bucket_access_lambda_policy" {
  name        = "TestS3BucketAccess"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.messages_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.messages_bucket.id}"
          ]
      },
    ]
  })
}