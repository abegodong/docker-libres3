#!/bin/bash

SXSETUP_CONF="/etc/sxserver/sxsetup.conf"
LIBRES3_CONF="/etc/libres3/libres3.conf"

if [ ! -r "$LIBRES3_CONF" ]; then
    cp "$LIBRES3_CONF".template $LIBRES3_CONF
fi

if [ -z "$SX_PORT" ]; then
    SX_PORT=443
fi

if [ -n "$S3_HOSTNAME" ] && [ -r "$SXSETUP_CONF" ]; then
    echo Setting S3 and SX parameters...
    . $SXSETUP_CONF
    sed -i "s/^secret_key=\"\"$/secret_key=\"$SX_ADMIN_KEY\"/" $LIBRES3_CONF
    sed -i "s/^s3_host=\"S3_HOSTNAME\"$/s3_host=\"$S3_HOSTNAME\"/" $LIBRES3_CONF
    sed -i "s/^sx_host=\"SX_CLUSTER_NAME\"$/sx_host=\"$SX_CLUSTER_NAME\"/" $LIBRES3_CONF
    sed -i "s/^sx_port=\"SX_PORT\"$/sx_port=\"$SX_PORT\"/" $LIBRES3_CONF
else
    echo "-e S3_HOSTNAME=s3.foo.com -v /path/to/sxsetup.conf:/etc/sxserver:ro are mandatory options"
    exit 1
fi

if [ -z "$DEF_SIZE" ]; then
    DEF_SIZE=1G
    echo Using default size for new buckets of 1G. Change it with -e DEF_SIZE=100G
fi
if [ -z "$DEF_REPLICA" ]; then
    DEF_REPLICA=1
    echo Using default replica count of 1. Change it with -e DEF_REPLICA=3
fi

sed -i "s/^replica_count=\"DEF_REPLICA\"$/replica_count=\"$DEF_REPLICA\"/" $LIBRES3_CONF
sed -i "s/^volume_size=\"DEF_SIZE\"$/volume_size=\"$DEF_SIZE\"/" $LIBRES3_CONF

echo Starting LibreS3...
/usr/sbin/libres3_ocsigen --foreground
