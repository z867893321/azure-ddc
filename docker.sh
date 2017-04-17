#!/bin/bash
sudo cd /opt
sudo wget https://download.docker.com/linux/ubuntu/dists/trusty/pool/stable/amd64/docker-ce_17.03.0~ce-0~ubuntu-trusty_amd64.deb
sudo dpkg -i docker-ce_17.03.0-ce-0~ubuntu-trusty_amd64.deb
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://ae6kri8o.mirror.aliyuncs.com"]
}
EOF

i=`hostname`|awk -F 0 `{print$2}`
if [ $i -eq 1]
then

docker run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:2.1.2 install \
  --debug
  --host-address $i \
  --admin-username $ucp_admin_username
  --admin-password $ucp_admin_password
 # --san $i
 # --san $controller_slb_ip
  --interactive

sudo docker swarm join-token worker|awk 'NR>2{print$0}' >>/opt/worker.sh
sudo docker swarm join-token manager|awk 'NR>2{print$0}' >>/opt/manager.sh
sudo apt-get install nfs-kernel-server -y
sudo tee /etc/exports <<-'EOF'
/opt/ *(rw,sync,no_root_squash,no_subtree_check)
EOF
sudo rpc.mountd
sudo service nfs-kernel-server restart
elif [$i -gt 1 && $i -le 3]
then

########################
sudo apt-get install nfs-common
mount -t nfs DDC-01/opt /opt
#bash /opt/workt.sh
###########
bash /opt/manager.sh
else
sudo apt-get install nfs-common
mount -t nfs DDC-01/opt /op
bash /opt/worker.sh
fi
