variable "source_image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/focal/20210415/focal-server-cloudimg-amd64.img"
}

variable "source_image_chksum" {
  type    = string
  default = "sha256:38b82727bfc1b36d9784bf07b8368c1d777450e978837e1cd7fa32b31837e77c"
}

variable "user_password" {
  type = string
  # password must match the hash in cloud-init/metadata/user-data file
  default = "Ubuntu20!"
}

variable "user_username" {
  type    = string
  # username must match the config in cloud-init/metadata/user-data file
  default = "ubuntu"
}

source "qemu" "base" {
  accelerator      = "hvf"
  boot_wait        = "1s"
  cpus             = 6
  disk_image       = true
  disk_interface   = "virtio"
  disk_size        = 1024 * 32
  display          = "cocoa,show-cursor=on"
  format           = "qcow2"
  http_directory   = "http"
  iso_checksum     = var.source_image_chksum
  iso_url          = var.source_image_url
  machine_type     = "q35"
  memory           = 1024 * 6
  net_device       = "virtio-net"
  output_directory = "vm/ubuntu"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password     = var.user_password
  ssh_timeout      = "20m"
  ssh_username     = var.user_username
  vm_name          = "ubuntu.qcow2"
  qemuargs = [
    ["-drive", "file=vm/ubuntu/ubuntu.qcow2,if=virtio,cache=unsafe,format=qcow2,id=disk0"],
    ["-drive", "if=virtio,format=raw,file=cloud-init/nocloud.iso,readonly=on,id=cdrom0"],
    ["-cpu", "qemu64"]
  ]
}

build {
  sources = ["source.qemu.base"]
  provisioner "shell" {
    scripts = [
      "scripts/customize.sh"
    ]
  }
}
