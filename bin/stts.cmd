set container=%~1
:loop
docker inspect %container% --format '{{.State.Health.Status}}'
timeout /t 10
goto loop