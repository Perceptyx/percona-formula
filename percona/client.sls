# -*- coding: utf-8 -*-
# vim: ft=sls
include:
  - .repo
  - percona.custom_version

{% from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}

{%- if salt['pillar.get']('percona:version') is defined and salt['pillar.get']('percona:version') != '' %}
{%- set version = salt['pillar.get']('percona:version') %}
{%- set major_version = version.split('.')[0] ~ '.' ~ version.split('.')[1] %}
{% else %}
{%- set major_version = '5.7' %}
{% endif %}

mysql-pkg:
{# We want to install a custom version and it's not in repository #}
{%- if mysql.version is defined and salt['cmd.retcode']('apt-cache madison ' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ ' | grep -qP \'(^|\s)\K' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ '(?=\s|$)\' | grep -qP \'(^|\s)\K' ~ mysql.version ~ '-[0-9](?=\s|$)\'', python_shell=True) == 1 %}
{%- set libperconaserverclient_version = salt['cmd.run_stdout']('curl -sL ' ~ mysql.percona_url ~ ' | grep -oP "\/downloads[^\s>]+libperconaserverclient([0-9|\.]*)_[^\s>]+\.' ~ grains['oscodename'] | lower ~ '_' ~ mysql.os_arch ~ '\.deb" | sed -n "s/\/downloads\(.*\)libperconaserverclient\([0-9|\.]*\)\_\(.*\)/\\2/p"', python_shell=True) %}
  pkg.installed:
    - sources:
      - {{ mysql.pkg_prefix }}-common-{{ mysql.major_version }}: /tmp/percona/{{ mysql.pkg_prefix }}-common-{{ mysql.version_suffix_w_major }}
      - libperconaserverclient18.1{{ libperconaserverclient_version }}: /tmp/percona/libperconaserverclient18.1{{ libperconaserverclient_version }}_{{ mysql.version_suffix }}
      - libperconaserverclient18.1{{ libperconaserverclient_version }}-dev: /tmp/percona/libperconaserverclient18.1{{ libperconaserverclient_version }}-dev_{{ mysql.version_suffix }}
      - {{ mysql.pkg_prefix }}-client-{{ mysql.major_version }}: /tmp/percona/{{ mysql.pkg_prefix }}-client-{{ mysql.version_suffix_w_major }}
      {%- if mysql.major_version == '5.6' %} {# Percona removed packages like percona-server-client-5.6_5.6.36-82.0-1.trusty_amd64.deb in 5.7 release #}
      - {{ mysql.pkg_prefix }}-client: /tmp/percona/{{ mysql.pkg_prefix }}-client_{{ mysql.version_suffix }}
      {% endif %}
    - require:
      - sls: percona.custom_version
{% else %}
  pkg.installed:
{%- if major_version == '8.0' %}
    - name: {{ mysql.pkg_prefix }}-client
{% else %}
    - name: {{ mysql.pkg_prefix }}-client-{{ mysql.major_version }}
{% endif %}
    - require:
      - debconf: mysql_debconf
{% endif %} {# if mysql.version is defined... #}
