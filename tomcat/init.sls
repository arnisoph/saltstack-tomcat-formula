#!py
# -*- coding: utf-8 -*-
# vim: ts=4 sw=4 et

__formula__ = 'tomcat'


def run():
    config = {}
    datamap = __salt__['formhelper.get_defaults'](__formula__, __env__, ['yaml'])['yaml']

    # SLS includes/ excludes
    config['include'] = datamap.get('sls_include', ['._prepare', '._instances', '._webapps', '._cleanup'])
    config['extend'] = datamap.get('sls_extend', {})

    return config
