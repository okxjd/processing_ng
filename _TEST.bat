cls
echo off
set ORACLE_HOME=C:\instantclient_12_1
set TNS_ADMIN=C:\instantclient_12_1
set NLS_LANG=RUSSIAN_RUSSIA.CL8MSWIN1251
set tt=C:\instantclient_12_1;%PATH%
set PATH=%tt%
set tt=
echo on

python processing_ng.py -a unload -t by_xlsx_col -s obj_addr_kladr --log

pause
