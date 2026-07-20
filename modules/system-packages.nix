{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    claude-code
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
    htop
    hyprlock
    git
    gcc
    killall
    rclone
    libsecret
    mangohud
  ];
}
