echo "Create user for PostgreSQL"
read -p "Username:" username
read -p "Email:" email

apt update

apt install postgresql postgresql-contrib y

service postgresql restart

su -u postgres createuser --superuser $username

apt install curl -y

apt install gnupg -y

curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | apt-key add

sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list &&  apt update'

apt install pgadmin4-web -y

echo -e "$email\npgadmin4\npgadmin4\ny\ny\n" | sudo /usr/pgadmin4/bin/setup-web.sh

echo "host    all             all             192.168.1.0/24          trust" >> /etc/postgresql/14/main/pg_hba.conf

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '0.0.0.0'/" /etc/postgresql/14/main/postgresql.conf

apt install iptables-persistent -y

iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

iptables -A OUTPUT -p tcp --dport 3306 -j ACCEPT

iptables-save > /etc/iptables/rules.v4

service iptables restart

service postgresql restart
