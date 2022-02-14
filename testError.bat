@echo off
java -version
IF %ERRORLEVEL% 0 (
  ECHO error - %ERRORLEVEL%
echo "Error level is",%ERRORLEVEL%
exit
)
