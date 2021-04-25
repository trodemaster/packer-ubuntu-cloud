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
  default = "ubuntu"
}

source "qemu" "base" {
  iso_checksum     = var.source_image_chksum
  iso_url          = var.source_image_url
  output_directory = "vm/ubuntu"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  disk_size        = 1024 * 32
  format           = "qcow2"
  memory           = 1024 * 6
  machine_type     = "q35"
  cpus             = 2
  accelerator      = "hvf"
  http_directory   = "http"
  disk_image       = true
  ssh_password     = var.user_password
  ssh_username     = var.user_username
  ssh_timeout      = "20m"
  vm_name          = "ubuntu.qcow2"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "1s"
  qemuargs = [
    ["-monitor", "stdio"],
    ["-drive", "file=vm/ubuntu/ubuntu.qcow2,if=virtio,cache=unsafe,format=qcow2,id=disk0"],
    ["-drive", "if=virtio,format=raw,file=cloud-init/nocloud.iso,readonly=on,id=cdrom0"],
    ["-device", "virtio-gpu-pci"],
    ["-cpu", "qemu64"],
    ["-display", "cocoa,show-cursor=on"],
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"],
    ["-device", "usb-tablet"],
    ["-device", "intel-hda"],
    ["-device", "hda-duplex"],
    ["-object", "rng-random,filename=/dev/urandom,id=rng0"],
    ["-device", "virtio-rng-pci,rng=rng0"],
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-boot", "strict=off"]
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
