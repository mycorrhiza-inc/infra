# Kessler Infrastructure

Terraform managed infrastructure for the kessler environments.

# Getting Up and Running

## Install Terraform


## Digital Ocean Access Token
You will need to have a Digital Ocean Access Token which you can create from [here](https://cloud.digitalocean.com/account/api/tokens).

Next, in your terminal you will need to export it 

```bash
export DO_PAT="{YOUR_ACCESS_TOKEN}"
```

for repeated use, add this to your shell's environement `rc` file.

## SSH Keys

You will need to have an ssh key for running Terraform remotely.

1. Create a new ssh key.
2. Add the ssh public key to your Digital Ocean account [here](https://cloud.digitalocean.com/account/security). Name it `terraform`.

NOTICE: Whenever you rotate this key in Digital Ocean, update the name.

# Running Terraform 

## Building A Single Instance
terraform destroy 


To build a single instance, first plan the build:
```bash
terraform plan \
-target="module.instances['lonelyserpent']" \
-var "do_token=${DO_PAT}" \
-var "pvt_key=$HOME/.ssh/{YOUR_TERRAFORM_KEY_NAME}"
```

then apply the build:
```bash
terraform apply -target="module.instances['{INSTANCE_NAME}']" \
-var "do_token=${DO_PAT}" \
-var "pvt_key=$HOME/.ssh/{YOUR_TERRAFORM_KEY_NAME}"
```

and finally to destroy that instance:
```bash
terraform destroy -target="module.instances['{INSTANCE_NAME}']" \
-var "do_token=${DO_PAT}" \
-var "pvt_key=$HOME/.ssh/{YOUR_TERRAFORM_KEY_NAME}"

```