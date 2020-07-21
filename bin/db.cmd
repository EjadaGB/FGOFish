set directory=%~1
set gitpwd=%~2
set dokpwd=%~3
set dbpwdadmin=%~4
set appname=%~5
set dbcontainer=%~6
set dbport=%~7
set dbemport=%~8
set dbsid=%~9

docker stop database
docker rm database
docker stop %appname%
docker rm %appname%
docker rmi ejada-img-app

Rem git clone https://EjadaGB:%gitpwd%@github.com/EjadaGB/%appname%.git

docker login --username=ejadagb --password=%dokpwd%

docker pull ejadagb/ejada-database:12.1.0.2-ee

docker run --name %dbcontainer% --hostname %dbcontainer% -p %dbport%:1521 -p %dbemport%:5500 -e ORACLE_SID=%dbsid% -e ORACLE_PDB=ORCLPDB1 -e ORACLE_PWD=%dbpwdadmin% -e ORACLE_CHARACTERSET=AL32UTF8 -v %directory%/oracle/oradata:/opt/oracle/oradata ejadagb/ejada-database:12.1.0.2-ee
