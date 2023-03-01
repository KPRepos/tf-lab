

resource "aws_iam_role" "bastion-ec2-role" {
    name = "bastion-ec2-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "bastion_iam_role_policy" {
  name = "bastion_iam_role_policy"
  role = "${aws_iam_role.bastion-ec2-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.public_s3_lab_mongo.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.public_s3_lab_mongo.arn}/*"]
    },
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": ["${aws_secretsmanager_secret.mongoadminUserpassword.arn}"]
    },
    {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "bastion-ec2-role" {
    name = "bastion-ec2-role"
    role = "${aws_iam_role.bastion-ec2-role.name}"
}

resource "aws_iam_role_policy_attachment" "ssm-policy-bastion" {
role       = "${aws_iam_role.bastion-ec2-role.name}"
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}




resource "aws_iam_role" "mongo-ec2-role" {
    name = "mongo-ec2-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "mongo_iam_role_policy" {
  name = "mongo_iam_role_policy"
  role = "${aws_iam_role.mongo-ec2-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": ["${aws_secretsmanager_secret.mongoadminUserpassword.arn}"]
    },
        {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "mongo-ec2-role" {
    name = "mongo-ec2-role"
    role = "${aws_iam_role.mongo-ec2-role.name}"
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
role       = "${aws_iam_role.mongo-ec2-role.name}"
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}