# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "percona/defaults.yaml" import rawmap with context %}

include:
  - percona.repo
  - percona.python
  - percona.custom_version

{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}
{% set mysql_root_user = salt['pillar.get']('percona:server:root_user', 'root') %}
{% set mysql_root_password = salt['pillar.get']('percona:server:root_password', salt['random.get_str'](32)) %}
{% set mysql_host = salt['pillar.get']('percona:server:host', 'localhost') %}
{% set defaults_extra_file = salt['pillar.get']('percona:defaults_extra_file', mysql.defaults_extra_file) %}

{%- if 'mysql80' in grains.get('roles','') %}

install-80-repo:
  pkg.installed:
    - name: percona-release
    - require_in:
        - cmdL enable-80-repo

enable-80-repo:
  cmd.run:
    - name: /usr/bin/percona-release setup ps80
    - require_in:
        - pkgrepo: percona-repository

{% endif %}

mysql_debconf_utils:
  pkg.installed:
    - name: {{ mysql.debconf_utils }}

mysql_debconf:
  debconf.set:
    - name: {{ mysql.pkg_prefix }}
    - data:
        '{{ mysql.pkg_prefix }}-server/root_password': {'type': 'password', 'value': '{{ mysql_root_password }}'}
        '{{ mysql.pkg_prefix }}-server/root_password_again': {'type': 'password', 'value': '{{ mysql_root_password }}'}
        '{{ mysql.pkg_prefix }}-server/start_on_boot': {'type': 'boolean', 'value': 'true'}
    - require_in:
      - pkg:  percona-server-pkg
    - require:
      - pkg: {{ mysql.debconf_utils }}

percona-server-pkg:
{# We want to install a custom version and it's not in repository #}
{%- if mysql.version is defined and salt['cmd.retcode']('apt-cache madison ' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ ' | grep -qP \'(^|\s)\K' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ '(?=\s|$)\' | grep -qP \'(^|\s)\K' ~ mysql.version ~ '-[0-9](?=\s|$)\'', python_shell=True) == 1 %}
  pkg.installed:
    - sources:
      - {{ mysql.pkg_prefix }}-server-{{ mysql.major_version }}: /tmp/percona/{{ mysql.pkg_prefix }}-server-{{ mysql.version_suffix_w_major }}
      {%- if mysql.major_version == '5.6' %} {# Percona removed packages like percona-server-server-5.6_5.6.36-82.0-1.trusty_amd64.deb in 5.7 release #}
      - {{ mysql.pkg_prefix }}-server: /tmp/percona/{{ mysql.pkg_prefix }}-server_{{ mysql.version_suffix }}
      {% endif %}
    - require:
      - sls: percona.custom_version
{% else %}
  pkg.installed:

{%- if 'mysql80' in grains.get('roles','') %}
    - name: {{ mysql.pkg_prefix }}-server
{% else %}
    - name: {{ mysql.pkg_prefix }}-server-{{ mysql.major_version }}
{% endif %}
    - require:
      - debconf: mysql_debconf
{% endif %} {# if mysql.version is defined... #}

mysql_root_password:
  mysql_user:
    - present
    - name: '{{ mysql_root_user }}'
    - password: '{{ mysql_root_password }}'
    - connection_host: '{{ mysql_host }}'
    - connection_default_file: {{ defaults_extra_file }}
    - connection_charset: utf8
    - saltenv:
      - LC_ALL: "en_US.utf8"
    - require:
      - service: mysqld
      - pkg: {{ mysql.python }}

root_my_cnf:
  file.managed:
    - name: /root/.my.cnf
    - template: jinja
    - source: salt://percona/files/root_my.cnf
    - user: root
    - group: root
    - mode: 600
    - context:
       mysql_root_user: '{{ mysql_root_user }}'
       mysql_root_password: '{{ mysql_root_password }}'
    - require:
      - mysql_user: mysql_root_password

{% for host in ['localhost', 'localhost.localdomain', salt['grains.get']('fqdn')] %}
mysql_delete_anonymous_user_{{ host }}:
  mysql_user:
    - absent
    - host: {{ host or "''" }}
    - name: ''
    - connection_host: '{{ mysql_host }}'
    - connection_user: '{{ mysql_root_user }}'
    {% if mysql_root_password %}
    - connection_pass: '{{ mysql_root_password }}'
    {% endif %}
    - connection_charset: utf8
    - require:
      - service: mysqld
      - pkg: {{ mysql.python }}
      {%- if mysql_root_user and mysql_root_password %}
      - mysql_user: mysql_root_password
      {%- endif %}
{% endfor %}

mysql_tzinfo_to_sql:
  cmd.run:
    - name: mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --defaults-extra-file=/root/.my.cnf mysql
    - unless: test $(mysql --defaults-extra-file=/root/.my.cnf mysql -sN --execute="select count(*) from time_zone;") -gt 0
    - require:
      - service: mysqld
      - file: root_my_cnf

mysqld:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - pkg: percona-server-pkg
