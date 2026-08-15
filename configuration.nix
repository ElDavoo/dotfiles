# Set condiviso da tutti gli host. Quello che vale solo per una macchina
# (hardware, bootloader, moduli pesanti) si importa da hosts/<nome>.
{...}: {
  imports = [
    ./modules/base.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/system-packages.nix
    ./modules/desktop.nix
    ./modules/storage.nix
    ./modules/services.nix
    ./modules/ssh.nix
  ];
}
