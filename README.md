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

Para a resolução do desafio foi provisionado uma máquina virtual com o terraform

<h1> provider "aws" { <\n>
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
</h1>
