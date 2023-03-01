#!/bin/sh -xe
sudo cat >/etc/yum.repos.d/mongodb-org-5.0.repo <<EOL
[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc
EOL
sleep 15
sudo yum install -y mongodb-org-5.0.10 mongodb-org-database-5.0.10 mongodb-org-server-5.0.10 mongodb-org-mongos-5.0.10 mongodb-org-tools-5.0.10
sleep 10
sudo yum install -y jq
sudo yum install -y git make checkpolicy policycoreutils selinux-policy-devel
git clone https://github.com/mongodb/mongodb-selinux
cd mongodb-selinux
make
sudo make install
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
sudo systemctl start mongod
sleep 4
systemctl is-active --quiet mongod && echo Service is running
sudo cat >/home/ec2-user/mongo-user.js <<\EOL
conn = new Mongo();
db = conn.getDB("test");
db = db.getSiblingDB('admin')
db = db.createUser({ user: "adminUser", pwd: "runtimechange", roles: ["root"] })
EOL

mongodbpass=$(aws secretsmanager get-secret-value  --secret-id mongoadminUserpassword --region ${aws_region} | jq --raw-output .SecretString | jq -r ."password")

sudo sed -i 's/runtimechange/'$mongodbpass'/g'  /home/ec2-user/mongo-user.js
createuser=$(mongo /home/ec2-user/mongo-user.js)
sleep 5
sudo systemctl stop mongod
sleep 5
sudo rm /home/ec2-user/mongo-user.js
sudo tee -a /etc/mongod.conf > /dev/null <<EOT
security:
  authorization: enabled
EOT
sudo systemctl start mongod
systemctl is-active --quiet mongod && echo Service is running
sudo yum install -y mongocli
git clone https://github.com/neelabalan/mongodb-sample-dataset.git
cd mongodb-sample-dataset/
rm -rf sample_airbnb/ sample_geospatial/ sample_supplies/  sample_analytics/ sample_mflix/ sample_training/
mongodbpass=$(aws secretsmanager get-secret-value  --secret-id mongoadminUserpassword --region ${aws_region} | jq --raw-output .SecretString | jq -r ."password")
./script.sh localhost 27017 adminUser $mongodbpass

