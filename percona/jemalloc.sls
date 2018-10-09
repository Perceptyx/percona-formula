{% from "percona/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('percona:server:lookup')) %}

{#

  This is installed to help in cases of memory fragmentation, check:

    https://www.percona.com/blog/2017/01/03/enabling-and-disabling-jemalloc-on-percona-server/
    https://support.qualityunit.com/412339-Speedup-Mysql-Memory-Allocation-Performance
    https://www.percona.com/blog/2013/03/08/mysql-performance-impact-of-memory-allocators-part-2/
    https://www.percona.com/blog/2012/07/05/impact-of-memory-allocators-on-mysql-performance/

#}

{{ mysql.jemalloc }}:
  pkg.installed
    onchanges_in:
      - service: mysqld
