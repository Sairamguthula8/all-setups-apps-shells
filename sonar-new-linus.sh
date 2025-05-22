# Update system
sudo yum update -y

# Install Java 17
sudo amazon-linux-extras enable corretto17
sudo yum install java-17-amazon-corretto -y
#Download sonarqube latest
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip
sudo yum install unzip -y
sudo unzip /opt/sonarqube-10.3.0.82913.zip

#change ownership to the user and switch to linux binaries to start the  service
chown -R <sonar_user>:<sonar_user_group> /opt/sonarqube-10.3.0.82913
cd /opt/sonarqube-10.3.0.82913/bin/linux-x86-64
./sonar.sh start
