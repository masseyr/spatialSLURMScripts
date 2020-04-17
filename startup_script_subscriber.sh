#!/bin/bash
apt-get update
apt-get install -y unzip
apt-get install -y python-dev
apt-get install -y python
apt-get install -y git
apt-get install -y build-essential
apt-get install -y python-gdal
apt-get install -y gdal-bin
apt-get install -y python-gdal
apt-get install -y python-pip
apt-get install -y libgdal-dev
apt-get install -y pkg-config
apt-get install -y python-opengl
apt-get install -y python-imaging
apt-get install -y libfreetype6-dev
apt-get install -y google-cloud-sdk
apt-get install -y postgresql postgresql-client
python -m pip install spectral
python -m pip install numpy
python -m pip install scipy
python -m pip install pandas
python -m pip install docker
python -m pip install psycopg2
python -m pip install psutil
python -m pip install pyyaml
python -m pip install xmltodict
python -m pip install google.cloud
python -m pip install google.cloud.storage
python -m pip install --upgrade google-cloud-pubsub
sudo apt-get install postgresql postgresql-client -y;
mkdir /root/cred; mkdir /root/log; mkdir /root/temp
wget https://ainet.io/cloudsql/cloud_sql_proxy -O /root/cred/cloud_sql_proxy
chmod +x /root/cred/cloud_sql_proxy
gsutil cp gs://software/keys/cloud-sql.json /root/cred/
echo 'net.ipv4.tcp_keepalive_time = 14400' | sudo tee -a /etc/sysctl.conf
sudo /sbin/sysctl --load=/etc/sysctl.conf
nohup /root/cred/cloud_sql_proxy -instances=magic-harpoon-000000:us-central1:aidb1=tcp:8080 -credential_file='/root/cred/cloud-sql.json' > '/root/cred/cloud-sql-proxy-'$HOSTNAME'-'$(date +%s)'.log' &
sleep $[ ( $RANDOM % 20 )  + 1 ]s
echo '{"queue":"ainet-channel1","subscription":"ainet-stream1"}' >> /root/environ.json
gcloud source repos clone ainet_receiver /root/ainet --project=magic-harpoon-000000
nohup python '/root/ainet/subscribe.py' > '/root/log/subscription-'$HOSTNAME'-'$(date +%s)'.log' & 
