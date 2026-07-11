{...}: {
  users.users.dave = {
    isNormalUser = true;
    description = "Davide";
    extraGroups = ["plugdrv" "input" "storage" "networkmanager" "adbusers" "wheel" "docker" "kvm" "scanner" "lp"];
  };

  services.getty.autologinUser = "dave";
}
