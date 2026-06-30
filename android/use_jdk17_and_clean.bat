@echo off
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d %~dp0
echo Using JAVA_HOME=%JAVA_HOME%
java -version
javac -version 2>nul || echo javac not found
call .\gradlew.bat clean --no-daemon
