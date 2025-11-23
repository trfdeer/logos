{ lib, config, ... }:
{
  options = {
    sqwer.helix.enable = lib.mkEnableOption "Enable Helix Editor";
  };

  config = lib.mkIf config.sqwer.helix.enable {
    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "catppuccin_mocha";
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
