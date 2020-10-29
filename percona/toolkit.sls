{%- from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona')) %}
{%- set percona_toolkit_url = 'https://www.percona.com/downloads/percona-toolkit/' ~ mysql.toolkit_version ~ '/binary/' ~ grains['os_family'] | lower ~ '/' ~ grains['oscodename'] ~ '/' %}
{%- set percona_toolkit_pkg_url = salt['cmd.run_stdout']('curl -sL ' ~ percona_toolkit_url ~ ' | grep -oP "\/downloads[^\s>]+percona-toolkit_([0-9])+[^\s]+.' ~ grains['oscodename'] ~ '_' ~ mysql.os_arch ~ '\.deb" | tail -1 | sed -e "s/^/https\:\/\/www.percona.com/"', python_shell=True) %}
{# set version number from toolkit pkg url, this converts LATEST to a version number #}
{%- set installed_toolkit_version = percona_toolkit_pkg_url.split('/')[5] %}

{# Check percona_toolkit_pkg_url as it may be None if invalid version is specified #}
{%- if percona_toolkit_pkg_url and 1 == salt['cmd.retcode']("dpkg-query -f '${Status} ${Version}' -W percona-toolkit | grep -E '^(install|hold) ok installed " ~ installed_toolkit_version ~ "-[0-9]." ~ grains['oscodename'] ~ "$'", python_shell=True) %}
percona-toolkit:
  pkg.installed:
    - sources:
      - percona-toolkit: {{ percona_toolkit_pkg_url }}
{% endif %}
