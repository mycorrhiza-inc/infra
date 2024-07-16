#!/bin/bash

# Input JSON users data
users_data='${users_json}'

# Parse JSON and create users
echo "$users_data" | jq -c '.[]' | while read user; do
  username=$(echo $user | jq -r '.username')
  sudo=$(echo $user | jq -r '.sudo')
  public_keys=$(echo $user | jq -r '.public_keys[]')

  # Create user and set up SSH directory
  sudo useradd -m -s /bin/bash $username
  sudo mkdir -p /home/$username/.ssh
  for key in $public_keys; do
    echo $key | sudo tee /home/$username/.ssh/authorized_keys
  done
  sudo chown -R $username:$username /home/$username/.ssh
  sudo chmod 700 /home/$username/.ssh
  sudo chmod 600 /home/$username/.ssh/authorized_keys

  # Add to sudoers if required
  if [ "$sudo" == "true" ]; then
    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
  fi
done
