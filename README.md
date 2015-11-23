
The repository contains useful Nagios NRPE plugins and some configuration examples balow.

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
command[check_pgsql]=/usr/lib64/nagios/plugins/check_pgsql -Hlocalhost -pnrpe -lnrpe -ddatabase
command[check_postgres_proc]=/usr/lib64/nagios/plugins/check_procs -a postgres -c 3:100 -u postgres
```

### Rails passenger monitoring

```
command[check_http]=/usr/lib64/nagios/plugins/check_http -I localhost -p 8080
command[check_passenger_status]=/usr/bin/sudo /usr/lib64/nagios/plugins/contrib/check_passenger_status_wrapper -w 2 -c 15
```

### Monit monitoring

The best way to monitor a server and make sure it is running is to install [monit](https://mmonit.com/monit/), and then monitor it.
```
command[check_monit]=/usr/local/bin/check_monit -H localhost
```
The monit plugin can be found in this repo [here](./plugins/check_monit.py). The plugin requires python.

