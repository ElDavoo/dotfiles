{pkgs, ...}: {
  services.fwupd.enable = true;

  services.devmon.enable = true;
  services.udisks2.enable = true;

  services.gvfs.enable = true;
  services.tumbler.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  services.blueman.enable = true;

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    greetd-password.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  services.dbus.packages = [pkgs.gnome-keyring pkgs.gcr];
}
