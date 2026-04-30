{...}: {
  programs.git = {
    enable = true;
    settings.user = {
      name = "Davide Palma";
      mail = "git@davidepalma.it";
    };
  };
}
