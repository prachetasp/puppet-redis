# Class: redis::params
#
# This class configures parameters for the puppet-redis module.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class redis::params {

  case $::osfamily {
    'redhat': {
      $nologin_shell  = '/sbin/nologin'
      $package        = 'redis'
      $service        = 'redis'
      $conf_logrotate = '/etc/logrotate.d/redis'
      $pidfile        = '/var/run/redis/redis.pid'
      $logfile        = '/var/log/redis/redis.log'
    }
    'debian': {
      $nologin_shell  = '/usr/sbin/nologin'
      $package        = 'redis-server'
      $service        = 'redis-server'
      $conf_logrotate = '/etc/logrotate.d/redis-server'
      $pidfile        = '/var/run/redis/redis-server.pid'
      $logfile        = '/var/log/redis/redis-server.log'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }

}
