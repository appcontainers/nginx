###########################################################
# Dockerfile to build nginx Service Base Container
# Based on: appcontainers/centos:7 (7.2)
# DATE: 12/7/2016
# COPYRIGHT: Appcontainers.com
###########################################################

# Set the base image in namespace/repo format. 
# To use repos that are not on the docker hub use the example.com/namespace/repo format.
FROM appcontainers/centos:7

# File Author / Maintainer
MAINTAINER Rich Nason rnason@appcontainers.com

###########################################################
#*********************  APP VERSIONS  *********************
###########################################################


###########################################################
#***********  OVERRIDE ENABLED ENV VARIABLES  *************
###########################################################

ENV TERMTAG nginx
ENV ENV dev
ENV SITE_NAME nginx.local

###########################################################
#**************  ADD REQUIRED APP FILES  ******************
###########################################################

ADD nginx.yml /etc/ansible/

###########################################################
#***************  UPDATES & PRE-REQS  *********************
###########################################################

# Clean, Update, and Install... then clear non English local data.
RUN yum clean all && \
yum -y update && \
pip install pip --upgrade && \

# Remove yum cache this bad boy can be 150MBish
yum clean all && \
rm -fr /var/cache/*

###########################################################
#***************  APPLICATION INSTALL  ********************
###########################################################

# We do all of our installs using ansible roles now
RUN ansible-galaxy install clusterfrak.nginx

# Install the role
RUN cd /etc/ansible && \
ls -lah && \
ansible-playbook nginx.yml

###########################################################
#**************  POST DEPLOY CLEAN UP  ********************
###########################################################

###########################################################
#*************  CONFIGURE START ITEMS  ********************
###########################################################

WORKDIR /etc/ansible/roles/clusterfrak.nginx/files
CMD /bin/bash -c "ansible-playbook nginx-reconfig.yml && service nginx stop && /usr/sbin/nginx -g 'daemon off;'"

###########################################################
#************  EXPOSE APPLICATION PORTS  ******************
###########################################################

# Expose ports to other containers only
EXPOSE 80
EXPOSE 443
EXPOSE 8080

###########################################################
#***************  OPTIONAL / LEGACY  **********************
###########################################################