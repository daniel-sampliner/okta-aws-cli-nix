{ lib
, buildGoApplication
, errcheck
, go-tools
, goconst
, gocyclo
, gofumpt
, golint
, gotools

, src
, version
}:
buildGoApplication {
  pname = "okta-aws-cli";
  inherit version src;

  modules = ./gomod2nix.toml;
  nativeBuildInputs = [
    errcheck
    go-tools
    goconst
    gocyclo
    gofumpt
    golint
    gotools
  ];
}
