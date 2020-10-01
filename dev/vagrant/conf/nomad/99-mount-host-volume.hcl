client {
  host_volume "persistence" {
    path = "/vagrant/persistence/minio"
    read_only = false
  }
}