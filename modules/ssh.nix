# Migrato da dotfiles-private (non conteneva nulla di segreto).
{...}: {
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = ["dave"];
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };
}
