#/bin/bash

DOT=$1
PRIV=$2

terraform plan -auto-approve \
	-var "do_token=$DOT" \
	-var "pvt_key=$PRIV"

terraform apply \
	-var "do_token=$DOT" \
	-var "pvt_key=$PRIV"

terraform output -json >terraform_output.json

echo $PRIV

python3 playbooks/generate_inventory.py $PRIV

rm terraform_output.json
