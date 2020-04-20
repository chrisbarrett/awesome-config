{ pkgs ? import <nixpkgs> {} }: with pkgs;

let
  # Materialise a bridging config file so pkgs required by the config are installed and available.

  entrypoint = writeText "awesome-entrypoint-lua" (
    callPackage ./entrypoint.lua.nix {
      inherit pkgs;
      scripts = callPackage ./scripts.nix {};
      rofi = withCLocale rofi "rofi";
    }
  );

  withCLocale = pkg: name: pkgs.symlinkJoin {
    inherit name;
    paths = [pkg];
    buildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram "$out/bin/$name" --set LC_ALL C
    '';
  };

  # Expose lua config files at $out/etc/awesome.

  awesome-config = stdenv.mkDerivation {
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

symlinkJoin {
  name = "awesomewm-with-config";
  buildInputs = [makeWrapper];
  paths = [
    awesome
    xorg.xbacklight
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
