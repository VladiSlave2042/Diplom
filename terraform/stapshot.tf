resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "my-snapshot"
  schedule_policy {
    expression = "0 0 ? * *"
  }
  retention_period = "168h"
  snapshot_spec {
    description = "daily-snapshot"
  }
  disk_ids = ["${yandex_compute_instance.vm-1.boot_disk.0.disk_id}",
    "${yandex_compute_instance.vm-2.boot_disk.0.disk_id}",
    "${yandex_compute_instance.vm-3.boot_disk.0.disk_id}",
    "${yandex_compute_instance.vm-4.boot_disk.0.disk_id}",
    "${yandex_compute_instance.vm-5.boot_disk.0.disk_id}",
    "${yandex_compute_instance.vm-6.boot_disk.0.disk_id}", ]
}