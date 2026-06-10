{ pkgs }: {
  packages = with pkgs; [
    # Theming
    bibata-cursors
    catppuccin-gtk
    adwaita-icon-theme
    rubik
    nerd-fonts.jetbrains-mono
  ];
  configs = [
    "hypr"
    "kitty"
    "quickshell"
    "rofi"
    "satty"
  ];
  configPath = ./.; 
}
