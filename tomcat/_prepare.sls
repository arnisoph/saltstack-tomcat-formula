#!py
# -*- coding: utf-8 -*-
# vim: ts=4 sw=4 et

__formula__ = 'tomcat'


def run():
    config = {}
    datamap = __salt__['formhelper.get_defaults'](__formula__, __env__, ['yaml'])['yaml']

    _gen_state = __salt__['formhelper.generate_state']
    instance_default_user = datamap['instance_defaults'].get('user')
    instance_default_group = datamap['instance_defaults'].get('group')

    # State tomcat base directory
    attrs = [
        {'name': datamap['instance_defaults'].get('basedir')},
        {'mode': 755},
        {'user': instance_default_user},
        {'group': instance_default_group},
        {'makedirs': True},
        ]

    config['tomcat_base_dir'] = _gen_state('file', 'directory', attrs)

    return config
