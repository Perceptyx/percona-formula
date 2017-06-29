# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "percona/defaults.yaml" import rawmap with context %}
{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}

mysql_config:
  file.managed:
    - name: {{ mysql.config.file }}
    - template: jinja
    - source: salt://percona/files/my.cnf
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.restart
    - m_name: {{ mysql.service }}
    - require:
      - file: mysql_config