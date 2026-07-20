{pkgs, ...}: {
  services.fwupd.enable = true;

  services.printing.enable = true;
  # niente cups-browsed: interroga la rete in continuo per scoprire
  # stampanti; le stampanti si aggiungono a mano quando servono
  services.printing.browsed.enable = false;
  services.printing.drivers = [
    pkgs.hplip
    pkgs.brlaser
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
  ];

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

  hardware.sane.enable = true;
  services.ipp-usb.enable = true;
  hardware.sane.extraBackends = [pkgs.sane-airscan];
  services.udev.packages = [pkgs.sane-airscan];
}
