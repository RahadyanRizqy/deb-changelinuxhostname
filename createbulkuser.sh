#!/bin/bash

# Define the common password
COMMON_PASSWORD="your password"

# Read usernames from the list file and create users
while IFS= read -r USERNAME; do
  PASSWORD=$(openssl passwd -1 $COMMON_PASSWORD)  # Generate hashed password

  sudo useradd -m -p $PASSWORD $USERNAME  # Create user with home directory
  sudo chsh -s /bin/bash $USERNAME
  sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
  find /home/$USERNAME -type d -exec chmod 755 {} \;
  find /home/$USERNAME -type f -exec chmod 644 {} \;
  cp -v index.html /home/$USERNAME;
  echo "User $USERNAME created with password: $COMMON_PASSWORD"
done < pwebauser.txt # list of user from txt in same directory
