cls
echo off
set ORACLE_HOME=C:\instantclient_12_1
set TNS_ADMIN=C:\instantclient_12_1
set NLS_LANG=RUSSIAN_RUSSIA.CL8MSWIN1251
set tt=C:\instantclient_12_1;%PATH%
set PATH=%tt%
set tt=
echo on

C:\python\python -m compileall .
C:\python\python -m py2exe.build_exe -c -b 1 -OO -i ctypes -i gzip processing_ng.py
C:\python\python prep12.py

pause
rem move dist dist_ora12
