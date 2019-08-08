{ pkgs ? import <nixpkgs> {} }:
rec {
	prisonArchitect = pkgs.callPackages ./the-eye/linux/prisonArchitect.nix {};
}
