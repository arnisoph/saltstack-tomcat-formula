#!py
# -*- coding: utf-8 -*-
# vim: ts=4 sw=4 et

__formula__ = 'tomcat'


def run():
    config = {}
    datamap = __salt__['formhelper.get_defaults'](__formula__, __env__)

    _gen_state = __salt__['formhelper.generate_state']
    instance_default_user = datamap['instance_defaults'].get('user')
    instance_default_group = datamap['instance_defaults'].get('group')

    for i_name, instance in datamap.get('instances', {}).iteritems():
        instance_dir = instance.get('basedir', '{0}/{1}'.format(datamap['instance_defaults'].get('basedir'), i_name))
        instance_id = instance.get('id')

        # State tomcat instance dir perms
        attrs = [
            {'name': instance_dir},
            {'user': instance_default_user},
            {'group': instance_default_group},
            {'mode': 755},
            {'recurse': ['user', 'group']},
            ]

        state_id = 'tomcat_{0}_dirperms'.format(i_name)
        config[state_id] = _gen_state('file', 'directory', attrs)

    return config
