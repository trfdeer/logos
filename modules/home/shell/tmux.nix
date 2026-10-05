{ lib, config, ... }:

let
  cfg = config.logos.home.tmux;
in
{
  options.logos.home.tmux = {
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
      keyMode = "vi";
      mouse = false;
      terminal = "tmux-256color";
      prefix = cfg.prefixKey;
    };
  };
}
