# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [
    ./hosts/mattone
    ./modules/base.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/system-packages.nix
    ./modules/desktop.nix
    ./modules/hermes.nix
    ./modules/storage.nix
    ./modules/secrets.nix
    ./modules/services.nix
    ./modules/ssh.nix
    ./modules/virtualization.nix
    ./modules/spicetify.nix
  ];
}
