{
  description = "NixOS system configuration for mattone";

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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    hermes-agent,
    nixos-hardware,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.mattone = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        {
          nixpkgs.overlays = [inputs.claude-code.overlays.default];
        }
        ./configuration.nix
        home-manager.nixosModules.home-manager
        hermes-agent.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-bak";
          home-manager.users.dave = import ./home.nix;
        }
      ];
    };

    formatter.${system} = pkgs.alejandra;

    checks.${system} = {
      alejandra = pkgs.runCommand "alejandra-check" {buildInputs = [pkgs.alejandra];} ''
        alejandra --check ${self}
        touch $out
      '';
      nixos-mattone = self.nixosConfigurations.mattone.config.system.build.toplevel;
    };
  };
}
