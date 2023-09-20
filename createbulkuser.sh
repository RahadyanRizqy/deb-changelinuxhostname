read -p "Mysql (ROOT) Password: " ROOTPASSWORD
read -p "Common Password: " COMMON_PASSWORD
read -p "File List Input: " TXTFILE

DBPASSWORD=$COMMON_PASSWORD

# Read usernames from the list file and create users
while IFS= read -r USERNAME; do
  PASSWORD=$(openssl passwd -1 $COMMON_PASSWORD)  # Generate hashed password
  DBUSER=$USERNAME

  sudo useradd -m -p $PASSWORD $USERNAME # Create user with home directory
  sudo chsh -s /bin/bash $USERNAME
  sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
  find /home/$USERNAME -type d -exec chmod 755 {} \;
  find /home/$USERNAME -type f -exec chmod 644 {} \;
  cp -v index.html /home/$USERNAME;

  mysql -u root -p$ROOTPASSWORD -e "CREATE DATABASE $DBUSER;"
  mysql -u root -p$ROOTPASSWORD -e "CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASSWORD';"
  mysql -u root -p$ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $DBUSER.* TO '$DBUSER'@'localhost';"
  mysql -u root -p$ROOTPASSWORD -e "FLUSH PRIVILEGES;"

  echo "User $USERNAME and its database created with password: $COMMON_PASSWORD";
done < $TXTFILE # list of user from txt in same directory
