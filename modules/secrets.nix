# Segreti gestiti con sops-nix: cifrati in secrets/, decifrati
# all'attivazione in /run/secrets usando la chiave SSH dell'host.
# Per modificarli: sops secrets/<file> (usa ~/.config/sops/age/keys.txt)
{inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets."rclone.conf" = {
    sopsFile = ../secrets/rclone.conf;
    format = "binary";
  };
}
