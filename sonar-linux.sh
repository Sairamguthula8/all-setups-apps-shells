#!/bin/bash

# Variables
SONAR_VERSION="10.3.0.82913"
SONAR_DB_USER="sonar"
SONAR_DB_PASS="sonar@123"
SONAR_DB_NAME="sonarqube"
SONAR_DIR="/opt/sonarqube"
EC2_USER="ec2-user"

# Update system
echo "Updating system..."
sudo yum update -y

# Install Java 17
echo "Installing Java 17..."
sudo amazon-linux-extras enable corretto17
sudo yum install java-17-amazon-corretto -y

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo yum install postgresql-server postgresql-contrib -y
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Setup PostgreSQL user and database
echo "Configuring PostgreSQL..."
sudo -u postgres psql <<EOF
CREATE USER $SONAR_DB_USER WITH ENCRYPTED PASSWORD '$SONAR_DB_PASS';
CREATE DATABASE $SONAR_DB_NAME OWNER $SONAR_DB_USER;
EOF

# Modify pg_hba.conf for password authentication
sudo sed -i "s/ident/md5/" /var/lib/pgsql/data/pg_hba.conf
sudo systemctl restart postgresql

# Download and extract SonarQube
echo "Downloading SonarQube..."
cd /opt
sudo yum install wget unzip -y
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip
sudo unzip sonarqube-$SONAR_VERSION.zip
sudo mv sonarqube-$SONAR_VERSION sonarqube
sudo chown -R $EC2_USER:$EC2_USER sonarqube

# Configure SonarQube
echo "Configuring SonarQube..."
sudo bash -c "cat >> $SONAR_DIR/conf/sonar.properties" <<EOF
sonar.jdbc.username=$SONAR_DB_USER
sonar.jdbc.password=$SONAR_DB_PASS
sonar.jdbc.url=jdbc:postgresql://localhost/$SONAR_DB_NAME
EOF

# Create systemd service
echo "Creating systemd service..."
sudo bash -c "cat > /etc/systemd/system/sonarqube.service" <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=$SONAR_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$SONAR_DIR/bin/linux-x86-64/sonar.sh stop
User=$EC2_USER
Group=$EC2_USER
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start SonarQube
echo "Starting SonarQube service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

echo "Installation Complete!"
echo "Access SonarQube at: http://<your-ec2-public-ip>:9000"
echo "Login: admin / admin"

#Connect & Run script:
#chmod +x install-sonarqube.sh
#sudo ./install-sonarqube.sh
