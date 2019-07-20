#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
import datetime
import argparse
import configparser
from pathlib import Path
import shutil
import tempfile
import ftplib

logger = logging.getLogger('xxx')

def CopyLocal(arg=None, cfg=None):
    logger.info("Copy Files from local to local")
    if arg and cfg:
        alias = cfg[str(arg.section)]

        src = Path(str(alias['source']))
        dest = Path(str(alias['destination']))
        
        if (not src.is_dir() and not src.is_file()):
            logger.error("ERROR: not found source file or catalog: '{0}'".format(str(src)))
            return False
        else:
            if src.is_dir():
                if dest.exists():
                    dest = dest.parent.joinpath(''.join([dest.parts[-1], '_', datetime.datetime.now().strftime('%j-%H%M%S-%f')]))
                try:
                    logger.info("FROM: {0}".format(str(src)))
                    logger.info("  TO: {0}".format(str(dest)))
                    shutil.copytree(str(src), str(dest), symlinks=True)
                    logger.info('OK')
                    logger.info('END\n-----------\n\n')
                    return True
                except Exception as ezz1:
                    logger.error("{0} - ERROR: {1}".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), ezz1))
                    return False
            elif src.is_file():
                if not dest.exists():
                    try:
                        dest.mkdir(parents=True)
                    except Exception as ezz1:
                        logger.error("{0} - ERROR: {1}".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), ezz1))
                        return False
                with src.open('r') as f:
                    file_list = [Path(i.strip()) for i in f.readlines() if Path(i.strip()).is_file()]
                    for_test_equal = [j.name for j in dest.glob('*.*') if dest.joinpath(j.name).exists()]
                    logger.info("  TO: {0}".format(str(dest)))
                    for i in file_list:
                        try:
                            if i.name in for_test_equal:
                                fff = i.with_name(i.stem + '_' + datetime.datetime.now().strftime('%j-%H%M%S-%f') + ''.join(i.suffixes))
                                shutil.copy(str(i), str(dest.joinpath(fff.name)))
                                logger.info(" > OK (RENAMED): {0}".format(fff.name))
                            else:
                                shutil.copy(str(i), str(dest))
                                logger.info(" > OK: {0}".format(str(i)))
                        except Exception as ezzz:
                            logger.error("{0} - ERROR: {1}".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), ezzz))
                            continue
                    logger.info('END\n-----------\n')
                return True
    else:
        return False
        
def CopyFTP(arg=None, cfg=None):
    logger.info("Copy Files from local to FTP")
    if arg and cfg:
        alias = cfg[str(arg.section)]
        src = Path(str(alias['source']))
        dest = str(alias['destination'])
        
        if not src.is_file():
            logger.error("ERROR: for FTP 'source' must be only 'file-list', not catalog!: '{0}'".format(str(src)))
            return False
        else:
            ftp = ftplib.FTP()
            try:
                ftp.encoding = alias['encoding']
                logger.info('Connect: {0}'.format(alias['host']))
                ftp.connect(alias['host'])
                ftp.login('ca', '12345')
                logger.info('OK')
                ftp.cwd(dest)
                for_test_equal = [Path(j.strip()).name for j in ftp.nlst()]
                
                with src.open('r') as f:
                    file_list = [Path(i.strip()) for i in f.readlines() if Path(i.strip()).is_file()]
                    logger.info("DEST: {0}".format(dest))
                    for i in file_list:
                        try:
                            if i.name in for_test_equal:
                                fff = i.with_name(i.stem + '_' + datetime.datetime.now().strftime('%j-%H%M%S-%f') + ''.join(i.suffixes))
                                ftp.storbinary("STOR " + fff.name, i.open('rb'))
                                logger.info(" > OK (RENAMED): {0}".format(fff.name))
                            else:
                                ftp.storbinary("STOR " + i.name, i.open('rb'))
                                logger.info(" > OK: {0}".format(str(i)))
                        except Exception as ezzz:
                            logger.error("{0} - ERROR: {1}".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), ezzz))
                            continue
            except ftplib.all_errors as err:
                logger.info('{0}'.format(err))
                return False
            finally:
                logger.info('Close connection')
                ftp.quit()
                logger.info('END\n-----------\n')
            return True
    else:
        return False

def SendFiles(arg=None, cfg=None):
    if arg and cfg:
        subtypes = {\
            'local': CopyLocal,
            'ftp': CopyFTP
            }
        subtypes[arg.type](arg, cfg)
        logger.info('END\n-----------\n\n')
        return True
    else:
        return False

if __name__ == '__main__':
    pass
