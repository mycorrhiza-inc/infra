import json

import sys

# Check if an argument is provided
if len(sys.argv) < 2:
    print("Usage: python example.py <first_argument>")
    sys.exit(1)

# Get the first argument
priv_key = sys.argv[1]

with open('terraform_output.json') as f:
    tout = json.load(f)


values = tout["ips"]["value"][0]

out = []
with open('playbooks/inventory.ini', 'w') as f:
    f.write('[webservers]\n')
    for v in values:
        name = v
        ip = values[v]['public_ip']
        f.write(f"{ip} ansible_user=root ansible_ssh_private_key_file={
                priv_key}\n")
