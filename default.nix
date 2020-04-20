{ pkgs ? import <nixpkgs> {} }:

let
  # Materialise a bridging config file so pkgs required by the config are installed and available.

  entrypoint = with pkgs; writeText "awesome-entrypoint-lua" (
    callPackage ./entrypoint.lua.nix {
      inherit pkgs;
      scripts = callPackage ./scripts.nix {};
      rofi = withCLocale rofi "rofi";
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

  withCLocale = pkg: name: pkgs.symlinkJoin {
    inherit name;
    paths = [pkg];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram "$out/bin/$name" --set LC_ALL C
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
  # Wrap configuration so that we attempt to resolve modules from
  # ~/.config/awesome/src, falling back to the config packed into the store.
  postBuild = ''
    wrapProgram "$out/bin/awesome" \
      --add-flags "--config ${awesome-config}/etc/awesome/entrypoint.lua" \
      --add-flags "--search ~/.config/awesome/src" \
      --add-flags "--search ${awesome-config}/etc/awesome"
  '';
}
