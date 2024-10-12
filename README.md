# Motivation

I frequently write flakes consisting of a single NixOS configuration, and the boilerplate needed to build a VM image of it (in one of the formats supported by [nixos-generators](https://github.com/nix-community/nixos-generators)). Some minor hoop-jumping is needed to allow me to:

- Run `nix build .#<any-format>` to build the image in whatever format I need for deployment
- Run `nixos-rebuild --flake <flakeref>#<any-format> switch` to rebuild a deployed VM with an updated configuration (instead of re-imaging it from a rebuilt image, which is time-consuming).

# Usage

## Flake template

```
nix flake init -t jeslinmx/nixos-generators-helper#proxmox-lxc
```

## Nix function

```
{
  description = ...;

  inputs = {
    nixos-generators-helper.url = "github:jeslinmx/nixos-generators-helper";
    nixos-generators-helper.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixos-generators-helper,
    ...
  }: {
    nixosModules.yourModule = { ... };

    packages = nixos-generators-helper.lib.mkConfigWithImage nixpkgs [ self.nixosModules.yourModule ... ];
    formatter = nixos-generators-helper.formatter; # optional, just pulls in alejandra
  };
}
```

# License

[CC0](./LICENSE)
