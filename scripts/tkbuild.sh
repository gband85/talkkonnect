#!/bin/bash

## talkkonnect headless mumble client/gateway with lcd screen and channel control
## Copyright (C) 2018-2019, Suvir Kumar <suvir@talkkonnect.com>
##
## This Source Code Form is subject to the terms of the Mozilla Public
## License, v. 2.0. If a copy of the MPL was not distributed with this
## file, You can obtain one at http://mozilla.org/MPL/2.0/.
##
## Software distributed under the License is distributed on an "AS IS" basis,
## WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
## for the specific language governing rights and limitations under the
## License.
##
## The Initial Developer of the Original Code is
## Suvir Kumar <suvir@talkkonnect.com>
## Portions created by the Initial Developer are Copyright (C) Suvir Kumar. All Rights Reserved.
##
## Contributor(s):
##
## Suvir Kumar <suvir@talkkonnect.com>
##
## My Blog is at www.talkkonnect.com
## The source code is hosted at github.com/talkkonnect


## Installation BASH Script for talkkonnect version 2 on fresh install of raspbian bullseye
## Please RUN this Script as root user

if [ "$SUDO_USER" ]
then
    USERNAME=$SUDO_USER
    echo "USERNAME is $USERNAME"
elif [ $USER == "root" ]
    then
        USERNAME=$USER
        echo "USERNAME is $USERNAME"
    else
        echo "Please run this script with sudo or as root"
        exit
fi

## If this script is run after a fresh install of raspbian you man want to update the 2 lines below

apt-get update
apt-get -y dist upgrade
apt-get install git -y

## Add talkkonnect user to the system
adduser --disabled-password --disabled-login --gecos "" talkkonnect
usermod -a -G cdrom,audio,video,plugdev,users,dialout,dip,input,gpio talkkonnect

## Install the dependencies required for talkkonnect
apt-get -y install libopenal-dev libopus-dev libasound2-dev git ffmpeg mplayer screen pkg-config

## Create the necessary directory structure under /home/talkkonnect/
cd /home/talkkonnect/
mkdir -p /home/talkkonnect/gocode
mkdir -p /home/talkkonnect/bin

## Create the log file
touch /var/log/talkkonnect.log

# Check Latest of GOLANG 64 Bit Version for Raspberry Pi
GOLANG_LATEST_STABLE_VERSION=$(curl -s https://go.dev/VERSION?m=text | grep go)
cputype=`lscpu | grep Architecture | cut -d ":" -f 2 | sed 's/ //g'`
bitsize=`getconf LONG_BIT`

cd /usr/local
if [ "$GO_VERSION" != "$GOLANG_LATEST_STABLE" ]
then 
if [ $bitsize == '32' ]
then
echo "32 bit processor"
wget -nc https://go.dev/dl/$GOLANG_LATEST_STABLE_VERSION.linux-armv6l.tar.gz $GOLANG_LATEST_STABLE_VERSION.linux-armv6l.tar.gz
tar -zxvf /usr/local/$GOLANG_LATEST_STABLE_VERSION.linux-armv6l.tar.gz
else
echo "64 bit processor"
wget -nc https://go.dev/dl/$GOLANG_LATEST_STABLE_VERSION.linux-arm64.tar.gz $GOLANG_LATEST_STABLE_VERSION.linux-arm64.tar.gz
tar -zxvf /usr/local/$GOLANG_LATEST_STABLE_VERSION.linux-arm64.tar.gz
fi
fi

#rm /usr/local/bin/go
ln -sf /usr/local/go/bin/go /usr/local/bin/go

echo "alias tk='cd /home/talkkonnect/gocode/src/github.com/talkkonnect/talkkonnect/'" >>  ~/.bashrc


## Set up GOENVIRONMENT
export GOPATH=/home/$USERNAME/gocode
export GO111MODULE="auto"

## Create the necessary directory structure under /home/$USERNAME
rm -r $GOPATH
mkdir -p $GOPATH/src/github.com/gband85
cd $GOPATH/src/github.com/gband85

## Get the latest source code of talkkonnect from github.com
echo "installing talkkonnect with traditional method avoiding go get cause its changed in golang 1.22 "
git clone https://github.com/gband85/talkkonnect
cd talkkonnect
go mod tidy

## Build talkkonnect as binary
go build -o /usr/local/bin/talkkonnect cmd/talkkonnect/main.go
#mv talkkonnect-bin /usr/local/bin/talkkonnect 

cp -f sample-configs/talkkonnect-version2-usb-gpio-example.xml /usr/local/etc/talkkonnect.xml
rm -r /usr/local/share/talkkonnect
mkdir /usr/local/share/talkkonnect
cp -rf audio circuit-diagram conf images sample-configs scripts soundfiles /usr/local/share/talkkonnect
cp -f conf/systemd/talkkonnect.service /etc/systemd/system/
chown -R $USERNAME:$USERNAME /home/$USERNAME

## Notify User
echo "=> Finished building TalKKonnect"
echo "=> talkkonnect binary is in /usr/local/bin"
echo "=> Now enter Mumble server connectivity details"
echo "talkkonnect.xml from /user/local/etc/"
echo "and configure talkkonnect features. Happy talkkonnecting!!"

exit


