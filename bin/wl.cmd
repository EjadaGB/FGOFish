@echo off
echo commamd line parameters are [%*]
for /f "tokens=1-10* delims= " %%A in ("%*") do (
	set directory=%%A
	set dbcontainer=%%B
	set dbpwdadmin=%%C
	set dbuser=%%D
	set dbpwd=%%E
	set dump=%%F
	set databaseip=%%G
	set dbport=%%H
	set dbsid=%%I
	set ds=%%J
	set appname=%%K
)

set dbuseradmin=system
set wlpwd=zSC4A4ck5S0tRpK8MpeI

docker exec -i -t -w /tmp %dbcontainer% /bin/bash -c "sqlplus %dbuseradmin%/%dbpwdadmin% @/opt/oracle/oradata/scripts/directory.sql"
(
echo ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
echo CREATE TABLESPACE TS_%dbuser%_DATA DATAFILE 'TS_%dbuser%_DATA.dbf' SIZE 200m reuse;
echo CREATE TABLESPACE TS_%dbuser%_INDX DATAFILE 'TS_%dbuser%_INDX.dbf' SIZE 200m reuse;
echo CREATE USER %dbuser% IDENTIFIED BY %dbpwd% DEFAULT TABLESPACE TS_%dbuser%_DATA TEMPORARY TABLESPACE "TEMP";
echo ALTER USER %dbuser% QUOTA UNLIMITED ON TS_%dbuser%_DATA;
echo ALTER USER %dbuser% QUOTA UNLIMITED ON TS_%dbuser%_INDX;
echo GRANT "CONNECT" TO %dbuser% ;
echo GRANT "RESOURCE" TO %dbuser% ;
echo GRANT CREATE JOB TO %dbuser% ;
echo GRANT CREATE TRIGGER TO %dbuser% ;
echo GRANT CREATE MATERIALIZED VIEW TO %dbuser% ;
echo GRANT CREATE VIEW TO %dbuser% ;
echo GRANT CREATE TABLE TO %dbuser% ;
echo GRANT CREATE SYNONYM TO %dbuser% ;
echo GRANT CREATE SEQUENCE TO %dbuser% ;
echo GRANT CREATE DATABASE LINK TO %dbuser% ;
echo GRANT CREATE PROCEDURE TO %dbuser% ;
echo exit
) > %directory%/oracle/oradata/scripts/createuser.sql

docker exec -i -t -w /tmp %dbcontainer% /bin/bash -c "sqlplus %dbuseradmin%/%dbpwdadmin% @/opt/oracle/oradata/scripts/createuser.sql"

MOVE %directory%\dump\%dump%.dmp "%directory%\oracle\oradata\backup\%dump%.dmp"

docker exec %dbcontainer% impdp %dbuseradmin%/%dbpwdadmin%@%dbsid% dumpfile=%dump%.dmp directory=bdir logfile=%dump%.log schemas=%dbuser%

(
echo dsname=FGO
echo dsdbname=%dbsid%
echo dsjndiname=%ds%
echo dsdriver=oracle.jdbc.OracleDriver
echo dsurl=jdbc:oracle:thin:@//%dbcontainer%:%dbport%/%dbsid%
echo dsusername=%dbuser%
echo dspassword=%dbpwd%
echo dstestquery=SQL ISVALID
echo dsmaxcapacity=1
)> %directory%/deploy/container-scripts/datasource.properties

(
echo username=weblogic
echo password=%wlpwd%
echo JAVA_OPTIONS=-Dweblogic.StdoutDebugEnabled=false
)> %directory%/deploy/container-scripts/security/security.properties

docker build --build-arg APPLICATION_NAME=%appname% -t ejada-img-app %directory%/deploy

docker run -d --name %appname% --hostname %appname% -p 7001:7001 -v %directory%/deploy/container-scripts/security:/u01/oracle/properties ejada-img-app

REM For Application Open Your Browser http://localhost:7001/%appname%
REM For Weblogic Open Your Browser http://localhost:7001/console
REM For Weblogic Open Your Browser https://localhost:5500/em

timeout /t 20
