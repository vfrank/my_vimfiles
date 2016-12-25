@echo off

if "%2" == "" (
   %0 %1 C:\.vim_tmp_start_file
   exit /b 1
)

cmd /c "vim" --serverlist > %2

if %~z2 == 0 (
   start gvim.exe %1
) else (
   start gvim.exe --remote-silent %1
)

del %2

