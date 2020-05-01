self: super: {
  rofiWithTheme = config: super.symlinkJoin {
    name = "rofi-with-theme";
    paths = [super.rofi];
    buildInputs = [super.makeWrapper];
    postBuild = ''
      wrapProgram "$out/bin/rofi" \
        --set LC_ALL C \
        --add-flags "-config ${super.writeText "rofi-config.rasi" config}"
    '';
  };
}
