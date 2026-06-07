{
  outputs = { self, ... }: {
    # Using 'nixosModules' to satisfy the flake schema check
    nixosModules.default = { config, lib, pkgs, ... }: 
      let
        core = import ./core.nix { inherit pkgs; };
        isDev = builtins.getEnv "NIX_DEV_DOTFILES" == "1";
        # The "Smart Switch": Symlink in dev, Copy in pure
        mkSource = path:
          if isDev
          then config.lib.file.mkOutOfStoreSymlink "${self.outPath}/${path}"
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
