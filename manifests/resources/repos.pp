class ffnord::resources::repos (
  $debian_mirror = $ffnord::params::debian_mirror
) inherits ffnord::params {
  package {
    'apt-transport-https':
      ensure => installed;
  } ->

  apt::source { 'debian-backports':
    location          => $debian_mirror,
    required_packages => 'debian-keyring debian-archive-keyring',
    release           => "${::lsbdistcodename}-backports",
    repos             => 'main contrib',
    include_src       => false,
  }
}
