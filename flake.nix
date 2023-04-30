{
  description = ''
    A collection of various wallpapers, packed with a Nix Flake
    for easier organization and curation.
  '';

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;
    genSystems = lib.genAttrs [
      # Add more systems if they are supported
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ];
    pkgsFor = nixpkgs.legacyPackages;
    version = props.version + "+date=" + (mkDate (self.lastModifiedDate or "19700101")) + "_" + (self.shortRev or "dirty");

    props = builtins.fromJSON (builtins.readFile ./nix/props.json);

    mkDate = longDate: (lib.concatStringsSep "-" [
      (builtins.substring 0 4 longDate)
      (builtins.substring 4 2 longDate)
      (builtins.substring 6 2 longDate)
    ]);
  in {
    overlays.default = _: prev: rec {
      wallpkgs = prev.callPackage ./nix/default.nix {
        stdenv = prev.stdenvNoCC;
        inherit version;
      };

      catppuccin = prev.callPackage ./nix/default.nix {
        style = "catppuccin";
      };
    };
    packages = genSystems (system:
      (self.overlays.default null pkgsFor.${system})
      // {
        default = self.packages.${system}.wallpkgs;
      });

    formatter = genSystems (system: pkgsFor.${system}.alejandra);
  };
}
