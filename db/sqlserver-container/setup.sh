#!/bin/bash

#wait for the SQL Server to come up
sleep 30

#run the setup script to create the DB and the schema in the DB
dbPassword=$1 
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $dbPassword -d master -i setup.sql

#import the data from the csv file
# /opt/mssql-tools/bin/bcp CalculatorDB.dbo.OperationLogs in "/usr/src/db/OperationLogs.csv" -c -t',' -S localhost -U sa -P dbPassword

ping localhost
