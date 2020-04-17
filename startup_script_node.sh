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
mkdir /root/cred
wget https://ainet.io/cloudsql/cloud_sql_proxy -O /root/cred/cloud_sql_proxy
chmod +x /root/cred/cloud_sql_proxy
gsutil cp gs://software/keys/cloud-sql.json /root/cred/
echo 'net.ipv4.tcp_keepalive_time = 14400' | sudo tee -a /etc/sysctl.conf
sudo /sbin/sysctl --load=/etc/sysctl.conf
nohup /root/cred/cloud_sql_proxy -instances=magic-harpoon-000000:us-central1:aidb1=tcp:8080 -credential_file='/root/cred/cloud-sql.json' > '/root/cred/cloud-sql-proxy-'$HOSTNAME'-'$(date +%s)'.log' &
gcloud source repos clone ainet_server /root/ainet --project=magic-harpoon-000000
mkdir /root/log
nohup python '/root/ainet/queue_pusher.py' > '/root/log/q_pusher-'$HOSTNAME'-'$(date +%s)'.log' &
nohup python '/root/ainet/csql.py' > '/root/log/csql-'$HOSTNAME'-'$(date +%s)'.log' & 
