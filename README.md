## WHAT IS THIS?

A ready to use LibreS3 Docker image.

Stable releases are available as tags, e.g.:

   docker pull skylable/libres3:release-1.1

Latest master is always available as:

   docker pull skylable/libres3:latest


## GETTING STARTED

TL;DR

   docker run -v /var/lib/docker-libres3:/data -v /path/to/etc/sxserver:/etc/sxserver:ro \
       -e S3_HOSTNAME=s3.foo.com \
       -p 8443:443 -p 8008:80 --restart=always -d --name libres3 skylable/libres3

By default new buckets will have replica=1 and size=1G. To change the defaults:

   docker run -v /path/to/databag:/data -v /path/to/etc/sxserver:/etc/sxserver:ro \
       -e S3_HOSTNAME=s3.foo.com -e DEF_REPLICA=3 -e DEF_SIZE=100G \
       -p 8443:443 -p 8008:80 --restart=always -d --name libres3 skylable/libres3

or edit /var/lib/docker-libres3/etc/libres3/libres3.conf.

Long explanation:

The first time you run this container you need to mount two volumes:

    - /var/lib/docker-libres3 is where LibreS3 will store persistent data like logs, config files.
    - /path/to/etc/sxserver is a read-only dir containing sxsetup.conf (see Skylable SX doc)

After the initial config. you only need to pass -v /var/lib/docker-libres3:/data

You can inspect LibreS3 logs also with: 

   docker logs -f libres3


## HOW TO CONNECT

LibreS3 will start accepting connections  on port 443 (HTTPS) and 80 (HTTP) inside 
Docker network.
If you want to make these ports available outside the Docker network, you need 
to publish the ports with the -p option, as shown in the examples above.

Your container will generate some sample config. files for s3cmd and python-boto under 
/var/lib/docker-libres3/etc/libres3.

## REPLACE SSL CERTS

If no SSL cert/key are found, a self-signed cert. is automatically generated.
If you want to use your own cert., replace the files /var/lib/docker-libres3/etc/ssl/certs/libres3.pem
and /var/lib/docker-libres3/etc/ssl/keys/libres3.key.

## HOW TO ADD/REMOVE USERS AND SET QUOTAS

See Skylable SX documentation: http://www.skylable.com/manuals/sx/manual.html

## HOW TO UPGRADE YOUR LIBRES3 CONTAINERS

   docker pull skylable/libres3
   docker stop libres3
   docker rm libres3
   docker start libres3

## MORE INFO

Visit http://www.skylable.com/products/libres3 to learn more about SX and LibreS3.

LibreS3 manual: http://www.skylable.com/products/libres3/manual.pdf

