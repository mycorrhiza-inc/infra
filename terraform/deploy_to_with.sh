#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <hostname> <branch_name> <.env file location>"
	exit 1
fi

# Get the hostname and branch name from the arguments
hostname=$1
branch_name=$2
env_location=$3

# Apply the Ansible playbook to the specified host with the given branch name
ansible-playbook -i ./playbooks/inventory.ini ./playbooks/deploy.yml --limit "$hostname" -e branch_name="$branch_name" -e env_file="$env_location" -v
