# Builder-Challenge Junior DevSecOps Challenge Attempt

## **Objetivo**:

O objetivo deste desafio técnico é avaliar o nível de conhecimento do candidato em nuvem e segurança da informação.

## **Desafio**:

Primeiramente, você pode selecionar uma das seguintes tecnologias para usar, de maneira que se sinta mais confortável para desenvolver seu desafio:

- AWS
- GCP

Para a tecnologia que você selecionar, você deve criar um IAC que irá realizar a criação de uma máquina virtual (VM ou EC2) e um bucket.

Nesta máquina criada, você deve criar uma aplicação (na linguagem que você se sentir confortável) que irá ser executado a cada hora, e irá criar um arquivo de texto contendo a hora de criação como conteúdo, e realizar o upload deste arquivo criado para o bucket.




<h2>Para a resolução do desafio foi provisionado uma máquina com recursos básicos.</h2>
<br>
provider "aws" {  <br>
  region = "us-east-1" <br>
  profile = "default" <br>
} <br>

resource "aws_instance" "ec2-instance" { <br>
  ami = "ami-0574da719dca65348" <br>
  instance_type  = "t2.micro" <br>
  key_name = "alura_key" <br>
tags = { <br>
  name = "Teste AWS" <br>
} <br>
} <br>



<h2>Feito uma regra para habilitar o acesso via SSH na VPC que estava atrelada a Máquina virtual</h2> 



resource "aws_security_group" "security-group-for-builders" { <br>
    name = "habilitar-acesso-remoto" <br>
    description = "Habilitar o acesso remoto " <br>
    vpc_id = "vpc-00cbad41c1b2cd6f0 " <br>
    ingress { <br>
        description = "Allow inbound traffic" <br>
        from_port = 22 <br>
        to_port = 22 <br>
        protocol = "tcp" <br>
        cidr_blocks = ["0.0.0.0/0"] <br>
    } <br>
    tags = { <br>
        name = "habilitar_ssh" <br>
    } <br>
} <br>

	
 <h2>A Chave KMS foi criada para criptografar os objetos do bucket</h2> <br>
  
  resource "aws_kms_key" "mykey" { <br>
  description             = "This key is used to encrypt bucket objects" <br>
  deletion_window_in_days = 10 <br>
} <br>

  <h2>Após criar a chave criei o bucket</h2> <br>
  
resource "aws_s3_bucket" "builder" { <br>
        bucket = "builders-challenge" <br>
        acl = "private" <br>
        lifecycle_rule { <br>
	id = "archive" <br>
	enabled = true <br>
	transition { <br>
	days = 30 <br>
	storage_class = "Standard_IA"} <br>
	transition { <br>
	days = 30 <br>
	storage_class = "STANDARD_IA" <br>
	} <br>
} <br>
	versioning { <br>
	enabled = true <br>
	} <br>
	tags = { <br>
	  Enviroment: "QA" <br>
	} <br>

} <br>

<h2>Para finalizar o provisionamento a máquina foi implementado a criptografia para proteger os objetos do bucket, utilizando a chave KMS criada anteriormente.</h2>
resource "aws_s3_bucket_server_side_encryption_configuration" "encriptacao" { <br>
  bucket = aws_s3_bucket.builder.bucket <br>

  rule { <br>
    apply_server_side_encryption_by_default { <br>
      kms_master_key_id = aws_kms_key.mykey.arn <br>
      sse_algorithm     = "aws:kms" <br>
    } <br>
  }
  
  

  
 
