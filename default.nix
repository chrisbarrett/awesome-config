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

  tyrannical = pkgs.stdenv.mkDerivation {
    name = "awesome-tyrannical";
    phases = "installPhase";
    src = pkgs.fetchFromGitHub {
      owner = "Elv13";
      repo = "tyrannical";
      rev = "9c336ea0fd636e05d47856949e9a8a856590f254";
      sha256 = "0j2k2bdrb7gyb8h8j5r4wr91wj3hzfw5mk74hh0dp7536fr41mnw";
    };
    installPhase = ''
      DEST=$out/etc/lua/tyrannical
      mkdir -p $DEST
      cp -r $src/* $DEST
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
      --add-flags "--search ${awesome-config}/etc/awesome" \
      --add-flags "--search ${tyrannical}/etc/lua"
  '';
}
