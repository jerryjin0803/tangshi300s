@echo off
setlocal enabledelayedexpansion
set "str=%~dp0"
call :test "%str%"
if "%cstr%" NEQ "" (goto :ch) else (echo ��Ϸ���������Եȡ�����)

start %~dp0\runtime\win32\simulator.exe -workdir %~dp0 -console no 
goto :eof

:ch
@echo ��--------------------------------------------��
@echo ��                                            ��  
@echo ��      ��Cocosģ��������֧������·����       �� 
@echo ��    ����Ѵ��ļ��У��Ƶ���Ŀ¼�£�������    ��
@echo ��                                            ��
@echo ��--------------------------------------------��
@echo   ��ǰ·����%~dp0
pause>nul

:test
set "var=%~1"
for /l %%i in (0 1 255) do (
   set "var_=!var:~%%i,1!"
   if "!var_!"=="" goto :eof
   if !var_! gtr Z set cstr=!cstr!!var_!
)
