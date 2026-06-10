{ pkgs }: {
  packages = with pkgs; [
    # Theming
    bibata-cursors
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
