#!/bin/bash
if [ ! -f /etc/krb5.conf ]; then
    echo "/etc/krb5.conf not found, please map your volume to make it available to this container"
    exit 1
fi

PRINCIPAL="$1"
PASSWORD="$2"

if [[ -z "${PRINCIPAL// }" ]]; then echo "PRINCIPAL hasn't been provided"; exit 1; fi;
if [[ -z "${PASSWORD// }" ]]; then echo "PASSWORD hasn't been provided, exit"; exit 1; fi;

KEYTAB_SECURITY=${KEYTAB_SECURITY:-"rc4-hmac"}

# password verifications
echo "========== Verifying password... =========="
echo $PASSWORD | kinit -V $PRINCIPAL
ret_code=$?
if [ $ret_code != 0 ]; then
  echo "Error : Wrong username/password combination"
  exit $ret_code
fi

# generate keytab
echo "========== Generating Keytab... =========="
KEYTAB_FILE=$(echo $PRINCIPAL | cut -d@ -f1 | cut -d/ -f1 | tr '[:upper:]' '[:lower:]').kt
ktutil < <(echo -e "addent -password -p $PRINCIPAL -k 1 -e $KEYTAB_SECURITY\n$PASSWORD\nwkt $KEYTAB_FILE\nquit")

# test keytab
echo "========== Testing Keytab =========="
kinit -V -kt $KEYTAB_FILE $PRINCIPAL
ret_code=$?
if [ $ret_code != 0 ]; then
  echo "Error : The keytab that was generated does not appear to work"
  exit $ret_code
fi

# copy output
echo "========== Writing keytab to /docker/secrets/$KEYTAB_FILE ========== "
echo "Make sure you have mapped your volume to the /docker/secrets volume"
cp $KEYTAB_FILE /docker/secrets/kmad0174.kt
echo "Successfully completed!"
