class ffnord::alfred (
  $master = false
) {
  file { '/usr/local/bin/mesh-announce':
    ensure => file,
    mode => '0755',
    source => 'puppet:///modules/ffnord/usr/local/bin/mesh-announce';
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

  exec { 'alfred':
    command => '/usr/bin/make CONFIG_ALFRED_CAPABILITIES=n',
    cwd => '/opt/alfred/',
    require => [Vcsrepo['/opt/alfred'],Package['build-essential'],Package['pkg-config'],Package['libgps-dev']];
  }

  service { 'alfred':
    ensure => running,
    hasrestart => true,
    enable => false,
    require => [Exec['alfred'],File['/etc/init.d/alfred']];
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
    command => 'PATH=/opt/alfred/:/bin:/usr/bin:/sbin:/usr/sbin/:$PATH /usr/local/bin/mesh-announce',
    user    => root,
    minute  => '*',
    require => [Vcsrepo['/opt/mesh-announce'], Vcsrepo['/opt/alfred'],File['/usr/local/bin/mesh-announce']];
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
