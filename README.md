# Builder-Challenge Junior DevSecOps Challenge Attempt

## **Objetivo**:

O objetivo deste desafio técnico é avaliar o nível de conhecimento do candidato em nuvem e segurança da informação.

## **Desafio**:

Primeiramente, você pode selecionar uma das seguintes tecnologias para usar, de maneira que se sinta mais confortável para desenvolver seu desafio:

- AWS
- GCP

Para a tecnologia que você selecionar, você deve criar um IAC que irá realizar a criação de uma máquina virtual (VM ou EC2) e um bucket.

Nesta máquina criada, você deve criar uma aplicação (na linguagem que você se sentir confortável) que irá ser executado a cada hora, e irá criar um arquivo de texto contendo a hora de criação como conteúdo, e realizar o upload deste arquivo criado para o bucket.


## **Resolução**

Para a resolução do desafio foi provisionado uma máquina com recursos básicos.

<h4> provider "aws" { <\n>
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
</h4>

Feito uma regra para habilitar o acesso via SSH na VPC que estava atrelada a Máquina virtual


resource "aws_security_group" "security-group-for-builders" {
    name = "habilitar-acesso-remoto"
    description = "Habilitar o acesso remoto "
    vpc_id = "vpc-00cbad41c1b2cd6f0 "
    ingress {
        description = "Allow inbound traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        name = "habilitar_ssh"
    }
}

	
 A Chave KMS foi criada para criptografar os objetos do bucket
  
  <h4> 
    resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}
  </h4>
  
  Após criar a chave criei o bucket
  
  <h4>
    
 
resource "aws_s3_bucket" "builder" {
        bucket = "builders-challenge"
        acl = "private"

        lifecycle_rule {
	id = "archive"
	enabled = true
	transition {
	days = 30
	storage_class = "Standard_IA"
}
	transition {
	days = 30
	storage_class = "STANDARD_IA"
	}
	
}
	versioning {
	enabled = true
	}
	tags = {
	  Enviroment: "QA"
	}

}
  </h4>
  
Para finalizar o provisionamento a máquina foi implementado a criptografia para proteger os objetos do bucket, utilizando a chave KMS criada anteriormente.

resource "aws_s3_bucket_server_side_encryption_configuration" "encriptacao" {
  bucket = aws_s3_bucket.builder.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
  
  

  
 
