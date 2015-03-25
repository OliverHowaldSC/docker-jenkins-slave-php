#!/bin/sh

#
# Usage: /ssh-key.sh "ssh-rsa AAAAB3Nz..."
#

IFS="$(printf '\n\t')"

key=$1

echo "Importing pub key to `whoami` account..."

mkdir -p ~/.ssh
if ! [[ -f ~/.ssh/authorized_keys ]]; then
  echo "Creating new ~/.ssh/authorized_keys"
  touch ~/.ssh/authorized_keys
fi

echo "Import ssh key: $key" 
grep -q "$key" ~/.ssh/authorized_keys || echo "$key imported_.key" >> ~/.ssh/authorized_keys
