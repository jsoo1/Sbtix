{
  description = ''
    Sbtix generates a Nix definition that represents your SBT
    project's dependencies. It then uses this to build a Maven repo
    containing the stuff your project needs, and feeds it back to your
    SBT build.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-utils, nixpkgs, ... }:
    let
      portable = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = import nixpkgs { inherit system; }; in

        rec {
          defaultApp = apps.sbtix;

          apps.sbtix = {
            type = "app";
            program = "${packages.sbtix-tool}/bin/sbtix";
          };

          apps.sbtix-gen = {
            type = "app";
            program = "${packages.sbtix-tool}/bin/sbtix-gen";
          };

          apps.sbtix-gen-all = {
            type = "app";
            program = "${packages.sbtix-tool}/bin/sbtix-gen-all";
          };

          apps.sbtix-gen-all2 = {
            type = "app";
            program = "${packages.sbtix-tool}/bin/sbtix-gen-all2";
          };

          packages.sbtix-tool = import ./sbtix-tool.nix {
            inherit (pkgs) callPackage writeText writeScriptBin stdenv sbt;
          };
        });

      overlay = final: prev: {
        sbtix-tool = import ./sbtix-tool.nix {
          inherit (prev) callPackage writeText writeScriptBin stdenv sbt;
        };
      };
    in

    portable // { inherit overlay; };
}
