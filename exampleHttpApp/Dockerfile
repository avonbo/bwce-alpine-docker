FROM alpinebwcebase:latest
MAINTAINER Alexander von Boguszewski <avonbogu@tibco.com>


USER tibco

COPY *.ear /tmp

# Configure BWCE Application
RUN  ${TIBCO_HOME}/scripts/configuration.sh

EXPOSE 8080
EXPOSE 8090


