{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.spicetify-nix.nixosModules.default
  ];

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      volumePercentage
      hidePodcasts
    ];
    enabledCustomApps = with spicePkgs.apps; [
    ];
    enabledSnippets = with spicePkgs.snippets; [
    ];
  };
}
