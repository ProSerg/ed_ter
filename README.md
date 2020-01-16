## create key pair

```
aws ec2 create-key-pair --key-name test-key
```

## move created key to ssh directory
```
mv ~/Download test-key.pem ~/.ssh/keys
cd ~/.ssh/keys
```

## get public key 
```
ssh-keygen -y -f ./test-key.pem
```



### terrafrom launce
terraform init
terraform plan

### original
https://medium.com/@hmalgewatta/setting-up-an-aws-ec2-instance-with-ssh-access-using-terraform-c336c812322f