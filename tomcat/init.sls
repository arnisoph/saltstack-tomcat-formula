#!jinja|yaml

{% from 'tomcat/defaults.yaml' import rawmap_osfam with context %}
{% set datamap = salt['grains.filter_by'](rawmap_osfam, merge=salt['pillar.get']('tomcat:lookup')) %}

include: {{ datamap.sls_include|default([]) }}
extend: {{ datamap.sls_extend|default({}) }}

tomcat_base_dir:
  file:
    - directory
    - name: {{ datamap.instance.basedir }}
    - mode: 755
    - user: root
    - group: root
    - makedirs: True

{% for id, instance in salt['pillar.get']('tomcat:instances', {})|dictsort %}
  {% set instance_dir = instance.basedir|default(datamap.instance.basedir) ~ '/' ~ id %}

tomcat_{{ id }}_archive:
  archive:
    - extracted
    - name: {{ instance_dir }}
    - source: {{ instance.source }}
  {% if 'source_hash' in instance %}
    - source_hash: {{ instance.source_hash }}
  {% endif %}
    - archive_format: {{ instance.archive_format|default('tar') }}
    - keep: {{ instance.archive_cache|default(True) }}

tomcat_{{ id }}_archive_link:
  file:
    - symlink
    - name: {{ instance_dir }}/{{ instance.version }}
    - target: {{ instance_dir }}/{{ archive_dir|default('apache-tomcat-' ~ instance.version) }}
    - user: root
    - group: root

  {% for w_id, webapp in instance.webapps|default({})|dictsort if webapp.manage|default(False) %}
    {% set webapps_root = webapp.root|default(instance_dir ~ '/' ~ instance.version ~ '/webapps') %}
    {% set webapp_root = webapp.root|default(webapps_root ~ '/' ~ webapp.alias|default(w_id)) %}
    {% if webapp.ensure|default('present') == 'absent' %}
tomcat_{{ id }}_webapp_{{ w_id }}_dir:
  file:
    - {{ webapp.ensure }}
    - name: {{ webapp_root }}
    - user: root
    - group: root
    - mode: 750
    {% endif %}

    {% if 'war' in webapp %}
tomcat_{{ id }}_webapp_{{ w_id }}_war:
  file:
    - {{ webapp.ensure|default('managed') }}
    - name: {{ webapps_root }}/{{ webapp.war.name|default(webapp.alias|default(w_id) ~ '.war') }}
    - source: {{ webapp.war.source }}
      {% if 'source_hash' in webapp.war %}
    - source_hash: {{ webapp.war.source_hash }}
      {% endif %}
    - user: root
    - group: root
    - mode: 644
    {% endif %}
  {% endfor %}
{% endfor %}
