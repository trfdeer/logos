{ lib, config, ... }:

let
  cfg = config.sqwer.home.tmux;
in
{
  options.sqwer.home.tmux = {
    enable = lib.mkEnableOption "Enable tmux";
    prefixKey = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "C-a";
      description = "Set prefix key";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      sensibleOnTop = true;
      escapeTime = 0;
      historyLimit = 20000;
      mouse = true;
      terminal = "tmux-256color";
      prefix = cfg.prefixKey;
    };
  };
}
