# Stampa e scansione: i driver (hplip, brother) pesano parecchio nella
# closure, quindi restano opzionali e non entrano nel set condiviso.
{pkgs, ...}: {
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

  hardware.sane.enable = true;
  services.ipp-usb.enable = true;
  hardware.sane.extraBackends = [pkgs.sane-airscan];
  services.udev.packages = [pkgs.sane-airscan];
}
