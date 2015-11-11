## WHAT IS THIS?

A ready to use LibreS3 Docker image.

## HOW TO USE IT?

TL;DR

   docker run -v /path/to/databag:/data -v /path/to/etc/sxserver:/etc/sxserver:ro \
       -e S3_HOSTNAME=s3.foo.com \
       -p 8443:8443 -p 8008:8008 --restart=always -d --name libres3 skylable/libres3

By default new buckets will have replica=1 and size=1G. To change that:

   docker run -v /path/to/databag:/data -v /path/to/etc/sxserver:/etc/sxserver:ro \
       -e S3_HOSTNAME=s3.foo.com -e DEF_REPLICA=3 -e DEF_SIZE=100G \
       -p 8443:8443 -p 8008:8008 --restart=always -d --name libres3 skylable/libres3

Logs will be stored under /data/logs and config. files will be created in /data/etc.
Make sure /data is rw.

You must also mount the directory where you store sxsetup.conf (typically /etc/sxserver) 
under /etc/sxserver. This volume shall be mounted as ro.

## REPLACE SSL CERTS

If no SSL cert/key are found, a self-signed cert. is automatically generated.
If you want to use your own cert., replace the files /data/etc/ssl/certs/libres3.pem
and /data/etc/ssl/keys/libres3.key.

## HOW TO UPGRADE?

   docker pull skylable/libres3
   docker stop libres3
   docker rm libres3
   docker start libres3

## MORE INFO

Visit http://www.skylable.com/products/libres3 to learn more about SX and LibreS3.

LibreS3 manual: http://www.skylable.com/products/libres3/manual.pdf

