{
  description = "okta-aws-cli";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell.inputs.flake-utils.follows = "flake-utils";

  inputs.gomod2nix.url = "github:nix-community/gomod2nix/v1.5.0";
  inputs.gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.gomod2nix.inputs.utils.follows = "flake-utils";

  # TODO: revert to upstream after https://github.com/okta/okta-aws-cli/issues/36
  inputs.okta-aws-cli.url = "github:daniel-sampliner/okta-aws-cli/all-profiles";
  inputs.okta-aws-cli.flake = false;

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        gomod2nix = inputs.gomod2nix.packages.${system}.default;

        generate-gomod2nix-toml = pkgs.writeShellApplication {
          name = "generate-gomod2nix-toml";
          text = ''
            "${gomod2nix}/bin/gomod2nix" generate \
              --dir "${inputs.okta-aws-cli}" \
              --outdir . \
              "$@"
          '';
        };

        gomod2nix-builder = pkgs.callPackage
          "${inputs.gomod2nix}/builder"
          { inherit gomod2nix; };

        okta-aws-cli =
          let
            src = inputs.okta-aws-cli;

            inherit (src) lastModifiedDate;
            year = builtins.substring 0 4 lastModifiedDate;
            month = builtins.substring 4 2 lastModifiedDate;
            day = builtins.substring 6 2 lastModifiedDate;

            version = "unstable-${year}-${month}-${day}";
          in
          pkgs.callPackage ./. {
            inherit (gomod2nix-builder) buildGoApplication;
            inherit src version;
            inherit (src) shortRev;
          };

        devshell = import "${inputs.devshell}" { nixpkgs = pkgs; };
      in
      {
        apps.generate-gomod2nix-toml = flake-utils.lib.mkApp {
          drv = generate-gomod2nix-toml;
        };

        devShells.default = devshell.mkShell {
          devshell.packages = okta-aws-cli.nativeBuildInputs;
          devshell.motd = "";
          devshell.name = "okta-aws-cli";
        };

        packages.default = okta-aws-cli;
      });
}
