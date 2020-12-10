{% from "percona/defaults.yaml" import rawmap with context %}

include:
  - percona.repo

{% set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:lookup')) %}

{# We want to install a custom version and it's not in repository #}
{%- if (mysql.version is defined and mysql.version != '') and salt['cmd.retcode']('apt-cache madison ' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ ' | grep -qP \'(^|\s)\K' ~ mysql.pkg_prefix ~ '-' ~ mysql.major_version ~ '(?=\s|$)\' | grep -qP \'(^|\s)\K' ~ mysql.version ~ '-[0-9](?=\s|$)\'', python_shell=True) == 1 %}
percona-custom-version:
  pkg.latest:
    - pkgs:
      - zlib1g-dev
      - libdbi-perl
      - libdbd-mysql-perl
      - libaio1
      - libwrap0
      - psmisc
      - curl

{%- set percona_tarball_url = "https://www.percona.com/" ~ salt['cmd.run_stdout']('curl -sL -X POST -d "newBrowse=fetch-files&p=Percona-Server-' ~ mysql.major_version ~ '/Percona-Server-' ~ mysql.version ~ '/binary/'~ grains['os_family'] | lower ~'/' ~ grains['oscodename'] | lower ~'" https://www.percona.com/downloads-ajax |grep -oP "/downloads/Percona-Server-[^\s>]+' ~ mysql.tarball_os_arch | lower ~ '[^\s>]+\.tar"', python_shell=True) %}

  archive.extracted:
    - name: /tmp/percona
    - source: {{ percona_tarball_url }}
    - enforce_toplevel: False
    - skip_verify: True
    - trim_output: True
    - keep: True
    - if_missing: /tmp/percona
    - require:
      - pkg: percona-custom-version
    - require_in:
      - pkg: percona-server-pkg
      - pkg: mysql-pkg
{% endif %}
