#!/bin/bash

dbPassword=${MSSQL_SA_PASSWORD}
#start SQL Server, start the script to create the DB and import the data
/opt/mssql/bin/sqlservr & /usr/src/db/setup.sh $dbPassword