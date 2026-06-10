{ pkgs }: {
  packages = with pkgs; [
    # Theming
    bibata-cursors
    catppuccin-gtk
    adwaita-icon-theme
    rubik
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  configs = [
    "gtk-3.0"
    "gtk-4.0"
    "hypr"
    "kitty"
    "quickshell"
    "rofi"
    "satty"
  ];
  configPath = ./.; 
}
