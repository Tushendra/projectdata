#!/bin/bash

Ip=$(echo `az vm list-ip-addresses -g trainerrg1 -n testvm --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" -o tsv`)


echo "[linux]" >> /etc/ansible/hosts
echo "$Ip" >> /etc/ansible/hosts
echo "[linux:vars]" >> /etc/ansible/hosts
echo "ansible_ssh_user = azureuser" >> /etc/ansible/hosts
echo "ansible_ssh_pass = Password123" >> /etc/ansible/hosts
