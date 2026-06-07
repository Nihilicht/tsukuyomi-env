{
  outputs = { self, ... }: {
    # Using 'nixosModules' to satisfy the flake schema check
    nixosModules.default = { config, lib, pkgs, ... }: 
      let
        core = import ./core.nix { inherit pkgs; };
        devPath = builtins.getEnv "NIX_DEV_DOTFILES";
        
        # Strict validation: Path exists + is a git repo + correct remote
        isDev = 
          let
            gitConfigPath = "${devPath}/.git/config";
            expectedRemote = "url = https://github.com/Nihilicht/tsukuyomi-env.git";
          in
            devPath != "" 
            && builtins.pathExists gitConfigPath
            && lib.strings.hasInfix expectedRemote (builtins.readFile gitConfigPath);
        
        # The "Smart Switch": Symlink to local path in dev, Copy to Nix store in pure
        mkSource = path:
          if isDev
          then config.lib.file.mkOutOfStoreSymlink "${devPath}/${path}"
          else ./${path};
      in {
        options.myEnv.enable = lib.mkEnableOption "My Environment";
        config = lib.mkIf config.myEnv.enable {
          # 1. Auto-install all packages from core.nix
          home.packages = core.packages;
          # 2. Auto-link all configs from core.nix
          xdg.configFile = builtins.listToAttrs (map (path: {
            name = path;
            value = { source = mkSource path; };
          }) core.configs);
        };
      };
  };
}
