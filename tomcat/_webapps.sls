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

        for w_id, webapp in instance.get('webapps', {}).iteritems():
            if not webapp.get('manage', False):
                continue

            webapps_root = webapp.get(instance_default_user,
                                      '{0}/{1}/webapps'.format(instance_dir, instance.get('version')))
            webapp_root = webapp.get(instance_default_group, '{0}/{1}'.format(webapps_root, webapp.get('alias', w_id)))
            webapp_name = webapp.get('name', webapp.get('alias', w_id))

            if webapp.get('ensure', 'present') == 'absent':
                # State webapp dir
                attrs = [
                    {'name': webapp_root},
                    {'user': instance_default_user},
                    {'group': instance_default_group},
                    {'mode': 750},
                    {'require': [
                        {'file': 'tomcat_{0}_archive_link'.format(i_name)},
                        ]},
                    {'require_in': [
                        {'file': 'tomcat_{0}_dirperms'.format(i_name)},
                        ]},
                    ]

                state_id = 'tomcat_{0}_webapp_{1}_dir'.format(i_name, w_id)
                config[state_id] = _gen_state('file', webapp.get('ensure'), attrs)

            if 'war' in webapp:
                deployment_type = webapp['war'].get('deployment_type', 'manager')
                war_file = '{0}/{1}'.format(webapps_root, webapp['war'].get('name', '{0}.war'.format(webapp_name)))
                war_source = webapp['war'].get('source')

                if deployment_type == 'simple':
                    # State webapp war file
                    attrs = [
                        {'name': war_file},
                        {'source': war_source},
                        {'user': instance_default_user},
                        {'group': instance_default_group},
                        {'mode': 644},
                        {'require': [
                            {'file': 'tomcat_{0}_archive_link'.format(i_name)},
                            ]},
                        {'require_in': [
                            {'file': 'tomcat_{0}_dirperms'.format(i_name)},
                            ]},
                        ]

                    if 'source_hash' in webapp['war']:
                        attrs.append({'source_hash': webapp['war'].get('source_hash')})

                    state_id = 'tomcat_{0}_webapp_{1}_war'.format(i_name, w_id)
                    config[state_id] = _gen_state('file', webapp.get('ensure', 'managed'), attrs)

                elif deployment_type == 'manager':
                    # State webapp war tomcat deployment
                    context_path = webapp['war'].get('context', '/{0}'.format(webapp_name))
                    attrs = [
                        {'name': context_path},
                        {'war': war_source},
                        {'url': webapp['war'].get('manager_url',
                                                  'http://127.0.0.1:{0}8080/manager'.format(instance_id))},
                        {'timeout': webapp['war'].get('manager_timeout', 180)},
                        {'require': [
                            {'file': 'tomcat_{0}_archive_link'.format(i_name)},
                            ]},
                        {'require_in': [
                            {'file': 'tomcat_{0}_dirperms'.format(i_name)},
                            ]},
                        ]

                    state_id = 'tomcat_{0}_webapp_{1}_war_manager_deploy'.format(i_name, w_id)
                    config[state_id] = _gen_state('tomcat', webapp.get('ensure', 'war_deployed'), attrs)

    return config
