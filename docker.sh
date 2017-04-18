#!/bin/bash
sudo apt-get purge docker-ce -y
sudo rm -rf /var/lib/docker
sudo apt-get update
sudo apt-get install -y \
     linux-image-extra-$(uname -r) \
     linux-image-extra-virtual
sudo apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
sudo apt-get update
sudo apt-get install -y docker-ce
echo "DOCKER_OPTS=\"\$DOCKER_OPTS --registry-mirror=https://24z731hs.mirror.aliyuncs.com\"" | sudo tee -a /etc/default/docker
sudo service docker restart

i=`hostname`|awk -F 0 `{print$2}`
if [ $i -eq 1]
then
ip=`ifconfig eth0|awk '{print$2}'|awk -F: 'NR==2{print$2}'`
sudo apt-get install -y tcl tk expect
sudo expect <<EOF
set timeout 300
spawn docker run --rm -it --name ucp  -v /var/run/docker.sock:/var/run/docker.sock   docker/ucp:2.1.2 install  --host-address $ip --admin-username hydsoft --admin-password hyddocker --interactive
expect "Additional aliases:"
send "\n"
expect eof
EOF

#docker run --rm -it --name ucp \
#  -v /var/run/docker.sock:/var/run/docker.sock \
#  docker/ucp:2.1.2 install \
#  --debug
#  --host-address $i \
#  --admin-username $ucp_admin_username
#  --admin-password $ucp_admin_password
 # --san $i
 # --san $controller_slb_ip
#  --interactive

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
