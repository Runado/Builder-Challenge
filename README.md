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

## *Para coletar a hora da máquina depois salvar em um arquivo e enviar para o S3 Bucket foi feito um Script em Python porém funciona apenas localmente na máquina do usuário e apenas enquanto o processo estiver em standby no computador em que está executando o Script. 

<h2> Importando as bibliotecas e realizando o acesso SSH </h2>

import paramiko <br>
import time <br>
import boto3 <br> 
while True: <br>
        aws = "44.211.218.25" #IP do Servidor AWS <br>
        k = paramiko.RSAKey.from_private_key_file("Caminho da Chave PEM ou PPK") <br>
        ssh = paramiko.SSHClient() <br>
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy()) <br>
        ssh.connect(hostname=aws, username="ubuntu", port=22, pkey = k ) <br>
        print ("Conexão bem-sucedida") <br>

<h2> Após a conexão ser estabelecida enviei o comando que grava a saída do "date" no arquivo horario.txt e depois eu exibo o arquivo para gerar uma saída e então ficar salvo na saída "stdout" após isso a saída é gravada em uma variavel e depois é gerado um arquivo saida.txt com o output do comando date na máquina local.</h2>
	stdin, stdout, stderr = ssh.exec_command("date >> horario.txt && cat horario.txt") // gera o arquivo horario.txt e depois mostra o conteúdo do arquivo <br>
        print("\nComando Enviado com Sucesso!")<br>
        stdin.close() //assim que fechar o input a saída de tudo que foi feito na máquina AWS ficará salvo no stdout.<br>
        saida = stdout.read().decode("utf-8") // gravando a saída em uma variável<br>
        print(saida)<br>
        ssh.close() // fechando a conexão ssh<br>
        
	with open("saida.txt", "w") as arquivo: // gerando um arquivo na máquina local e gravando com a saída capturada ( Horário da máquina da AWS)<br>
                arquivo.write(saida)<br>
<h2> Neste script o arquivo que foi enviado para o bucket não foi o que está na máquina AWS e sim o que foi gerado localmente apartir da sáida gravada, após isso foi só necessário utilizar biblioteca boto3 para enviar o arquivo local saida.txt e conferir se o bucket foi criado corretamente e se o arquivo está lá.
	
	
	s3_client = boto3.client('s3') <br>
        s3 = boto3.resource('s3')<br>
        my_bucket = s3.Bucket("builders-challenge")<br>
        response = s3_client.upload_file("saida.txt","builders-challenge","saida.txt") // enviando o arquivo <br>
        for bucket in s3.buckets.all():<br>
                print("Nome do Bucket: "+bucket.name)   // verificando os buckets existentes<br>
        for file in my_bucket.objects.all():<br>
                print("Arquivo: " + file.key)  // verificando se o arquivo está lá <br>
        print("\nA Rotina será executada novamente em 60 minutos")<br>
        time.sleep(60*60) // todo o código está em um Loop Infinito então o programa foi congelado e após 1 hora ele irá executar novamente coletando o horário e salvando na máquina local e enviando o arquivo pro bucket<br> 

<br>
	<br>
	<br>
	<br>
	<br>
	
##Tentativa que não deu certo 	
<h2> Tentei cumprir esse desafio utilizando python, shell script e crontab mas sem sucesso devido a um erro que não consegui resolver em tempo ágil, a idéia era apartir de um programa em python acessar a máquina e configurar o crontab para a cada 1 hora,  gravar a saida do comando "date" em um arquivo "horario.txt" depois configurar outra rotina para enviar o arquivo horário.txt através de um shell script que iria se conectar com a API rest da AWS e realizar o upload a cada 1 hora também, deixei abaixo o código fonte do shell script, por algum motivo a execução do shell script não terminava e também não realizava o upload.


file=horario.txt <br>
bucket=builders-challenge <br>
resource="/${bucket}/${file}" <br>
contentType="application/x-compressed-tar" <br>
dateValue=`date -R` <br>
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}" <br>
s3Key="CHAVE PUBLICA AWS" <br>
s3Secret="CHAVE PRIVADA AWS" <br>
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64` <br>
curl -X PUT -T "${file}" \ <br>
  -H "Host: ${bucket}.s3.amazonaws.com" \ <br>
  -H "Date: ${dateValue}" \ <br>
  -H "Content-Type: ${contentType}" \ <br>
  -H "Authorization: AWS ${s3Key}:${signature}" \ <br>
  https://${bucket}.s3-us-east-2.amazonaws.com/${file} <br>
	
	
## Para verificar a saida do python, o bucket criado na aws e o conteúdo do objeto que foi enviado acesse o link: https://1drv.ms/u/s!AmI54ft7P6O7tS477beDnvHvuUwZ?e=Nmtk60
	

	
	


	

  
 
