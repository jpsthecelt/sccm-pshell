java -version
IF %ERRORLEVEL% EQU 9009 (
  ECHO error - SomeFile.exe not found in your PATH
echo %ERRORLEVEL%
)
echo %ERRORLEVEL%
