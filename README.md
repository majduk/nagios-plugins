# Nagios plugins

The repository contains usefull Nagios NRPE plugins.

# NRPE config example

Below you can find some NRPE config examples:

### Basic server monitoring

command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10%
command[check_memory]=/usr/local/bin/check_memory 15 6 75 50
command[check_time]=/usr/lib64/nagios/plugins/check_ntp_time -H ntp.server -w 0.5 -c 1


### Mysql monitoring
command[check_mysql]=/usr/lib64/nagios/plugins/check_mysql -unrpe -pnrpe -H localhost

### Monit monitoring

The best way to monitor the server and make sure it is running is to install [Monit](https://mmonit.com/monit/), and then monitor it.
command[check_monit]=/usr/local/bin/check_monit -H localhost

The monit plugin can be found in this repo [here](../blob/plugins/check_monit.py). The plugin requires python.

