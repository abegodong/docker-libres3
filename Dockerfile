FROM centos:centos7
MAINTAINER Skylable Dev-Team <dev-team@skylable.com>

# Install deps
RUN yum clean all && \
    yum -y update && \
    yum -y install epel-release 

#COPY skylable.repo /etc/yum.repos.d/

RUN yum -y install ocaml ocaml-camlp4-devel ocaml-camlp4 \
    ocaml-compiler-libs ocaml-runtime pcre-devel openssl-devel make m4 \
    ncurses-devel git 
RUN git clone http://git.skylable.com/libres3 && \
    cd libres3/ && \
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
    make && make install 

COPY libres3.pem /etc/ssl/certs/
COPY libres3.key /etc/ssl/private/
COPY libres3.conf.template /etc/libres3/
COPY run.sh /

EXPOSE 8443 8008
CMD ["/run.sh"]
