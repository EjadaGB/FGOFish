set container=%~1
set wlsport=%~2
set directory=%~3
docker start %container%
docker stop %container%
docker rm %container%
docker run -d --name %container% --hostname %container% -p %wlsport%:7001 -v %directory%/deploy/container-scripts/security:/u01/oracle/properties ejada-img-app

timeout /t 20