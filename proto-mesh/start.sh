#!/bin/bash

# Verify that the config file exists
if [ ! -f config ]; then
    echo 'config file not present! Aborting.'
    exit
fi

# Load config file
source config

# We're starting! :D
echo "Starting proto-mesh..."

# Initialize the network interface
bash $IFACE_SETUP_SCRIPT

# Do other things
cd utils

bash batman-start.sh

#Initialize Gateway based on config
if [ $NET_GATEWAY == 'server' ]; then
   echo "Setting up Batman Network Gateway" 
   sudo batctl bl 1
   sudo brctl addbr br0
   sudo brctl addif br0 bat0 eth0 
   #sudo batctl gw_mode server
elif [ $NET_GATEWAY == 'client' ]; then
   echo "Setting up Batman Network Client"  
   sudo batctl bl 1
   #sudo batctl gw_mode client 20
else
   sudo batctl bl 1
fi

# If KadNode name resolution is enabled, wait for neighbors
# and then start KadNode
if [ $ENABLE_KADNODE == '1' ]; then 
   bash wait-for-neighbor.sh
   bash kadnode-start.sh $HOSTNAME
fi

cd ../
