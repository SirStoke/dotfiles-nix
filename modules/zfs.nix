{ config, pkgs, ... }:

{ 
  fileSystems."/boot" =
    { device = "bpool/nixos/root";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

  boot.supportedFilesystems = ["zfs"];
  networking.hostId = "b81789d1";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.extraPrepareConfig = ''
    mkdir -p /boot/efis
    for i in  /boot/efis/*; do mount $i ; done
  
    mkdir -p /boot/efi
    mount /boot/efi
  '';
  boot.loader.grub.extraInstallCommands = ''
  ESP_MIRROR=$(mktemp -d)
  cp -r /boot/efi/EFI $ESP_MIRROR
  for i in /boot/efis/*; do
   cp -r $ESP_MIRROR/EFI $i
  done
  rm -rf $ESP_MIRROR
  '';
  boot.loader.grub.device = "/dev/disk/by-id/nvme-VMware_Virtual_NVMe_Disk_VMware_NVME_0000";
}
