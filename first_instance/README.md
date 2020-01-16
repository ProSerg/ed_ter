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


