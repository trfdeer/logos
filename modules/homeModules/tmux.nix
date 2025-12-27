{ lib, config, ... }:
{
  options = {
    sqwer.tmux.enable = lib.mkEnableOption "Enable tmux";
    sqwer.tmux.prefixKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Set prefix key";
    };
  };

  config = lib.mkIf config.sqwer.tmux.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      sensibleOnTop = true;
      escapeTime = 0;
      historyLimit = 20000;
      mouse = true;
      terminal = "tmux-256color";
    }
    // lib.optionalAttrs (config.sqwer.tmux.prefixKey != "") {
      prefix = config.sqwer.tmux.prefixKey;
    };
  };
}
