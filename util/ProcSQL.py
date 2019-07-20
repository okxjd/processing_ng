#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import csv
import logging
from pathlib import Path
import datetime
import shutil
import tempfile
from Base import TPL_FORMAT2
from Base import TPL_FORMAT_BL

logger = logging.getLogger('xxx')

def SQL_by_tpl_date_filename(arg=None, cfg=None):
    logger.info('SQL by template: dstart, dstop (the dates are in filename)')
    tpl = Path(str(cfg[str(arg.section)]['source']))
    res = Path(str(cfg[str(arg.section)]['destination']))
    if not res.exists():
        res.mkdir(parents=True)
    CWD = Path.cwd()
    date_formats = { 'YYYY-MM-DD HH24:MI:SS': '%Y-%m-%d %H:%M:%S', 'DD-MM-YYYY HH24:MI:SS': '%d-%m-%Y %H:%M:%S' }
    dt = (str(cfg[str(arg.section)]['dstart']), str(cfg[str(arg.section)]['dstop']), str(cfg[str(arg.section)]['dformat']))
    dt0 = datetime.datetime.strptime(dt[0], date_formats[dt[2]]).strftime('%Y-%m-%d')
    dt1 = datetime.datetime.strptime(dt[1], date_formats[dt[2]]).strftime('%Y-%m-%d')
    req_suffix_day = '__'.join(sorted(set([dt0,dt1])))
    os.chdir(str(tpl))
    a = [i for i in os.walk('.') if [j for j in i[2] if 'sql' in j.lower()]]
    d = {}
    for i in a:
        d[i[0]] = i[2]
    os.chdir(str(CWD))
    sr = Path(str(cfg[arg.section]['saved_filenames']))
    if arg.save_filenames is True and not sr.is_dir():
        ftemp = sr.open('w')
    else:
        ftemp = tempfile.TemporaryFile('w')
    for i in d:
        for j in d[i]:
            if 'sql' in j:
                p = tpl.joinpath(i[2:], j)
                tmp = p.open(mode='r').read().format(dstart=dt[0], dstop=dt[1], dformat=dt[2])
                if not res.joinpath(i[2:]).exists():
                    res.joinpath(i[2:]).mkdir(parents=True)
                    logger.info('{0}'.format(str(res)))
                res_file = res.joinpath(i[2:], ''.join([Path(Path(j).name).stem, ' (', req_suffix_day, ')', '.sql']))
                res_file.touch(exist_ok=True)
                logger.info('{0}'.format(str(res_file)))
                with res_file.open(mode='w') as rr:
                    rr.write(tmp)
                ftemp.write(str(res_file)+'\n')
    ftemp.close()
    return True

def SQL_by_tpl_date_no_filename(arg=None, cfg=None):
    logger.info('SQL by template: dstart, dstop (the dates are NOT in filename)')
    tpl = Path(str(cfg[str(arg.section)]['source']))
    res = Path(str(cfg[str(arg.section)]['destination']))
    if not res.exists():
        res.mkdir(parents=True)
    CWD = Path.cwd()
    date_formats = { 'YYYY-MM-DD HH24:MI:SS': '%Y-%m-%d %H:%M:%S', 'DD-MM-YYYY HH24:MI:SS': '%d-%m-%Y %H:%M:%S' }
    dt = (str(cfg[str(arg.section)]['dstart']), str(cfg[str(arg.section)]['dstop']), str(cfg[str(arg.section)]['dformat']))
    dt0 = datetime.datetime.strptime(dt[0], date_formats[dt[2]]).strftime('%Y-%m-%d')
    dt1 = datetime.datetime.strptime(dt[1], date_formats[dt[2]]).strftime('%Y-%m-%d')
    req_suffix_day = '__'.join(sorted(set([dt0,dt1])))
    os.chdir(str(tpl))
    a = [i for i in os.walk('.') if [j for j in i[2] if 'sql' in j.lower()]]
    d = {}
    for i in a:
        d[i[0]] = i[2]
    os.chdir(str(CWD))
    sr = Path(str(cfg[arg.section]['saved_filenames']))
    if arg.save_filenames is True and not sr.is_dir():
        ftemp = sr.open('w')
    else:
        ftemp = tempfile.TemporaryFile('w')
    for i in d:
        for j in d[i]:
            p = tpl.joinpath(i[2:], j)
            logger.info('{0}'.format(str(p)))
            tmp = p.open(mode='r').read().format(dstart=dt[0], dstop=dt[1], dformat=dt[2])
            s = res.joinpath(i[2:])
            if not s.exists():
                s.mkdir(parents=True)
                logger.info('{0}'.format(str(s)))
            res_file = s.joinpath(Path(j).name)
            res_file.touch(exist_ok=True)
            with res_file.open(mode='w') as rr:
                rr.write(tmp)
            ftemp.write(str(res_file)+'\n')
    ftemp.close()
    return True

def SQL_by_tpl_raion(arg=None, cfg=None):
    logger.info('SQL by template: raion')
    file_dir   = Path(str(cfg[str(arg.section)]['source']))
    result_dir = Path(str(cfg[str(arg.section)]['destination']))
    sql_list  = list(file_dir.glob('**/*.sql'))
    if not result_dir.exists():
        result_dir.mkdir(parents=True)
    sr = Path(str(cfg[arg.section]['saved_filenames']))
    if arg.save_filenames is True and not sr.is_dir():
        ftemp = sr.open('w')
    else:
        ftemp = tempfile.TemporaryFile('w')
    for s in sql_list:
        f = open(str(s), 'r').read()
        for z in TPL_FORMAT2:
            result_file = str(Path(result_dir).joinpath(''.join([Path(Path(s).name).stem, '_', z.replace(':', '_'), '.sql'])))
            with open(result_file, 'w') as fn:
                fn.write(f.format(z))
            ftemp.write(result_file+'\n')
    ftemp.close()
    return True
    
def SQL_by_tpl_block(arg=None, cfg=None):
    logger.info('SQL by template: block')
    file_dir   = Path(str(cfg[str(arg.section)]['source']))
    result_dir = Path(str(cfg[str(arg.section)]['destination']))
    sql_list  = list(file_dir.glob('**/*.sql'))
    if not result_dir.exists():
        result_dir.mkdir(parents=True)
    sr = Path(str(cfg[arg.section]['saved_filenames']))
    if arg.save_filenames is True and not sr.is_dir():
        ftemp = sr.open('w')
    else:
        ftemp = tempfile.TemporaryFile('w')
    for s in sql_list:
        f = open(str(s), 'r').read()
        for z in TPL_FORMAT_BL:
            result_file = str(Path(result_dir).joinpath(''.join([Path(Path(s).name).stem, '_', z.replace(':', '_'), '.sql'])))
            with open(result_file, 'w') as fn:
                fn.write(f.format(z))
            ftemp.write(result_file+'\n')
    ftemp.close()
    return True

def SQL_by_list(arg=None, cfg=None):
    logger.info('SQL by list')
    file_dir    = Path(str(cfg[str(arg.section)]['source']))
    result_dir  = Path(str(cfg[str(arg.section)]['destination']))
    tmp_dir     = Path(str(cfg[str(arg.section)]['tmp_dir']))
    sql_list    = list(file_dir.glob('**/*.sql'))
    csv_list    = list(file_dir.glob('**/*.csv'))
    if not result_dir.exists():
        result_dir.mkdir(parents=True)
    if tmp_dir.exists():
        shutil.rmtree(str(tmp_dir))
    tmp_dir.mkdir(parents=True)
    sr = Path(str(cfg[arg.section]['saved_filenames']))
    if arg.save_filenames is True and not sr.is_dir():
        ftemp = sr.open('w')
    else:
        ftemp = tempfile.TemporaryFile('w')
    for c in csv_list:
        with open(str(c), 'r', newline='') as file_csv:
            content_csv = csv.reader(file_csv, delimiter=';', lineterminator='\r\n')
            cnt = 0
            fc = 0
            wb_name = str(Path(tmp_dir).joinpath(''.join([Path(Path(c).name).stem, '_', str(fc).zfill(3), '.csv'])))
            csv_res_file = open(wb_name, 'w', newline='')
            csv_res_iter = csv.writer(csv_res_file, delimiter=';', lineterminator='\r\n')
            for row in content_csv:
                if cnt < 900:
                    csv_res_iter.writerow(row)
                    cnt += 1
                else:
                    csv_res_file.close()
                    fc += 1
                    cnt = 1
                    wb_name = str(Path(tmp_dir).joinpath(''.join([Path(Path(c).name).stem, '_', str(fc).zfill(3), '.csv'])))
                    csv_res_file = open(wb_name, 'w', newline='')
                    csv_res_iter = csv.writer(csv_res_file, delimiter=';', lineterminator='\r\n')
                    csv_res_iter.writerow(row)
            csv_res_file.close()
    tmp_list = list(tmp_dir.glob('**/*.csv'))
    if tmp_list:
        for s in sql_list:
            f = open(str(s), 'r').read()
            for t in tmp_list:
                res_sql = str(Path(result_dir).joinpath(''.join([Path(Path(t).name).stem, '.sql'])))
                with open(res_sql, 'w') as w_file:
                    logger.info('{0}'.format(''.join([Path(Path(t).name).stem, '.sql'])))
                    with open(str(t), 'r', newline='') as r_file_kn:
                        rd = csv.reader(r_file_kn, delimiter=';', lineterminator='\r\n')
                        q = ',\n'.join(["'"+str(x[0])+"'" for x in rd])
                        w_file.write(f.format(q))
                ftemp.write(res_sql+'\n')
    ftemp.close()
    shutil.rmtree(str(tmp_dir))
    return True

def ProcSQL(arg=None, cfg=None):
    if arg and cfg:
        subtypes = {\
                'tpl_date_in_filename'   : SQL_by_tpl_date_filename,
                'tpl_date'               : SQL_by_tpl_date_no_filename,
                'tpl_raion'              : SQL_by_tpl_raion,
                'tpl_block'              : SQL_by_tpl_block,
                'list'                   : SQL_by_list
                }
        subtypes[arg.type](arg, cfg)
        logger.info('END\n-----------\n\n')
        return True
    else:
        return False

if __name__ == '__main__':
    pass
