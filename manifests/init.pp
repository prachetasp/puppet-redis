class redis (
  $servers = {},
) inherits redis::params {
  create_resources('redis::server', $servers)
}
