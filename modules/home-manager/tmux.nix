{ lib, config, ... }:
{
  options = {
    sqwer.tmux.enable = lib.mkEnableOption "Enable tmux";
  };

  config = lib.mkIf config.sqwer.tmux.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      mouse = true;
      terminal = "tmux-256color";
    };
  };
}
