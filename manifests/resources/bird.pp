class ffnord::resources::bird (
  #https://pkg.labs.nic.cz/doc/?project=bird
  #https://gitlab.nic.cz/labs/bird/-/wikis/transition-notes-to-bird-2
  apt::key {
    'cznic-labs-pkg.gpg':
      key => '0xAB6A303124019B64',
      key_source => 'https://pkg.labs.nic.cz/gpg';
  }

  apt::source {
    'bird':
      location   => 'https://pkg.labs.nic.cz/bird3',
      release    => $::lsbdistcodename,
      repos      => 'main';
  }

  package {
    'bird3':
      ensure => installed,
      notify => Service['bird3'],
      require => [
        Apt::Source['bird']
      ];
  }

  service {
    'bird':
      ensure => running,
      enable => true,
      require => [
        Package['bird3'],
      ];
  }

  $include_bird4 = $ffnord::params::include_bird4,
  $include_bird6 = $ffnord::params::include_bird6,
) inherits ffnord::params {
  file {
    '/etc/bird/':
      ensure => directory,
      mode => '0755';
  }

  ffnord::firewall::service { 'bird':
    ports  => ['179'],
    protos => ['tcp'],
    chains => ['mesh']
  }

  ffnord::resources::ffnord::field {
    'INCLUDE_BIRD4': value => $include_bird4;
    'INCLUDE_BIRD6': value => $include_bird6;
  }

}
