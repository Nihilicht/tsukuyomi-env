{ pkgs }: {
  packages = with pkgs; [
    # Compositor & Session
    hyprland
    uwsm
    
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
