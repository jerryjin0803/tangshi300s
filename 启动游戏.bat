@echo off
setlocal enabledelayedexpansion
set "str=%~dp0"
call :test "%str%"
if "%cstr%" NEQ "" (goto :ch) else (echo 游戏启动，请稍等。。。)

start %~dp0\runtime\win32\simulator.exe -workdir %~dp0 -console no 
goto :eof

:ch
@echo ┏--------------------------------------------┓
@echo ┃                                            ┃  
@echo ┃      【Cocos模拟器】不支持中文路径！       ┃ 
@echo ┃    建议把此文件夹，移到根目录下，再运行    ┃
@echo ┃                                            ┃
@echo ┗--------------------------------------------┛
@echo   当前路径：%~dp0
pause>nul

:test
set "var=%~1"
for /l %%i in (0 1 255) do (
   set "var_=!var:~%%i,1!"
   if "!var_!"=="" goto :eof
   if !var_! gtr Z set cstr=!cstr!!var_!
)
