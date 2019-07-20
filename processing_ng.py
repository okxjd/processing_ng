#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import os
import datetime
import argparse
import configparser
from configparser import ExtendedInterpolation
from pathlib import Path

logger = logging.getLogger('xxx')
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(levelname)s: %(message)s', datefmt='%Y-%m-%d %H/%M/%S')
logC = logging.StreamHandler()
logC.setLevel(logging.INFO)
logC.setFormatter(formatter)
logger.addHandler(logC)

try:
    from unload.Unload import Unloading
except ImportError:
    Unloading = lambda x: False

from util import Converter as C
from util import ProcSQL as S
from util import ProcXLSX as X
from util import SendFiles as SF

__version__ = '3.9.1'
__build_date__ = '18.02.2019'
__author__ = 'Valerii Malyshkin'
__author_email__ = 'site@okxjd.space'
__license__ = 'MIT/Expat'
__progname__='Processing NG'
__python_ver__='3.4.3'
__ora_lib_ver__='cx_Oracle-5.2.1'
__xlsx_lib1_ver__='openpyxl-2.1.4'
__xlsx_lib2_ver__='xlwt3-0.1.2'

def CmdArgsRead():
    try:
        parser = argparse.ArgumentParser(prog="processing_ng", formatter_class=argparse.RawDescriptionHelpFormatter, epilog='''Examples:
        processing_ng -a unload -t simple -s UNLOAD --save_empty --write_count --save_filenames --db k138_22_read
        processing_ng -a unload -t parametric -s UNLOAD_T --write_count --db k138_22_read --log
        processing_ng -a conv -t xlsx2xls -s CONV --write_count
        processing_ng -a xlsx -t split_mask -s SPLIT --config "cfg\custom_config.conf"
        processing_ng -a sql -t list -s SQL
        processing_ng -a send_files -t local -s SEND_LOCAL --log
        processing_ng -v
        processing_ng -h''', add_help=True)
        parser.add_argument('-a', '--action', required=True, help='- action to do')
        parser.add_argument('-t', '--type', required=True, help='- subtype of action')
        parser.add_argument('-s', '--section', required=True, help='- section from config-file')
        parser.add_argument('--db', help='- if you need to change db quickly - it\'s for it')
        parser.add_argument('--log', help='- save console output into file', action='store_true')
        parser.add_argument('--write_count', help='- write_count', action='store_true')
        parser.add_argument('--save_filenames', help='- save_filenames', action='store_true')
        parser.add_argument('--save_empty', help='- save_empty', action='store_true')
        parser.add_argument('-u', '--use_src_subfolders', help='- use_src_subfolders', action='store_true')
        parser.add_argument('--config', help='- custom config file, default is "config.conf".', default='config.conf')
        parser.add_argument('-v', '--version', action='version', version="""{0} {1} (build {4})
Developed by {2}
License: {3} (see LICENSE.rst)
Python: {5}
Used 3rd party packages: {6}, {7}, {8}
""".format(__progname__, __version__, __author__, __license__, __build_date__, __python_ver__, __ora_lib_ver__, __xlsx_lib1_ver__, __xlsx_lib2_ver__))
        t = parser.parse_args()
        return t
    except Exception as zz:
        logger.error("{0}: {1}\n".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), zz))
        return False

def LoadConfig(raw_cfg_path=None):
    if raw_cfg_path:
        cfg_path = str(raw_cfg_path)
        if Path(cfg_path).exists():
            cf = configparser.ConfigParser(delimiters='=', comment_prefixes='#', interpolation=ExtendedInterpolation())
            cfg_tmp = dict()
            try:
                cf.read(cfg_path)
                for i in cf.sections():
                    cfg_tmp[i] = dict(cf.items(i))
                return cfg_tmp
            except configparser.Error as zz:
                logger.error("{0} - ERROR: {1}\n".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), zz))
                return False
    else:
        return False
        
def AddFileLogger(config=None, arguments=None):
    if config and arguments:
        if arguments.type == 'by_xlsx_col':
            log_dir = Path(str(config['UNLOAD_ACTIONS_LIST']['log_dir']))
        else:
            log_dir = Path(str(config[arguments.section]['log_dir']))
        time_mark = datetime.datetime.now()
        if not log_dir.exists():
            try:
                log_dir.mkdir(parents=True)
            except OSError as zz:
                logger.error("{0}: {1}\n".format(time_mark.strftime('%d %b %Y %H:%M:%S'), zz))
                return False
        try:
            log_file = str(log_dir.joinpath(''.join(['log_', time_mark.strftime('%Y-%m-%d-%H%M'), ' (', arguments.action, '.', arguments.type, '.', arguments.section, ').log'])))
            logger.info('log-file: {0}\n'.format(log_file))
            logF = logging.FileHandler(log_file, 'w')
            logF.setLevel(logging.INFO)
            logF.setFormatter(formatter)
            logger.addHandler(logF)
            return True
        except Exception as zz:
            logger.error("{0}: {1}\n".format(time_mark.strftime('%d %b %Y %H:%M:%S'), zz))
            return False

def main():
    try:
        arguments = CmdArgsRead()
        if arguments:
            cfg_file = arguments.config
            cfg = LoadConfig(cfg_file)
            if cfg:
                if arguments.log is True:
                    AddFileLogger(cfg, arguments)
                tasks = {\
                    'unload': Unloading,
                    'xlsx': X.ProcXLSX,
                    'sql': S.ProcSQL,
                    'conv': C.Convert,
                    'send_files': SF.SendFiles
                    }
                tasks[arguments.action](arguments, cfg)
            else:
                return False
        else:
            return False
    except Exception as zz:
        logger.error("{0} - ERROR: {1}\n".format(datetime.datetime.now().strftime('%d %b %Y %H:%M:%S'), zz))
        return False



if __name__ == '__main__':
    os.system('cls')
    logger.info("{0} {1}".format(__progname__, __version__))
    logger.info('='*(len(__progname__+__version__)+1)+'\n')
    main()
