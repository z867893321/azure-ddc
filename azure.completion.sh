#!/bin/bash
read -p "请输入您所需要创建的资源组名称" ResourceGroup
read -p "输入虚拟机用户,密码(至少8位,必须包含一个大写字母,一个小写字母,一个数字,一个特殊符号!@#$%^&+=),名称" vmusername vmpassword 
read -p "请输入您需要创建的公共IP名称"  PublicIP
read -p "请输入您需要创建的公共IP DNS域名前缀" publicdns
read -p "请输入可用性集名称(2个)" AvailabilitySet1 AvailabilitySet2
Account=$ResourceGroup$RANDOM
Vnet=$ResourceGroup$RANDOM
Subnet=$ResourceGroup$RANDOM
mylb=$ResourceGroup'lb'
accountid=`azure account list|awk 'NR==4{print $4}'`
a=`azure group list|awk 'NR>4{print $2}'|sed -n "/^$ResourceGroup$/"p|wc -l`
while [ $a -ne 0 ]
do
 read -p "您输入的资源组名已存在，请重新输入" NewRG
 ResourceGroup=$NewRG
 a=`azure group list|awk 'NR>4{print $2}'|sed -n "/^"$ResourceGroup"$/"p|wc -l`
done
azure group create -n $ResourceGroup -l chinanorth
#######创建存储账户
azure storage account create -g $ResourceGroup -l chinanorth --kind Storage --sku-name GRS $Account
##### 创建虚拟网络
azure network vnet create -g $ResourceGroup -l chinanorth -n $Vnet 
##### 创建子网
azure network vnet subnet create -g $ResourceGroup -e $Vnet  -n $Subnet -a 10.0.2.0/24 
####创建公网ip
azure network public-ip create --resource-group $ResourceGroup  --location chinanorth --name $PublicIP --domain-name-label $publicdns -a Static
#####创建负载均衡器
azure network lb create -g $ResourceGroup -n $mylb -l chinanorth
#####创建前端IP池
azure network lb frontend-ip create -g $ResourceGroup -l $mylb  -i $PublicIP -n LoadBalancerFrontEnd
#####创建后端池
azure network lb address-pool create -g $ResourceGroup --lb-name $mylb -n ucp
####创建两个可用性集
azure availset create --resource-group $ResourceGroup --location chinanorth  --name $AvailabilitySet1

azure availset create --resource-group $ResourceGroup --location chinanorth  --name $AvailabilitySet2

for i in {1..6}
do
mynic=DDC-0$i$[$RANDOM%1000]
vmname=DDC-0$i
if [ $i -le 3 ]

then
azure network nic create -g $ResourceGroup -l chinanorth -n $mynic -m $Vnet  -k $Subnet -d "/subscriptions/$accountid/resourceGroups/$ResourceGroup/providers/Microsoft.Network/loadBalancers/$mylb/backendAddressPools/ucp"
azure vm create  \
 --admin-username $vmusername  \
 --admin-password $vmpassword  \
 -g $ResourceGroup \
 -l chinanorth \
 --os-type linux  \
 --availset-name $AvailabilitySet1  \
 --nic-name $mynic  \
 --storage-account-name  $Account  \
 --image-urn Canonical:UbuntuServer:14.04.5-LTS:latest \
 -n $vmname \
 -z Standard_DS3
#azure vm extension set $ResourceGroup $vmname  CustomScript Microsoft.Azure.Extensions 2.0 --public-config '{"fileUris": ["https://raw.githubusercontent.com/z867893321/test/master/docker.sh"],"commandToExecute": "./docker.sh"}'
else
azure network nic create -g $ResourceGroup -l chinanorth -n $mynic -m $Vnet  -k $Subnet
azure vm create  \
 --admin-username $vmusername  \
 --admin-password $vmpassword  \
 -g $ResourceGroup \
 -l chinanorth \
 --os-type linux  \
 --availset-name $AvailabilitySet2  \
 --nic-name $mynic  \
 --storage-account-name  $Account  \
--image-urn Canonical:UbuntuServer:14.04.5-LTS:latest \
 -n $vmname \
 -z Standard_DS3
#azure vm extension set $ResourceGroup $vmname  CustomScript Microsoft.Azure.Extensions 2.0 --public-config '{"fileUris": ["https://raw.githubusercontent.com/z867893321/test/master/docker.sh"],"commandToExecute": "./docker.sh"}'
fi
done

#azure vm create  \
# --admin-username $vmusername  \
# --admin-password $vmpassword  \
# -g $ResourceGroup \
# -l chinanorth \
# --os-type linux  \
# --availset-name $AvailabilitySet1  \
# --nic-name $nic$s  \
# --vnet-name $Vnet \
# --vnet-subnet-name  $subnet \
# --storage-account-name  $Account  \
# --image-urn Canonical:UbuntuServer:14.04.5-LTS:latest \
# -n ddc01 \
# -z Standard_DS3 \
# --customData "export IPDNS=$publicdns"
sudo apt-get install -y nfs -common
sudo mount -t cifs //hydsoft.file.core.chinacloudapi.cn/install /mnt -o vers=3.0,username=hydsoft,password=AhNAVn1hAKp8dfyFoBG447UzBRRPJO2wYou/ybB1T58TlvEijAV8uYb7ArZIrPIJbNB+OpfEJ72fDpk3NRngXg==,dir_mode=0777,file_mode=0777
