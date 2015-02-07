#!py
# -*- coding: utf-8 -*-
# vim: ts=4 sw=4 et

__formula__ = 'tomcat'


def run():
    config = {}
    datamap = __salt__['formhelper.get_defaults'](__formula__, __env__, ['yaml'])['yaml']

    _gen_state = __salt__['formhelper.generate_state']
    instance_default_user = datamap['instance_defaults'].get('user', 'tomcat')
    instance_default_group = datamap['instance_defaults'].get('group', 'tomcat')

    for i_name, instance in datamap.get('instances', {}).iteritems():
        instance_dir = instance.get('basedir', '{0}/{1}'.format(datamap['instance_defaults'].get('basedir'), i_name))
        instance_id = instance.get('id')

        # State instance directory
        attrs = [
            {'name': instance_dir},
            {'source': instance.get('source')},
            {'keep': instance.get('archive_cache', True)},
            {'archive_format': instance.get('archive_format', 'tar')},
            ]

        if 'source_hash' in instance:
            attrs.append({'source_hash': instance.get('source_hash')})

        state_id = 'tomcat_{0}_archive'.format(i_name)
        config[state_id] = _gen_state('archive', 'extracted', attrs)

        # State tomcat archive link
        archive_dir = instance.get('archive_dir', 'apache-tomcat-{0}'.format(instance.get('version')))
        attrs = [
            {'name': '{0}/{1}'.format(instance_dir, instance.get('version'))},
            {'target': '{0}/{1}'.format(instance_dir, archive_dir)},
            {'user': instance_default_user},
            {'group': instance_default_group},
            {'require': [
                {'archive': 'tomcat_{0}_archive'.format(i_name)},
                ]},
            ]

        state_id = 'tomcat_{0}_archive_link'.format(i_name)
        config[state_id] = _gen_state('file', 'symlink', attrs)

    return config
