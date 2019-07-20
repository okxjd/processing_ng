#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pathlib import Path
import datetime
import xlwt3
import openpyxl
import tempfile
import logging

logger = logging.getLogger('xxx')

def string_none(x=None):
    if x is None:
        return ''
    else:
        return str(x)

def CONV_xlsx2xls(arg=None, cfg=None):
    logger.info('CONVERT: xlsx >> xls')
    file_dir   = Path(str(cfg[str(arg.section)]['source']))
    result_dir = Path(str(cfg[str(arg.section)]['destination']))
    xlsx_list  = list(file_dir.glob('**/*.xlsx'))
    if not result_dir.exists():
        result_dir.mkdir(parents=True)
    if xlsx_list:
        sr = Path(str(cfg[arg.section]['saved_filenames']))
        if arg.save_filenames is True and not sr.is_dir():
            ftemp = sr.open('w')
        else:
            ftemp = tempfile.TemporaryFile('w')
        logger.info(' > start - {0}'.format(datetime.datetime.now().strftime('%Y/%m/%d %H:%M:%S')))
        for i in xlsx_list:
            try:
                w_book = xlwt3.Workbook()
                sh = 0
                w_sheet = w_book.add_sheet('sheet_'+str(sh))
                r_book = openpyxl.load_workbook(str(i), read_only=True, use_iterators=True)
                r_sheet = r_book.active
                tmp_row = []
                cnt = 0
                count2= 0
                logger.info(str(i) + ' /' + str(sh))
                for rrr in r_sheet.rows:
                    if cnt > 60000:
                        sh = sh + 1
                        cnt = 0
                        w_sheet = w_book.add_sheet('sheet_'+str(sh))
                        logger.info(str(i) + ' /' + str(sh))
                    tmp_row = [string_none(i.value) for i in rrr]
                    for g in range(len(tmp_row)):
                        w_sheet.write(cnt, g, tmp_row[g])
                    cnt = cnt + 1
                    count2 = count2 + 1
                if arg.write_count:
                    w_book_name = str(Path(result_dir).joinpath(''.join([Path(Path(i).name).stem, '_C_s', str(sh), '_r', str(count2), '.xls'])))
                else:
                    w_book_name = str(Path(result_dir).joinpath(''.join([Path(Path(i).name).stem, '_C', '.xls'])))
                w_book.save(w_book_name)
                ftemp.write(w_book_name+'\n')
            except Exception as ee:
                logger.error("{0} - ERROR: {1}".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), ee))
                continue
        ftemp.close()
        logger.info(' > stop  - {0}'.format(datetime.datetime.now().strftime('%Y/%m/%d %H:%M:%S')))
        return True
    else:
        return False

def Convert(arg=None, cfg=None):
    if arg and cfg:
        subtypes = {\
                'xlsx2xls': CONV_xlsx2xls
                }

        subtypes[arg.type](arg, cfg)
        logger.info('END\n-----------\n\n')
        return True
    else:
        return False

if __name__ == '__main__':
    pass
