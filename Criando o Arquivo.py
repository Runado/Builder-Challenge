import paramiko
import time
import boto3
while True:
        aws = "44.211.218.25"
        k = paramiko.RSAKey.from_private_key_file("C:/Users/josel/Desktop/alura_key.pem")
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname=aws, username="ubuntu", port=22, pkey = k )
        print ("Conexão bem-sucedida")
        stdin, stdout, stderr = ssh.exec_command("date >> horario.txt && cat horario.txt")
        print("\nComando Enviado com Sucesso!")
        stdin.close()
        saida = stdout.read().decode("utf-8")
        print(saida)
        ssh.close()
        with open("saida.txt", "w") as arquivo:
                arquivo.write(saida)
        s3_client = boto3.client('s3')
        s3 = boto3.resource('s3')
        my_bucket = s3.Bucket("builders-challenge")
        response = s3_client.upload_file("saida.txt","builders-challenge","saida.txt")
        for bucket in s3.buckets.all():
                print("Nome do Bucket: "+bucket.name)
        for file in my_bucket.objects.all():
                print("Arquivo: " + file.key)
        print("\nA Rotina será executada novamente em 60 minutos")
        time.sleep(60*60)



