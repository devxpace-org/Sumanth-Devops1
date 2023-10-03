resource "aws_instance" "suman" {
  ami                    = var.ami[var.region]
  instance_type          = "t2.micro"
  availability_zone      = var.zone
  key_name               = "jenkinskey"
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  tags                   = { Name = "sumanth" }
 
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = "us-east-1a" # Replace with your desired availability zone
  size             = 1           # Replace with your desired volume size (in GiB)
}

resource "aws_volume_attachment" "volume_attachment" {
  device_name = "/dev/sdf"                          # Replace with your desired device name
  instance_id = aws_instance.suman.id              # Reference the instance resource ID
  volume_id   = aws_ebs_volume.ebs_volume.id    # Reference the EBS volume resource ID
}

variable "security_group_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_security_group" "example_sg" {
  name        = "mysg"
  tags ={
    name="sumanthsg"
  }
  description = "Example security group for EC2 instance"

  dynamic "ingress" {
    for_each = var.security_group_rules

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-policy"
  description = "Allows read access to a specific S3 object"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::sumanth994/sumanthfile",
      },
    ],
  })
}

resource "aws_iam_role" "example_role" {
  name = "SumanthRole1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the IAM policy to the role
resource "aws_iam_policy_attachment" "example_policy_attachment" {
  name       = "sumanth_policy_attachment"
  policy_arn = aws_iam_policy.s3_read_policy.arn
  roles      = [aws_iam_role.example_role.name]
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile1"
  role = aws_iam_role.example_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


output "publicip" {
  value = aws_instance.suman.public_ip
}

output "privateip" {
  value = aws_instance.suman.private_ip
}
