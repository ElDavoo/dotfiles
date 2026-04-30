{pkgs, ...}: {
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  networking.firewall.checkReversePath = "loose";
  networking.firewall.enable = false;

  services.tailscale.enable = true;
}
