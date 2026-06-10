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
    "hypr"
    "kitty"
    "quickshell"
    "rofi"
    "satty"
  ];
  configPath = ./.; 
}
