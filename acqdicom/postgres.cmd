@ECHO ON
REM The script sets environment variables helpful for PostgreSQL
@SET PATH="%~dp0\bin";%PATH%
@SET PGDATA=%~dp0\data
@SET PGDATABASE=postgres
@SET PGUSER=postgres
@SET PGPORT=5439
@SET PGLOCALEDIR=%~dp0\share\locale
if not exist "%~dp0\data" (
	mkdir "%~dp0\data" 
	 "%~dp0\bin\initdb" -D "%~dp0\data" -U postgres -A trust
)
"%~dp0\bin\pg_ctl" -D "%~dp0\data" -l logfile start
ECHO "Click enter to stop"
pause
"%~dp0\bin\pg_ctl" -D "%~dp0\data" stop