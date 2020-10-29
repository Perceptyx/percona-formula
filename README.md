
# percona-formula [![Build Status](https://travis-ci.org/Perceptyx/percona-formula.png?branch=master)](https://travis-ci.org/Perceptyx/percona-formula)


A saltstack formula that configures Percona Server.


## Available states

- [`client`](#client)

- [`server`](#server)

- [`qpress`](#qpress)

- monitoring.[`cacti`](#monitoring-cacti)

- monitoring.[`nagios`](#monitoring-nagios)

- monitoring.[`zabbix`](#monitoring-zabbix)

- [`toolkit`](#toolkit)

- [`xtrabackup`](#xtrabackup)

### Client

- Installs Percona Server client package.

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
- You may declare a version within your pillar `percona: toolkit_version`.  If no version is defined, the LATEST version will be used.  Please note that LATEST ensures the most up-to-date version is installed.  See defaults.yaml.

### Xtrabackup

- Installs Percona Xtrabackup
