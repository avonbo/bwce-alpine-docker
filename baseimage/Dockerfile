FROM alpine:3.5
MAINTAINER Alexander von Boguszewski <avonbogu@tibco.com>

# BWCE Environment Configuration
	ENV TIBCO_HOME=/opt/tibco \
	APPDIR=/opt/tibco \
	JAVA_HOME=/opt/tibco/tibco.home/tibcojre64/1.8.0 \
 	MALLOC_ARENA_MAX=2 \
	MALLOC_MMAP_THRESHOLD_=1024 \
	MALLOC_TRIM_THRESHOLD_=1024 \
	MALLOC_MMAP_MAX_=65536 \
	MEMORY_LIMIT=512M \
	BW_LOGLEVEL=info

# Create Tibco Binary Folder
RUN mkdir -p ${TIBCO_HOME} && \
	mkdir -p ${APPDIR} 

# Download and install bash
RUN apk add --update bash 

# Download and install glibc, little bit hacky
ENV GLIBC_VERSION 2.23-r3

RUN apk add --update curl && \
  curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
  curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
  rm -rf glibc.apk glibc-bin.apk 
  

# Copy BWCE Files to Image
COPY "bwce-runtime  java-code  scripts resources" /tmp/

#add tibco user
RUN addgroup tibco && \
	adduser -S -H tibco tibco && \	
	chown  tibco ${TIBCO_HOME} && \
	chown  tibco ${APPDIR} && \
	chmod 755 /tmp/*.sh

USER tibco
#WORKDIR /home/tibco

# Configure BWCE Installation
RUN  /tmp/install.sh


USER root

# cleanup
#RUN apk del curl && \
#    rm -rf /var/cache/* && \
#    rm -rf /tmp/* 
# remove vi
# remove netcat
# remove wget
# remove telnet

ENTRYPOINT ["/opt/tibco/scripts/start.sh"]