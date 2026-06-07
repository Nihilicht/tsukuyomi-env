{ pkgs }: {
  packages = with pkgs; [
    # Compositor & Session
    hyprland
    uwsm
    
    # Shell & Desktop
    quickshell
    rofi-wayland
    kitty
    dolphin
    
    # System Utilities
    grim
    slurp
    satty
    pavucontrol
    wl-clipboard
    cliphist
    
    # CLI Tools & Shell
    starship
    atuin
    zoxide
    jq
    
    # Theming
    bibata-cursors
  ];
  configPath = ./.; 
}
