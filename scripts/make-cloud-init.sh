#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# test for hdiutil in the path
if ! hash "hdiutil" >/dev/null 2>&1; then
  echo "Error: hdiutil not found in path!!"
  echo "If your on linux use this tool instead https://manpages.debian.org/testing/cloud-image-utils/cloud-localds.1.en.html"
  exit 1
fi

# Build the iso
hdiutil makehybrid -o cloud-init/nocloud.iso -ov -iso -joliet -default-volume-name cidata cloud-init/metadata

echo "Fin!"
