provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_instance" "ec2-instance" {
  ami = "ami-0574da719dca65348"
  instance_type  = "t2.micro"
  key_name = "alura_key"

tags = {
  name = "Teste AWS"
}
}


resource "aws_security_group" "security-group-for-builders" {
    name = "habilitar-acesso-remoto"
    description = "Habilitar o acesso remoto "
    vpc_id = "vpc-00cbad41c1b2cd6f0 "

    ingress {
        description = "Allow inbound ssh traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "habilitar_ssh"
    }
}
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


resource "aws_s3_bucket" "builder" {
        bucket = "builders-challenge"
        acl = "private"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encriptacao" {
  bucket = aws_s3_bucket.builder.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}





