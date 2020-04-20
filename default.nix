{ pkgs ? import <nixpkgs> {} }:

let
  # Materialise a bridging config file so pkgs required by the config are installed and available.

  entrypoint = with pkgs; writeText "awesome-entrypoint-lua" (
    callPackage ./entrypoint.lua.nix {
      inherit pkgs;
      scripts = callPackage ./scripts.nix {};
    }
  );

  # Expose lua config files at $out/etc/awesome.

  awesome-config = pkgs.stdenv.mkDerivation {
    name = "awesome-config";
    phases = "installPhase";
    src = ./src;
    installPhase = ''
      DEST=$out/etc/awesome
      mkdir -p $DEST
      cp -r $src/* $DEST
      cp ${entrypoint} $DEST/entrypoint.lua
    '';
  };
in

# Finally, pack everything together

pkgs.symlinkJoin {
  name = "awesomewm-with-config";
  buildInputs = [pkgs.makeWrapper];
  paths = [
    pkgs.awesome
    pkgs.xorg.xbacklight
    awesome-config
  ];
  postBuild = ''
    wrapProgram "$out/bin/awesome" \
    --add-flags "--config ${awesome-config}/etc/awesome/entrypoint.lua" \
    --add-flags "--search ~/.config/awesome/src"
  '';
}
