{ pkgs }: {
  packages = with pkgs; [
    # Theming
    bibata-cursors
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
