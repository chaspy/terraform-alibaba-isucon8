# terraform-alibaba-isucon8

## Prerequisites
- Add key-pair(public key) to Alibaba Cloud
- Update keyname in main.tf

## Usage

```
$ cp .envrc.sample .envrc
# Update .envrc
$ source .envrc # or direnv allow
$ terraform init
$ terraform plan
$ terraform apply
# terraform destroy
```

You can login to the instance with `ssh root@<output ip address>`
