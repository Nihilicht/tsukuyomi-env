{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    qml-language-server = {
      url = "github:cushycush/qml-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # Standard Home Manager module export
    homeManagerModules.default = { config, lib, pkgs, nixataraxia ? null, userData ? null, ... }: 
      let
        core = import ./core.nix { inherit pkgs; };
        
        sattyWrapped = if nixataraxia != null then nixataraxia.wrapWithDeps {
          package = pkgs.satty;
          deps = [ pkgs.wl-clipboard ];
        } else pkgs.writeShellScriptBin "satty" ''
          export PATH="${pkgs.wl-clipboard}/bin:$PATH"
          exec ${pkgs.satty}/bin/satty "$@"
        '';

        devPath = builtins.getEnv "TSUKUYOMI_DEV_PATH";
        
        # Strict validation: Path exists + is a git repo + correct remote
        isDev = 
          if config.env.devPath != null then true
          else if devPath != "" then
            let
              gitConfigPath = "${devPath}/.git/config";
              expectedRemote = "url = https://github.com/Nihilicht/tsukuyomi-env.git";
            in
              builtins.pathExists gitConfigPath
              && lib.strings.hasInfix expectedRemote (builtins.readFile gitConfigPath)
          else false;
        
        # The "Smart Switch": Symlink to local path in dev, Copy to Nix store in pure
        mkSource = path:
          let
            targetPath = if config.env.devPath != null then config.env.devPath else devPath;
          in
          if isDev
          then config.lib.file.mkOutOfStoreSymlink "${targetPath}/${path}"
          else ./${path};
      in {
        options.env = {
          enable = lib.mkEnableOption "Desktop Environment";
          devPath = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Absolute path to the local repository for development/symlinking.";
          };
        };

        config = lib.mkIf config.env.enable {
          assertions = [
            {
              # tsukuyomi-env acts purely as an isolated environment config.
              # The host system MUST provide the entry points.
              assertion = (builtins.elem pkgs.uwsm config.home.packages) 
                       || (builtins.elem pkgs.hyprland config.home.packages)
                       || (config.wayland.windowManager.hyprland.enable or false);
              message = "tsukuyomi-env requires `uwsm` and/or `hyprland` to be provided by the host configuration. Please add them to your environment.";
            }
          ];

          # 1. Auto-install all packages from core.nix
          home.packages = core.packages;

          # 2. Auto-link all configs from core.nix
          xdg.configFile = builtins.listToAttrs (map (path: {
            name = path;
            value = { 
              source = mkSource path; 
              recursive = !isDev; # Enable recursion in pure mode to allow file-level merging
            };
          }) core.configs) // {
            # 3. Dynamically generated Lua module for absolute paths!
            # Note: In dev mode (isDev=true), this entry may cause a collision if ~/.config/hypr 
            # is a symlink to your local folder. Home Manager handles this by throwing an error.
            # To fix this in dev mode, you'd usually exclude 'hypr' from core.configs and 
            # link its contents individually, or ignore paths.lua in your local repo.
            "hypr/paths.lua".text = ''
              return {
                rofi = "${pkgs.rofi}/bin/rofi",
                grim = "${pkgs.grim}/bin/grim",
                slurp = "${pkgs.slurp}/bin/slurp",
                satty = "${sattyWrapped}/bin/satty",
                cliphist = "${pkgs.cliphist}/bin/cliphist",
                wl_copy = "${pkgs.wl-clipboard}/bin/wl-copy",
                wl_paste = "${pkgs.wl-clipboard}/bin/wl-paste",
                kitty = "${pkgs.kitty}/bin/kitty",
                dolphin = "${pkgs.kdePackages.dolphin}/bin/dolphin",
                helium = "${pkgs.helium}/bin/helium",
                quickshell = "${pkgs.quickshell}/bin/qs",
                pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol"
              }
            '';
          };
        };
      };

    # Define overlay for quickshell and qml-language-server
    overlays.default = final: prev: {
      qml-language-server = inputs.qml-language-server.packages.${prev.stdenv.hostPlatform.system}.default;
      helium = inputs.helium.packages.${prev.stdenv.hostPlatform.system}.default;
    };

    # Backwards compatibility / NixOS module mapping
    nixosModules.default = self.homeManagerModules.default;
  };
}
