# Nagios plugins

The repository contains usefull Nagios NRPE plugins.

# NRPE config example

Below you can find some NRPE config examples:

### Basic server monitoring
```
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[check_load]=/usr/lib64/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_zombie_procs]=/usr/lib64/nagios/plugins/check_procs -w 5 -c 10 -s Z
command[check_total_procs]=/usr/lib64/nagios/plugins/check_procs -w 150 -c 200
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10%
command[check_memory]=/usr/local/bin/check_memory 15 6 75 50
command[check_time]=/usr/lib64/nagios/plugins/check_ntp_time -H ntp.server -w 0.5 -c 1
```

### Database monitoring

MySQL:
```
command[check_mysql]=/usr/lib64/nagios/plugins/check_mysql -unrpe -pnrpe -H localhost
```

Postgres:
```
command[check_postgres_proc]=/usr/lib64/nagios/plugins/check_procs -a postgres -c 3:100 -u postgres
```

### Monit monitoring

The best way to monitor the server and make sure it is running is to install [Monit](https://mmonit.com/monit/), and then monitor it.
```
command[check_monit]=/usr/local/bin/check_monit -H localhost
```
The monit plugin can be found in this repo [here](../plugins/check_monit.py). The plugin requires python.

