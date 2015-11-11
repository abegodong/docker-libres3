#!/bin/bash 

set -e

SXSETUP_CONF="/etc/sxserver/sxsetup.conf"
DATABAG="/data"
ETC_DIR="$DATABAG/etc"
LOG_DIR="$DATABAG/logs"
LIBRES3_CONF="$ETC_DIR/libres3/libres3.conf"
LIBRES3_KEY="$ETC_DIR/ssl/keys/libres3.key"
LIBRES3_CERT="$ETC_DIR/ssl/certs/libres3.pem"

if [ -n "$S3_HOSTNAME" ] && [ -r "$SXSETUP_CONF" ]; then
    echo Starting S3 node for $S3_HOSTNAME
    echo $SXSETUP_CONF found
else
    echo "Please use this syntax:"
    echo "docker run -v /path/to/databag:/data -v /path/to/etc/sxserver:/etc/sxserver:ro \
       -e S3_HOSTNAME=s3.foo.com \
       -p 8443:443 -p 8008:80 --restart=always -d --name libres3 skylable/libres3"
    exit 1
fi

if ! [ -r "$LIBRES3_KEY" ] || ! [ -r "$LIBRES3_CERT" ]; then
    echo Generating self-signed SSL certificate. 
    echo If you want to use your own certificate, place the cert in $LIBRES3_CERT and the key in $LIBRES3_KEY
    libres3_certgen $S3_HOSTNAME
fi

if ! [ -r "$LIBRES3_CONF" ]; then
    if grep -q 'SX_USE_SSL="no"' $SXSETUP_CONF; then
       LIBRES3_FLAGS="--no-ssl"
    fi
    
    mkdir -p $ETC_DIR/libres3
    cp /etc/libres3/mime.types $ETC_DIR/libres3/
    if [ -z "$DEF_SIZE" ]; then
        DEF_SIZE=1G
        echo Using default size for new buckets of 1G. Change it with -e DEF_SIZE=100G
    fi
    if [ -z "$DEF_REPLICA" ]; then
        DEF_REPLICA=1
        echo Using default replica count of 1. Change it with -e DEF_REPLICA=3
    fi
    libres3_setup --s3-host $S3_HOSTNAME \
        --s3-http-port 80 \
        --s3-https-port 443 \
        --default-replica $DEF_REPLICA \
        --default-volume-size $DEF_SIZE \
        --sxsetup-conf $SXSETUP_CONF \
        --batch $LIBRES3_FLAGS
    if [ $? -ne 0 ]; then
        echo Error running libres3_setup
        exit 1
    fi
fi


# store logs on permanent storage
mkdir -p $LOG_DIR
chown nobody $LOG_DIR
sed -i "s,^#logdir=,logdir=$LOG_DIR," $LIBRES3_CONF

# sends errors to docker logs
touch $LOG_DIR/errors.log
tail -F $LOG_DIR/errors.log &

echo Starting LibreS3...
/usr/sbin/libres3_ocsigen --foreground

