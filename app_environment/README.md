## Goal 

work with environment

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

## Terraform
https://medium.com/faun/terraform-building-out-an-aws-application-environment-1993539a2b37
## Packer
http://blog.shippable.com/build-aws-amis-using-packer

##todo

prepare IAM for nginx instance
prepare dockerfile with terrafrom, python, packer
