{ pkgs }: rec {

  keyboardShow = pkgs.writeShellScript "keyboard-show" ''
    setxkbmap -query | grep 'layout:' | awk '{print $2}'
  '';

  keyboardDvorak = pkgs.writeShellScript "keyboard-dvorak" ''
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option 'caps:ctrl_modifier'
    ${pkgs.xcape}/bin/xcape -e 'Caps_Lock=Escape'
    setxkbmap 'us(dvp)'
    xmodmap "$HOME/.Xmodmap"
  '';

  keyboardQwerty = pkgs.writeShellScript "keyboard-qwerty" ''
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option 'caps:ctrl_modifier'
    ${pkgs.xcape}/bin/xcape -e 'Caps_Lock=Escape'
    setxkbmap 'us'
  '';

  keyboardToggle = pkgs.writeShellScript "keyboard-toggle" ''
    LAYOUT=$(${keyboardShow})

    if [[ "$LAYOUT" == 'us(dvp)' ]]; then
      ${keyboardQwerty}
    else
      ${keyboardDvorak}
    fi
  '';

}
