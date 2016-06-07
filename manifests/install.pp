# FIX: Set bind_address to internal IP later once we are in VPC

class redis::install(
  $redis_dl_dir      = '/opt/redis-dl',
  $redis_install_dir = '/opt/redis',
  $version           = hiera('redis_version', '2.8.19')
  ){

  include redis::params
  include gcc
  include wget

  $conf_dir            = "/etc/"
  $redis_tar           = "redis-${version}.tar.gz"
  $redis_pkg           = "${redis_dl_dir}/${redis_tar}"

  package { 'redis':
    ensure => $package_ensure,
    name   => $package,
  }

  file { [ $redis_dl_dir, $conf_dir ]:
    ensure => directory,
  }

  file { [ '/var/log/redis', '/var/run/redis' ]:
    ensure => 'directory',
    owner  => 'redis',
    group  => 'redis',
    mode   => '0755',
  }

  wget::fetch { "download redis source":
    source      => "http://download.redis.io/releases/${redis_tar}",
    destination => $redis_pkg,
    timeout     => 0,
    verbose     => false,
    require     => File[$redis_dl_dir],
  }

  file { 'redis bin link':
    ensure => link,
    path   => '/usr/local/bin/redis-cli',
    target => "${redis_install_dir}/bin/redis-cli",
  }

  file { 'redis-sentinel bin link':
    ensure => link,
    path   => '/usr/bin/redis-sentinel',
    target => "${redis_install_dir}/bin/redis-sentinel",
  }

  exec { 'extract redis':
    command => "tar -xzf ${redis_pkg}",
    cwd     => $redis_dl_dir,
    path    => '/bin:/usr/bin',
    unless  => "test -f ${redis_dl_dir}/Makefile",
    require => Wget::Fetch['download redis source'],
  }

  exec { 'install redis':
    command => "rm -rf $redis_install_dir/*; make && make install PREFIX=${redis_install_dir}",
    cwd     => "${redis_dl_dir}/redis-${version}",
    path    => '/bin:/usr/bin',
    unless  => "test $(${redis_install_dir}/bin/redis-server --version | awk {'print \$3'} | cut -d '=' -f2) = $version",
    require => [ Exec['extract redis'], Class['gcc'] ],
  }

}
