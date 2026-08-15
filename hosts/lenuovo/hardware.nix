# Lenovo IdeaPad Flex 15 (20332): Pentium N3520 (Bay Trail), 4 GB di RAM,
# iGPU Gen7, SSD condiviso con Windows.
{pkgs, ...}: {
  # L'ESP è quella di Windows: 100 MB totali, ~68 MB liberi. Non ci sta un
  # kernel, quindi niente systemd-boot (che tiene kernel e initrd sull'ESP).
  # GRUB invece lascia kernel/initrd in /boot sulla root ext4 e nell'ESP mette
  # solo grubx64.efi, pochi MB. os-prober aggiunge la voce per Windows.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    configurationLimit = 10;
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  # Bay Trail: i C-state profondi causano freeze casuali su questa piattaforma
  # (bug noto della famiglia N3xxx/J1xxx). max_cstate=1 costa un po' di
  # autonomia ma evita i blocchi.
  boot.kernelParams = ["intel_idle.max_cstate=1"];

  # Firmware per il bluetooth Atheros AR3012 (0cf3:3004).
  hardware.enableRedistributableFirmware = true;

  hardware.graphics.enable = true;
  # Gen7 → driver VAAPI i965, non intel-media-driver (che parte da Gen8).
  hardware.graphics.extraPackages = [pkgs.intel-vaapi-driver];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";

  # 4 GB di RAM: un derivation build alla volta, altrimenti l'OOM killer
  # arriva prima della fine (i 4 core restano usabili dentro il singolo build).
  nix.settings.max-jobs = 1;

  # zram da solo non basta per i build grossi: swapfile sulla root.
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];
}
