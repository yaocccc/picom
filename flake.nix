{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      overlay = final: prev: {
        picom = prev.picom.overrideAttrs (oldAttrs: rec {
          version = "master";
          src = ./.;
          dontVersionCheck = true;
          nativeBuildInputs =
            (oldAttrs.nativeBuildInputs or [ ])
            ++ (with prev; [
              asciidoc
            ]);
          buildInputs =
            (oldAttrs.buildInputs or [ ])
            ++ (with prev; [
              pcre
            ]);
        });
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };
      in
      rec {
        packages.picom = pkgs.picom;
        packages.default = pkgs.picom;
      }
    )
    // {
      overlays.default = overlay;
    };
}
