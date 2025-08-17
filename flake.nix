{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

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

  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, spicetify-nix, home-manager, ... }: {
    nixosConfigurations.mattone = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-pc-laptop
        ./configuration.nix
        "${nixos-hardware}/common/gpu/nvidia/ampere"
        "${nixos-hardware}/common/cpu/intel/comet-lake"
        # This module works the same as the `specialArgs` parameter we used above
        # choose one of the two methods to use
        # { _module.args = { inherit inputs; };}
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # TODO replace ryan with your own username
            home-manager.users.dave = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }

      ];
    };
  };
}
