#!/bin/bash

setparms () {
# Takes the variables from the grep search
instid=$1
avz=$4
if [[ $pubpriv = "public" ]]
then
    serverip=$2
else
    serverip=$3
fi
}

if [[ $# != 2 ]]
then
        echo "Need the region and whether public of private address"
        echo "e.g. ${0} <region> <public/private>"
        exit 2
else
        region=$1
        pubpriv=$2
fi

# Used to show all the instances in the region
aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,PrivateIpAddress,Tags[?Key==`Name`],Placement.AvailabilityZone]' --output text > servers.txt

# Show servers names and select one
grep Name servers.txt | cut -f2 | column
echo "Select a servers name"
read name

setparms $(grep -B 1 $name servers.txt | grep i-)

#Generate a new key to connect each time and don't prompt
rm -rf ~/.ssh/newtempkey
# For Linux
# ssh-keygen -q -b 4096 -t rsa -f ~/.ssh/newtempkey -N "" 0>&-
# For Osx
ssh-keygen -q -b 4096 -t rsa -f ~/.ssh/newtempkey -N "" 

aws ec2-instance-connect send-ssh-public-key --region $region --instance-id $instid --availability-zone $avz --instance-os-user ubuntu --ssh-public-key file://newtempkey.pub

ssh -i ~/.ssh/newtempkey ubuntu@$serverip
