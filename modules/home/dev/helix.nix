{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.logos.home.helix = {
    enable = lib.mkEnableOption "Enable Helix Editor";
    grammars = lib.mkOption {
      type = with lib.types; nullOr (listOf str);
      default = null;
      description = ''
        Tree-sitter grammar names to build into Helix.
        `null` builds the stock package with every grammar.
      '';
    };
  };

  config = lib.mkIf config.logos.home.helix.enable {
    programs.helix = {
      enable = true;
      defaultEditor = true;
      package =
        let
          helixGrammars =
            if config.logos.home.helix.grammars == null then
              pkgs.helix
            else
              pkgs.helix.override {
                lockedGrammars = lib.getAttrs config.logos.home.helix.grammars (
                  lib.importJSON "${pkgs.path}/pkgs/by-name/he/helix/grammars.json"
                );
              };
        in
        helixGrammars;
      settings = {
        theme = "rose_pine";
        editor = {
          mouse = true;
          bufferline = "always";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
          indent-guides = {
            render = true;
            skip-levels = 1;
          };
          true-color = true;
        };
      };
      languages = {
        language = [
          {
            name = "nix";
            language-servers = [ "nixd" ];
            formatter.command = "nixfmt";
            auto-format = true;
          }
          {
            name = "rust";
            language-servers = [ "rust-analyzer" ];
            auto-format = true;
          }
        ];
        language-server.nixd = {
          command = "nixd";
        };
        language-server.rust-analyzer = {
          check.command = "clippy";
          cachePriming.enable = false;
          rustfmt.extraArgs = [
            "--config"
            "group_imports=StdExternalCrate,imports_granularity=Crate"
          ];
        };
      };
    };
  };
}
