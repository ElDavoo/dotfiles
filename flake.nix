{
  description = "NixOS system configuration for mattone";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprwm.url = "github:hyprwm/hypridle";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private = {
      url = "github:ElDavoo/dotfiles-private";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    private,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.mattone = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        private.nixosModules.ssh
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
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
