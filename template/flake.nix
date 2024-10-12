{
  description = "Opinionated flake template with nixos-generators and agenix";
  inputs = {
    nixpkgs.url = "nixpkgs/release-24.05";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "";
    agenix.inputs.home-manager.follows = "";

    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ( { self, lib, ... }: {
    imports = [ inputs.devshell.flakeModule ];

    flake = {
      nixosModules = {
        exampleModule = { system.stateVersion = "24.05"; };
      };
      nixosConfigurations = {
        example = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.nixos-generators.nixosModules.proxmox-lxc
            self.nixosModules.exampleModule
          ];
        };
      };
    };

    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, system, ... }: {
      formatter = pkgs.alejandra;
      devshells.default = {
        commands = [
          {
            name = "build-image";
            category = "build";
            help = "Build <nixosConfiguration> [proxmox-lxc] image for [${system}]";
            command = ''
              ${inputs.nixos-generators.apps.${system}.nixos-generate.program} \
                --flake $PRJ_ROOT#''\${1} \
                --format ''\${2:-proxmox-lxc} \
                --system ''\${3:-${system}} \
                --show-trace
            '';
          }
          { package = inputs.agenix.packages.${system}.default; category = "dev"; }
        ];
        packages = [ pkgs.nixd ];
        env = [
          { name = "RULES"; eval = "$PRJ_ROOT/secrets.nix"; }
        ];
      };
    };
  });
}

