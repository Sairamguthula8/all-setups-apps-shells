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
mv sonarqube-10.3.0.82913 /opt/sonarqube
#change ownership to the user and switch to linux binaries to start the  service
chmod +x sonarqube
useradd sonaradmin
chown -R <sonar_user>:<sonar_user_group> /opt/sonarqube
su - sonaradmin
cd /opt/sonarqube/bin/linux-x86-64
./sonar.sh start
./sonar.sh status
