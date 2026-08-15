{
  description = "NixOS system configuration for mattone and lenuovo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    claude-code.url = "github:sadjow/claude-code-nix";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    hermes-agent.url = "github:NousResearch/hermes-agent";

    # Uses its own pinned nixpkgs: the flake needs nodePackages,
    # which was removed from nixpkgs-unstable.
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Firefox add-ons (rycee's standalone add-on set).
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    hermes-agent,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Un host = configuration.nix (set condiviso) + hosts/<nome> (hardware e
    # moduli specifici), più i moduli che arrivano dai flake input e servono
    # solo a quella macchina.
    mkHost = hostName: extraModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules =
          [
            {
              nixpkgs.overlays = [
                inputs.claude-code.overlays.default
                # Espone pkgs.firefox-addons costruito con la nostra nixpkgs
                # (così allowUnfree copre estensioni come Tampermonkey).
                inputs.firefox-addons.overlays.default
              ];
            }
            ./configuration.nix
            ./hosts/${hostName}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = {inherit inputs;};
              home-manager.users.dave = import ./home.nix;
            }
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      mattone = mkHost "mattone" [hermes-agent.nixosModules.default];
      lenuovo = mkHost "lenuovo" [];
    };

    formatter.${system} = pkgs.alejandra;

    checks.${system} = {
      alejandra = pkgs.runCommand "alejandra-check" {buildInputs = [pkgs.alejandra];} ''
        alejandra --check ${self}
        touch $out
      '';
      statix = pkgs.runCommand "statix-check" {buildInputs = [pkgs.statix];} ''
        cd ${self}
        statix check .
        touch $out
      '';
      deadnix = pkgs.runCommand "deadnix-check" {buildInputs = [pkgs.deadnix];} ''
        deadnix --fail ${self}
        touch $out
      '';
      nixos-mattone = self.nixosConfigurations.mattone.config.system.build.toplevel;
      nixos-lenuovo = self.nixosConfigurations.lenuovo.config.system.build.toplevel;
    };
  };
}
