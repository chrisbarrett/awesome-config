{ pkgs ? import <nixpkgs> {
  overlays = [(import ./overlays)];
}
}: with pkgs;

let
  rofiCustom = rofiWithTheme (callPackage ./rofi-theme.nix {});

  # Materialise a bridging config file so pkgs required by the config are installed and available.

  entrypoint = writeText "awesome-entrypoint-lua" (
    callPackage ./entrypoint.lua.nix {
      inherit pkgs;
      scripts = callPackage ./scripts.nix {};
    }
  );

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
  paths = [awesome rofiCustom];

  # Wrap configuration so that we attempt to resolve modules from
  # ~/.config/awesome/src, falling back to the config packed into the store.
  postBuild = ''
    wrapProgram "$out/bin/awesome" \
      --prefix PATH : '${xorg.xbacklight}/bin' \
      --set AWESOME_AUDIO_MANAGER_COMMAND '${pavucontrol}/bin/pavucontrol' \
      --set AWESOME_BROWSER_COMMAND '${chromium}/bin/chromium' \
      --set AWESOME_FILE_MANAGER_COMMAND '${gnome3.nautilus}/bin/nautilus' \
      --set AWESOME_LAUNCHER_COMMAND '${rofiCustom}/bin/rofi -show run' \
      --set AWESOME_TERMINAL_COMMAND '${gnome3.gnome-terminal}/bin/gnome-terminal' \
      --set AWESOME_WIFI_MANAGER_COMMAND 'nm-connection-editor' \
      --add-flags "--config ${awesome-config}/etc/awesome/entrypoint.lua" \
      --add-flags "--search ~/.config/awesome/src" \
      --add-flags "--search ${awesome-config}/etc/awesome" \
      --add-flags "--search ${luaLibraries}/etc/lua"
  '';
}
