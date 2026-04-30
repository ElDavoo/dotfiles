{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    htop
    hyprlock
    git
    gcc
    killall
    rclone
    libsecret
  ];
}
