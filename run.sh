#!/bin/bash 

set -e

SXSETUP_CONF="/etc/sxserver/sxsetup.conf"
DATABAG="/data"
ETC_DIR="$DATABAG/etc"
LOG_DIR="$DATABAG/logs"
LIBRES3_CONF="$ETC_DIR/libres3/libres3.conf"
LIBRES3_KEY="$ETC_DIR/ssl/private/libres3.key"
LIBRES3_CERT="$ETC_DIR/ssl/certs/libres3.pem"

if ! [ -r "$LIBRES3_CONF" ]; then
    if [ -n "$S3_HOSTNAME" ] && [ -r "$SXSETUP_CONF" ]; then
        echo First setup of LibreS3 node for $S3_HOSTNAME
        echo $SXSETUP_CONF found
    else
        echo "Please use this syntax:"
        echo "docker run -v /path/to/databag:/data -v /path/to/etc/sxserver:/etc/sxserver:ro \
           -e S3_HOSTNAME=s3.foo.com \
           -p 8443:443 -p 8008:80 --restart=always -d --name libres3 skylable/libres3"
        echo This image expects sxsetup.conf to be available under /etc/sxserver.
        exit 1
    fi

    # read settings from sxsetup.conf
    . $SXSETUP_CONF
    if [ $SX_USE_SSL = "no" ]; then 
       LIBRES3_FLAGS="--no-ssl"
    else
       if ! [ -r "$LIBRES3_KEY" ] || ! [ -r "$LIBRES3_CERT" ]; then
          echo Generating self-signed SSL certificate.
          echo If you want to use your own certificate, place the cert in $LIBRES3_CERT and the key in $LIBRES3_KEY
          libres3_certgen $S3_HOSTNAME
       fi
    fi

    mkdir -p $ETC_DIR/libres3
    cp /etc/mime.types $ETC_DIR/libres3/
    if [ -z "$DEF_SIZE" ]; then
        DEF_SIZE=1G
        echo Using default size for new buckets of 1G. Change it with -e DEF_SIZE=100G
    fi
    if [ -z "$DEF_REPLICA" ]; then
        DEF_REPLICA=1
        echo Using default replica count of 1. Change it with -e DEF_REPLICA=3
    fi

    # FIXME: workaround to force LibreS3 to run as nobody/nobody, no matter what sxsetup.conf says
    umask 077
    SXSETUP_TEMP=$(mktemp)
    cp $SXSETUP_CONF $SXSETUP_TEMP
    sed -i 's,^SX_SERVER_GROUP=".*$,SX_SERVER_GROUP="nobody",' $SXSETUP_TEMP

    # initial setup of LibreS3
    libres3_setup --s3-host $S3_HOSTNAME \
        --s3-http-port 80 \
        --s3-https-port 443 \
        --default-replica $DEF_REPLICA \
        --default-volume-size $DEF_SIZE \
        --sxsetup-conf $SXSETUP_TEMP \
        --batch $LIBRES3_FLAGS
    if ! [ -r $LIBRES3_CONF  ]; then
        echo Error running libres3_setup: cannot find $LIBRES3_CONF
        exit 1
    fi
    
    # set the admin key
    sed -i "s/^secret_key=\"\"$/secret_key=\"$SX_ADMIN_KEY\"/" $LIBRES3_CONF
    # turn on sane defaults
    echo "allow_public_bucket_index=true" >>$LIBRES3_CONF
    echo "allow_list_all_volumes=true" >>$LIBRES3_CONF


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

