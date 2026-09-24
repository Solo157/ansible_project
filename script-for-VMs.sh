#!/bin/bash
-------------------------
# generate keys
ssh-keygen -t rsa -b 2048 -f ~/.ssh/my_otus_id_rsa_cicd_vms -N ""

ZONE=ru-central1-b
EXTERNAL_SUBNET=default-ru-central1-b
SSH_KEY=$(cat ~/.ssh/my_otus_id_rsa_cicd_vms.pub)
SG_ID=$(yc vpc security-group get default-sg-enpii3i3t1ln2t0i8c5k --format json | jq -r .id)

# SSH password for the ubuntu user (login by password, not by key)
VM_USER_PASSWD='otus'

# create static public IP for DEVELOP VM
if yc vpc address list | grep -q develop-public-ip; then
  echo "Public IP already exists, skip creation"
else
  echo "create static public IP"
  yc vpc address create --name develop-public-ip --external-ipv4 zone=$ZONE
fi

# create virt machine for DEVELOP VM
export DEVELOP_HOST_IP=$(yc vpc address get develop-public-ip --format json | jq -r '.external_ipv4_address.address')
yc compute instance create \
  --name develop-host \
  --zone $ZONE \
  --preemptible \
  --core-fraction 20 \
  --metadata-from-file user-data=<(cat <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    plain_text_passwd: '$VM_USER_PASSWD'
EOF
) \
  --create-boot-disk image-id=fd8dcjve5vsdhbqs6nqj \
  --network-interface subnet-name=$EXTERNAL_SUBNET,nat-ip-version=ipv4,nat-address=$DEVELOP_HOST_IP,security-group-ids=$SG_ID \
  --hostname develop-host


# create static public IP for PROD VM
if yc vpc address list | grep -q prod-public-ip; then
  echo "Public IP already exists, skip creation"
else
  echo "create static public IP"
  yc vpc address create --name prod-public-ip --external-ipv4 zone=$ZONE
fi

# create virt machine for PROD VM
export PROD_HOST_IP=$(yc vpc address get prod-public-ip --format json | jq -r '.external_ipv4_address.address')

yc compute instance create \
  --name prod-host \
  --zone $ZONE \
  --preemptible \
  --core-fraction 20 \
  --metadata-from-file user-data=<(cat <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    plain_text_passwd: '$VM_USER_PASSWD'
EOF
) \
  --create-boot-disk image-id=fd8dcjve5vsdhbqs6nqj \
  --network-interface subnet-name=$EXTERNAL_SUBNET,nat-ip-version=ipv4,nat-address=$PROD_HOST_IP,security-group-ids=$SG_ID \
  --hostname prod-host


# create static public IP for VAULT VM
#if yc vpc address list | grep -q vault-public-ip; then
#  echo "Public IP already exists, skip creation"
#else
#  echo "create static public IP"
#  yc vpc address create --name vault-public-ip --external-ipv4 zone=$ZONE
#fi

# create virt machine for VAULT VM
#export VAULT_HOST_IP=$(yc vpc address get vault-public-ip --format json | jq -r '.external_ipv4_address.address')
#yc compute instance create \
#  --name vault-host \
#  --zone $ZONE \
#  --preemptible \
#  --core-fraction 20 \
#  --metadata-from-file user-data=<(cat <<EOF
##cloud-config
#users:
#  - name: ubuntu
#    sudo: ALL=(ALL) NOPASSWD:ALL
#    ssh-authorized-keys:
#      - $(cat ~/.ssh/my_otus_id_rsa_cicd_vms.pub)
#EOF
#) \
#  --create-boot-disk image-id=fd8dcjve5vsdhbqs6nqj \
#  --network-interface subnet-name=$EXTERNAL_SUBNET,nat-ip-version=ipv4,nat-address=$VAULT_HOST_IP,security-group-ids=$SG_ID \
#  --hostname vault-host

# waiting.. until VMs are ready
sleep 30

ssh-keyscan -H $DEVELOP_HOST_IP >> ~/.ssh/known_hosts
DEVELOP_HOST_USER=$(ssh -i ~/.ssh/my_otus_id_rsa_cicd_vms -o IdentitiesOnly=yes ubuntu@$DEVELOP_HOST_IP "whoami")
if [ "$DEVELOP_HOST_USER" = "ubuntu" ]; then
  echo "OK: user is ubuntu on DEVELOP_HOST"
else
  echo "ERROR: wrong user for DEVELOP_HOST"
fi

ssh-keyscan -H $PROD_HOST_IP >> ~/.ssh/known_hosts
PROD_HOST_USER=$(ssh -i ~/.ssh/my_otus_id_rsa_cicd_vms -o IdentitiesOnly=yes ubuntu@$PROD_HOST_IP "whoami")
if [ "$PROD_HOST_USER" = "ubuntu" ]; then
  echo "OK: user is ubuntu on PROD_HOST"
else
  echo "ERROR: wrong user for PROD_HOST"
fi

#ssh-keyscan -H $VAULT_HOST_IP >> ~/.ssh/known_hosts
#VAULT_HOST_USER=$(ssh -i ~/.ssh/my_otus_id_rsa_cicd_vms -o IdentitiesOnly=yes ubuntu@$VAULT_HOST_IP "whoami")
#if [ "$VAULT_HOST_USER" = "ubuntu" ]; then
#  echo "OK: user is ubuntu on VAULT_HOST"
#else
#  echo "ERROR: wrong user for VAULT_HOST"
#fi