terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
provider "yandex" {
  token = "y0_AgAAAAAeDgurAATuwQAAAADfAP2Jh_u4KASxQG2XsJ8vF_kWyTDL5Ds"
  cloud_id = "b1gm89k2ds3gdamaj4vo"
  folder_id = "b1gkoo3ipkk5jge3h5m3"
}