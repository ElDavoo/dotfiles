# Steam e affini: pesante (runtime a 32 bit, Proton, gamescope), quindi
# resta fuori dal set condiviso e lo importa solo chi ha una GPU capace.
{pkgs, ...}: {
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [pkgs.proton-ge-bin];
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = [pkgs.mangohud];
}
