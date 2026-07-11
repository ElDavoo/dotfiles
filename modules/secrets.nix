# Segreti gestiti con sops-nix: cifrati in secrets/, decifrati
# all'attivazione in /run/secrets usando la chiave SSH dell'host.
# Per modificarli: sops secrets/<file> (usa ~/.config/sops/age/keys.txt)
{
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets."rclone.conf" = {
    sopsFile = ../secrets/rclone.conf;
    format = "binary";
  };

  # Token GitHub per nix (access-tokens = github.com=...).
  # Leggibile da root e dal gruppo wheel, così vale sia per
  # sudo nixos-rebuild sia per i comandi nix da utente.
  sops.secrets."nix-access-tokens.conf" = {
    sopsFile = ../secrets/nix-access-tokens.conf;
    format = "binary";
    mode = "0440";
    group = "wheel";
  };

  nix.extraOptions = "!include ${config.sops.secrets."nix-access-tokens.conf".path}";
}
