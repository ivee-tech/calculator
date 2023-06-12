ARG tag
FROM mcr.microsoft.com/mssql/server:${tag} 
# 2017-CU12-ubuntu

USER root

# Create db directory
RUN mkdir -p /usr/src/db
WORKDIR /usr/src/db

# Install ping that will be used to keep the container up
RUN apt-get update && apt-get install -y iputils-ping

COPY . .

# Grant permissions for the setup and entrypoint scripts to be executable
RUN chmod +x /usr/src/db/setup.sh
RUN chmod +x /usr/src/db/entrypoint.sh

# it doesnt' work on 2017-latest
# USER mssql
CMD ./entrypoint.sh
