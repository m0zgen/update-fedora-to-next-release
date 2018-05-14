#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Script for upgrade current version Fedora to next (new) release
# as example - 26 to 27, 27 to 28, etc...

# Envs
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

RED='\033[1;31m'
GREEN='\033[1;32m'
CL='\033[0m'


# Update procedure
# -------------------------------------------------------------------------------------------\
# Check current user as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Update procedure
if [[ -e /etc/fedora-release ]]; then
  # Detect distributive
  echo "Fedora detected. Checking release..."
  CURRENT_RELEASE=$(cat /etc/fedora-release | awk {'print $3'})
  # Update question
  echo -en "You release is ${RED}$CURRENT_RELEASE${CL}... Update to new release(${GREEN}y${CL}/${RED}n${CL})? "
  read answer
  # If answer "y"
  if echo "$answer" | grep -iq "^y" ;then
    echo -en "${GREEN}Start upgrade proccess...${CL}\n"
    # Increment release number
    (( CURRENT_RELEASE++ ))
    echo -e "Update to $CURRENT_RELEASE...\n"
    # Update release
    dnf upgrade --refresh
    dnf install dnf-plugin-system-upgrade -y
    dnf system-upgrade download --releasever=$CURRENT_RELEASE
    # Question for reboot
    echo -en "reboot(${GREEN}y${CL}/${RED}n${CL})? "
    read answer
    if echo "$answer" | grep -iq "^y" ;then
      echo "System will be reboot..."
      dnf system-upgrade reboot
    else
      echo -e "You system is updated. Please reboot with bash command - ${GREEN}dnf system-upgrade reboot${CL}\nBye.. Bye..."
      exit 1
    fi
  fi
# If does not Fedora distributive
else
  echo "Not exist"
  exit 1
fi