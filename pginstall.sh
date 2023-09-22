#!/bin/bash
#Tested on Ubuntu 22.04
#Tested on Debian 11
#Last test September 12th, 2023

install() {
    apt update
    apt install postgresql postgresql-contrib -y
    service postgresql restart

    echo "Create user for PostgreSQL"
    apt install lsb-release -y
    read -p "Username:" username

    if [ $(lsb_release -is) == 'Debian' ]; then
        su - postgres -c "createuser --superuser $username"
    else
        su -u postgres createuser --superuser $username
    fi

    adduser $username

    apt install curl -y
    apt install gnupg -y

    curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | apt-key add

    sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list &&  apt update'

    apt install pgadmin4-web -y

    /usr/pgadmin4/bin/setup-web.sh

    echo "host    all             all             192.168.1.0/24          trust" >> /etc/postgresql/14/main/pg_hba.conf

    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '0.0.0.0'/" /etc/postgresql/14/main/postgresql.conf

    apt install iptables-persistent -y

    iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 5432 -j ACCEPT
    iptables-save > /etc/iptables/rules.v4

    service iptables restart
    service postgresql restart

    ipv4=$(ip a | grep -oP 'inet \K[\d.]+' | tail -1)
    echo "Your PostgreSQL now can be accessed remotely on $ipv4:5432 and for pgAdmin4 http://$ipv4/pgadmin4/"
}

uninstall() {
	apt remove postgresql -y
	apt remove postgresql-contrib -y
	apt remove curl -y
	apt remove gnupg -y
	apt remove pgadmin4-web -y
	apt remove iptables-persistent -y
	apt autoremove -y
	apt autoclean
	apt clean
	rm -rf /var/lib/pgadmin
	rm -rf /usr/pgadmin4
    username=$(tail -n 1 /etc/passwd | cut -d: -f1)
    userdel -r $username
    userdel $username
}

echo "Choose your option: "
echo "[1]: Install PostgreSQL and pgAdmin4"
echo "[2]: Uninstall PostgreSQL and pgAdmin4"
read -p ": " option

if [ "$option" == '1' ]; then
    install
else
    uninstall
fi
