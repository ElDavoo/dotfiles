# GParted Live come voce di boot in systemd-boot.
#
# L'ESP (/boot) è troppo piccola per l'intera ISO (~650 MB, solo ~390 MB liberi),
# quindi:
#   - kernel + initrd estratti dalla ISO vanno sull'ESP (piccoli);
#   - la ISO resta nel nix store, referenziata dalla closure di sistema
#     (niente GC), e viene loop-montata a boot dallo script live-boot di Debian
#     tramite il parametro `findiso=`, che la cerca sulle partizioni per path.
# Il path della ISO nello store è relativo alla root della partizione che
# contiene /nix (la root ext4 su nvme1n1p2), quindi findiso la trova lì.
{pkgs, ...}: let
  gpartedIso = pkgs.fetchurl {
    url = "https://downloads.sourceforge.net/gparted/gparted-live-1.8.1-3-amd64.iso";
    hash = "sha256-P2ay4QuLssVz7WzdOptU/QqOdpBjSraxXDyPUXmS0aE=";
  };

  # Estrae kernel e initrd dalla ISO senza montarla (libarchive legge ISO9660).
  gpartedBoot = pkgs.runCommand "gparted-live-boot" {} ''
    mkdir -p $out
    ${pkgs.libarchive}/bin/bsdtar -xOf ${gpartedIso} live/vmlinuz  > $out/vmlinuz
    ${pkgs.libarchive}/bin/bsdtar -xOf ${gpartedIso} live/initrd.img > $out/initrd.img
  '';
in {
  boot.loader.systemd-boot.extraFiles = {
    "efi/gparted/vmlinuz" = "${gpartedBoot}/vmlinuz";
    "efi/gparted/initrd.img" = "${gpartedBoot}/initrd.img";
  };

  boot.loader.systemd-boot.extraEntries = {
    "gparted.conf" = ''
      title   GParted Live 1.8.1-3
      linux   /efi/gparted/vmlinuz
      initrd  /efi/gparted/initrd.img
      options boot=live config components union=overlay username=user noswap noeject toram findiso=${gpartedIso}
    '';
  };
}
