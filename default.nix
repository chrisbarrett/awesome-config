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

  # Bundle 3rd-party Lua libs into a derivation for adding to the Lua path.

  luaLibraries = symlinkJoin {
    name = "awesomewm-lua-libs";
    paths = builtins.attrValues (import ./libs.nix {

      luaFromGithub = { name, owner, rev, sha256, repo ? name }: stdenv.mkDerivation {
        inherit name;
        phases = "installPhase";
        src = fetchFromGitHub { inherit repo owner rev sha256; };
        installPhase = ''
          DEST=$out/etc/lua/${name}
          mkdir -p $DEST
          cp -r $src/* $DEST
        '';
      };

    });
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
      --add-flags "--search ${luaLibraries}/etc/lua"
  '';
}
