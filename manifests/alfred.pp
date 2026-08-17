class ffnord::alfred (
  $master = false
) {
  file { '/opt/mesh-announce/respondd.conf':
    ensure => file,
    mode => '0755',
    source => 'puppet:///modules/ffnord/opt/mesh-announce/respondd.conf';
  }

  file {
    "/opt/mesh-announce/${mesh_code}-respondd.conf":
    ensure => file,
    content => template('ffnord/etc/mesh-announce/respondd.conf.erb'),
  }

  package {
    'alfred':
      ensure => installed;
    'build-essential':
      ensure => installed;
    'pkg-config':
      ensure => installed;
    'libgps-dev':
      ensure => installed;
    'python3':
      ensure => installed;
    'ethtool':
      ensure => installed;
  }


  service { 'alfred':
    ensure => running,
  }

  service::unit_file { 'respondd':
    content => file("/opt/mesh-announce/respondd.service"),
    enable => true,
    active => true,
  }

  service { 'respondd':
    ensure => running,
  }

  vcsrepo { '/opt/mesh-announce':
    ensure => present,
    provider => git,
    source => 'https://github.com/ffnord/mesh-announce.git',
    revision => 'b31922fd53d2796b69ac4bd260ad837a200d0d5f',
    require => [Package['python3'],Package['ethtool']];
  }

  cron {
  'update-alfred-announce':
    command => 'PATH=/bin:/usr/bin:/sbin:/usr/sbin/:$PATH /opt/mesh-announce/announce.sh',
    user    => root,
    minute  => '*',
    require => [Vcsrepo['/opt/mesh-announce'],File['/opt/mesh-announce/announce.sh']];
  }

  ffnord::firewall::service { 'alfred':
    protos => ['udp'],
    chains => ['mesh','bat'],
    ports => ['16962'],
  }

  if $master {
    ffnord::resources::ffnord::field { 'ALFRED_OPTS': value => '-m'; }
  } else {
    ffnord::resources::ffnord::field { 'ALFRED_OPTS': value => ''; }
  }
}
