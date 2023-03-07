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
sudo yum install -y jq
sudo yum install -y mongocli python-pip
sudo amazon-linux-extras install epel -y
sudo yum install -y s3cmd
wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-amazon2-x86_64-100.6.1.rpm
sudo yum install -y mongodb-database-*.rpm

sudo cat >/home/ec2-user/mongo-backup.sh <<\EOL
#!/bin/sh -xe
MONGODUMP_PATH="/usr/bin/mongodump"
MONGO_DATABASE="sample_weatherdata" 
MONGO_HOST="${mongodb_dns}"
MONGO_PORT="27017"
TIMESTAMP=`date +%F-%H%M`
mongodbpass=$(aws secretsmanager get-secret-value  --secret-id mongoadminUserpassword --region ${aws_region} | jq --raw-output .SecretString | jq -r ."password")
$MONGODUMP_PATH -h $MONGO_HOST:$MONGO_PORT -d $MONGO_DATABASE --username adminUser --password $mongodbpass  --authenticationDatabase=admin
mv dump mongodb-$HOSTNAME-$TIMESTAMP
tar cf mongodb-$HOSTNAME-$TIMESTAMP.tar mongodb-$HOSTNAME-$TIMESTAMP
s3cmd put mongodb-$HOSTNAME-$TIMESTAMP.tar s3://${backup_s3_bucket}/mongodb-backups/mongodb-$HOSTNAME-$TIMESTAMP.tar
rm -rf mongodb-*
EOL
sudo chmod +x /home/ec2-user/mongo-backup.sh 
sudo sh -c 'echo "*/55 * * * * /home/ec2-user/mongo-backup.sh" >> /var/spool/cron/ec2-user'
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo rpm -ivh sess*
sudo rm sess*
