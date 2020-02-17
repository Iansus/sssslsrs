#!/bin/bash

command -v ncat &>/dev/null && echo '[+] NCat is already installed!' && exit 1

apt update
apt -y install ncat
