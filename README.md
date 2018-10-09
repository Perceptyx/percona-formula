
# percona-formula [![Build Status](https://travis-ci.org/Perceptyx/percona-formula.png?branch=master)](https://travis-ci.org/Perceptyx/percona-formula)


A saltstack formula that configures Percona Server.


## Available states

- [`client`](#client)

- [`jemalloc`](#jemalloc)

- [`server`](#server)

- [`qpress`](#qpress)

- monitoring.[`cacti`](#monitoring-cacti)

- monitoring.[`nagios`](#monitoring-nagios)

- monitoring.[`zabbix`](#monitoring-zabbix)

- [`toolkit`](#toolkit)

- [`xtrabackup`](#xtrabackup)

### Client

- Installs Percona Server client package.

### Jemalloc

- Installs jemalloc package to be used by Percona.

### Qpress

- Installs qpress to be used by Xtrabackup/innobackupex with --compression option.

### Server

- Installs Percona Server Server package
- Configure root password
- Remove MySQL users without host or without username
- Import MySQL timezone information
- Enables and starts MySQL service
- When using custom paths for logging ensure mysql-error.log and mysql-slow.log are present with correct permissions

### Monitoring Cacti

- Installs Percona Monitoring templates for Cacti

### Monitoring Nagios

- Installs Percona Monitoring plugins for Nagios

### Monitoring Zabbix

- Installs Percona Monitoring templates for Zabbix

### Toolkit

- Installs Percona Toolkit

### Xtrabackup

- Installs Percona Xtrabackup
