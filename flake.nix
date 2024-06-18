{
  description = "Utility function to define flake packages and nixosConfigurations for all nixos-generators formats";
  inputs = {
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    nixos-generators,
    utils,
    ...
  }:
    {
      lib.mkConfigWithImage = nixpkgs: modules:
        (utils.lib.eachDefaultSystem (system: let
          formatModules = nixpkgs.lib.filterAttrs (name: _: name != "all-formats") nixos-generators.nixosModules;
        in {
          packages =
            builtins.mapAttrs (format: formatModule:
              nixos-generators.nixosGenerate {
                inherit system format;
                modules = [formatModule] ++ modules;
              })
            formatModules
            // {
              nixosConfigurations = builtins.mapAttrs (format: formatModule:
                nixpkgs.lib.nixosSystem {
                  inherit system;
                  modules = [formatModule] ++ modules;
                })
              formatModules;
            };
        }))
        .packages;
    }
    // utils.lib.eachDefaultSystem (system: {formatter = nixpkgs.legacyPackages.${system}.alejandra;});
}
