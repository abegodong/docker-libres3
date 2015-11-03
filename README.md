## WHAT IS THIS?

A ready to use LibreS3 Docker container.

## HOW TO USE IT?

TL;DR

   docker run -v /path/to/sxsetup.conf:/etc/sxserver:ro -e S3_HOSTNAME=s3.foo.com \
       -p 8443:443 -p 8008:80 --restart=always -d --name libres3 skylable/libres3

By default new buckets will have replica=1 and size=1G. To change that:

   docker run -v /path/to/sxsetup.conf:/etc/sxserver:ro -e S3_HOSTNAME=s3.foo.com -e DEF_REPLICA=3 -e DEF_SIZE=100G \
       -p 8443:443 -p 8008:80 --restart=always -d --name libres3 skylable/libres3

## MORE INFO

Visit http://www.skylable.com/products/libres3 to learn more about SX and LibreS3.

LibreS3 manual: http://www.skylable.com/products/libres3/manual.pdf

