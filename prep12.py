#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import os.path
import shutil
from pathlib import Path
from processing_ng import __version__ as main_ver

CWD = os.getcwd()
dst_1 = os.path.join(CWD, 'dist')
dst_3 = os.path.join(CWD, 'dist', 'log')

# dst_4 = os.path.join(CWD, 'dist', 'BAT для Выгрузки по колонке из XLSX-файла')
# os.makedirs(dst_4)

if not os.path.exists(dst_3):
    os.makedirs(dst_3)

files1 = ['config.conf', 'LICENSE.rst', 'AUTHORS.rst', 'README.rst']

f1 = [shutil.copy(j, dst_1) for j in files1]

dbl = """rem =========================
rem --save_empty --write_count --save_filenames --log

rem a_read k138_22_read mdr

rem pvd79_serov
rem pvd138_krasnoufimsk
rem pvd144_ntagil
rem pvd161_ekb

"""

dbl2 = """rem =========================
rem a_read
rem k138_22_read
"""

fexe = 'processing_ng.exe'

cfg_prefix = '''echo off
set ORACLE_HOME=C:\instantclient_12_1
set TNS_ADMIN=C:\instantclient_12_1
set NLS_LANG=RUSSIAN_RUSSIA.CL8MSWIN1251
set tt=C:\instantclient_12_1;%PATH%
set PATH=%tt%
set tt=
echo on
'''

bat = {\
    '_выгрузка - простая - ais.bat':      ' -a unload -t simple -s UNLOAD --save_empty --write_count --save_filenames --db a_read',
    '_выгрузка - простая - mdr.bat':      ' -a unload -t simple -s UNLOAD --save_empty --write_count --save_filenames --db mdr',
    '_выгрузка - простая - k138_22.bat':  ' -a unload -t simple -s UNLOAD --save_empty --write_count --save_filenames --db k138_22_read',
    
    '_выгрузка - по десяткам - k138_22.bat':   ' -a unload -t parametric -s UNLOAD_T --save_empty --write_count --save_filenames --db k138_22_read',
    '_выгрузка - по районам - k138_22.bat':   ' -a unload -t parametric -s UNLOAD_D --save_empty --write_count --save_filenames --db k138_22_read',
    '_выгрузка - по блокам - k138_22.bat':   ' -a unload -t parametric -s UNLOAD_B --save_empty --write_count --save_filenames --db k138_22_read',
    
    '_выгрузка - по всем ПВД.bat':                ' -a unload -t allpvd -s UNLOAD --save_empty --write_count --save_filenames --log',
    
    '_XLSX - склеить.bat':                        ' -a xlsx -t join -s JOIN --write_count',
    
    '_XLSX - разделить - по количеству строк.bat':  ' -a xlsx -t split_rowcount -s SPLIT',
    '_XLSX - разделить - по маске.bat':             ' -a xlsx -t split_mask -s SPLIT',
    
    '_XLSX - сцепить 2 файла.bat':                ' -a xlsx -t compare -s COMPARE --log',
    
    '_SQL - сделать скрипты - по периоду - даты в именах.bat': ' -a sql -t tpl_date_in_filename -s SQL',
    '_SQL - сделать скрипты - по периоду.bat':                 ' -a sql -t tpl_date -s SQL',
    '_SQL - сделать скрипты - по районам.bat':                 ' -a sql -t tpl_raion -s SQL',
    '_SQL - сделать скрипты - по списку из CSV.bat':           ' -a sql -t list -s SQL',
    
    '_копировать файлы (local).bat':      ' -a send_files -t local -s SEND_LOCAL --log',
    '_копировать файлы (ftp).bat':        ' -a send_files -t ftp -s SEND_FTP --log',
    
    '_из нового Ехеля в старый Ехель.bat':     ' -a conv -t xlsx2xls -s CONV --write_count'
}
    
# 'BAT для Выгрузки по колонке из XLSX-файла/_r ИНФА ПО ЗАЯВКЕ по заявке.bat': ' -a unload -t by_xlsx_col -s req_infa',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r ИНФА ПО ЗАЯВКЕ - MIN по заявке.bat': ' -a unload -t by_xlsx_col -s req_infa_min',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r ДОКИ - ПРИЛОЖЕННЫЕ по заявке.bat': ' -a unload -t by_xlsx_col -s req_pril_doc',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r ДОКИ - ИСХОДЯЩИЕ по заявке.bat': ' -a unload -t by_xlsx_col -s req_out_doc',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r ЗАЯВИТЕЛЬ по заявке.bat': ' -a unload -t by_xlsx_col -s req_declarant',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r РЕШЕНИЯ - ВСЕ по заявке.bat': ' -a unload -t by_xlsx_col -s req_resh_all',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r РЕШЕНИЯ - ПОСЛЕДНЕЕ по заявке.bat': ' -a unload -t by_xlsx_col -s req_resh_last',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r ТЕКСТ РЕШЕНИЯ по номеру решения.bat': ' -a unload -t by_xlsx_col -s req_resh_text',
# 'BAT для Выгрузки по колонке из XLSX-файла/_r ДОП по заявке.bat': ' -a unload -t by_xlsx_col -s req_dop',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ИНФА ПО ОН - MIN по кн.bat': ' -a unload -t by_xlsx_col -s obj_info_min',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ИНФА ПО ОН - MAX по кн.bat': ' -a unload -t by_xlsx_col -s obj_info_max',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o АДРЕС КЛАДР по кн.bat': ' -a unload -t by_xlsx_col -s obj_addr_kladr',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ПРАВА по кн.bat': ' -a unload -t by_xlsx_col -s obj_rights',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ПРАВА И ОБРЕМЕНЕНИЯ по кн.bat': ' -a unload -t by_xlsx_col -s obj_rights_encums',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ОН - СПИСОК по заявке.bat': ' -a unload -t by_xlsx_col -s obj_by_req_lst',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ОН - СПИСОК - МКД по заявке.bat': ' -a unload -t by_xlsx_col -s obj_by_req_lst_mkd',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ОН - КОЛ-ВО по заявке.bat': ' -a unload -t by_xlsx_col -s obj_by_req_cnt',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o ЗУ по номеру квартала.bat': ' -a unload -t by_xlsx_col -s obj_zu_by_kk',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o СВЯЗЬ - по ОКС найти ЗУ.bat': ' -a unload -t by_xlsx_col -s obj_zu_by_oks',
# 'BAT для Выгрузки по колонке из XLSX-файла/_o СВЯЗЬ - по ЗУ найти ОКС.bat': ' -a unload -t by_xlsx_col -s obj_oks_by_zu'
    # }

for i in bat.keys():
    f = open(os.path.join(dst_1, i), 'w').write(''.join([cfg_prefix, fexe, bat[i], '\npause\n', dbl]))


