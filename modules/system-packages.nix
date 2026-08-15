{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    claude-code
    htop
    hyprlock
    git
    gcc
    killall
    rclone
    libsecret
  ];
}
