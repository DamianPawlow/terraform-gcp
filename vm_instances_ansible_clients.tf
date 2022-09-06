resource "google_compute_instance" "ansible_client" {
  count = "${var.ansible_num_nodes}"
  name         = "ansible-client-${count.index}"
  machine_type = "n1-standard-1"
  zone         = var.ansible_client_zone
  tags            = ["ansible-client"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}