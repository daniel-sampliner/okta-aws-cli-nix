{ lib
, buildGoApplication
, errcheck
, go-tools
, goconst
, gocyclo
, gofumpt
, golint
, gotools

, shortRev
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

  postPatch = ''
    sed -i -E '/^[[:blank:]]+Version = /s/ "(.*)"$/ "\1-g${shortRev}"/' internal/config/config.go
  '';

  postCheck = ''
    "$GOPATH"/bin/okta-aws-cli --version \
      | grep -q -- '^okta-aws-cli version .*-g${shortRev}$'
  '';

  NIX_DEBUG=0;
}
