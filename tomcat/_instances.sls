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
            attrs.append(dict(source_hash=instance.get('source_hash')))

        state_id = 'tomcat_{0}_archive'.format(i_name)
        config[state_id] = _gen_state('archive', 'extracted', attrs)

        # State tomcat archive link current
        archive_dir = instance.get('archive_dir', 'apache-tomcat-{0}'.format(instance.get('version')))
        attrs = [
            {'name': '{0}/cur'.format(instance_dir)},
            {'target': '{0}/{1}'.format(instance_dir, instance.get('cur_version'))},
            {'user': instance_default_user},
            {'group': instance_default_group},
            {'require': [
                {'archive': 'tomcat_{0}_archive'.format(i_name)},
                ]},
            ]

        state_id = 'tomcat_{0}_archive_link_current'.format(i_name)
        config[state_id] = _gen_state('file', 'symlink', attrs)

        for v_id, version in instance.get('versions', {}).iteritems():
            # State tomcat archive link version
            archive_dir = version.get('archive_dir', 'apache-tomcat-{0}'.format(version.get('version')))
            attrs = [
                {'name': '{0}/{1}'.format(instance_dir, version.get('version'))},
                {'target': '{0}/{1}'.format(instance_dir, archive_dir)},
                {'user': instance_default_user},
                {'group': instance_default_group},
                {'require': [
                    {'archive': 'tomcat_{0}_archive'.format(i_name)},
                    ]},
                ]

            state_id = 'tomcat_{0}_archive_link_{1}'.format(i_name, v_id)
            config[state_id] = _gen_state('file', 'symlink', attrs)

            # State tomcat filess
            if 'files' in version:
                for files_name in version['files'].get('manage'):
                    files_default_attrs = datamap['files'].get(files_name, {})
                    files_attrs = version['files'].get(files_name, {})

                    path = files_attrs.get('path', files_default_attrs.get('path', None))

                    if not path:
                        path = '{0}/{1}/{2}'.format(instance_dir,
                                                    version.get('version'),
                                                    files_attrs.get('relative_path',
                                                                    files_default_attrs.get('relative_path')))
                    # TODO listen service
                    context = version
                    context['i_name'] = i_name
                    context['id'] = instance_id
                    attrs = [
                        {'name': path},
                        {'user': instance_default_user},
                        {'group': instance_default_group},
                        {'mode': files_attrs.get('mode', files_default_attrs.get('mode', 640))},
                        {'context': context},
                        {'template': 'jinja'},
                        {'require': [
                            {'archive': 'tomcat_{0}_archive'.format(i_name)},
                            ]},
                        ]

                    contents = files_attrs.get('contents', False)
                    if contents:
                        attrs.append(dict(
                            contents_pillar='tomcat:lookup:instances:{0}:'
                                            'versions:{1}:files:{2}:contents'.format(i_name, v_id, files_name)))
                    else:
                        attrs.append(dict(source=files_attrs.get('template_path',
                                                                 'salt://{0}/files/{1}'.format(__formula__,
                                                                                               files_name))))

                    state_id = 'tomcat_{0}_files_{1}'.format(i_name, files_name)
                    config[state_id] = _gen_state('file', files_attrs.get('ensure', 'managed'), attrs)

    return config
