# LICENSE UPL 1.0
#
# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This Dockerfile extends the Oracle WebLogic image built under 12213-doma-home-in-image.
#
# It will deploy any package defined in APP_PKG_FILE.
# into the DOMAIN_HOME with name defined in APP_NAME
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Run:
#      $ docker build --build-arg APPLICATION_NAME=sample -t ejada-img-app .
#

# Pull base image
# ---------------
FROM ejadagb/ejada-weblogic-domain:12.2.1.3-developer

# Maintainer
# ----------
MAINTAINER Mohammed Helmy Halawa <mhalawa@ejada.com>

ARG APPLICATION_NAME="${APPLICATION_NAME:-sample}"

# Define variables
ENV APP_NAME="${APPLICATION_NAME}" \
    APP_FILE="${APPLICATION_NAME}.war"  

# Copy files and deploy application in WLST Offline mode
COPY container-scripts/* /u01/oracle/
COPY $APP_FILE /u01/oracle/

# Deploy Application
RUN wlst.sh -skipWLSModuleScanning /u01/oracle/app-deploy.py
    
# Define default command to start bash.
CMD ["startAdminServer.sh"]

# Copy files and deploy application in WLST Offline mode
COPY container-scripts/* /u01/oracle/

RUN wlst -loadProperties /u01/oracle/datasource.properties /u01/oracle/ds-deploy.py && \
    wlst /u01/oracle/jms-deploy.py