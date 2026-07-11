{pkgs, ...}: {
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  networking.firewall.enable = true;
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = ["tailscale0"];

  services.tailscale.enable = true;
}
