{ lib, config, ... }:
{
  options.sqwer.home.starship = {
    enable = lib.mkEnableOption "Enable Starship prompt";
  };

  config = lib.mkIf config.sqwer.home.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = config.sqwer.home.zsh.enable;
      settings = {
        add_newline = false;
        right_format = "$time";
        time = {
          disabled = false;
          style = "bold bright-black";
          format = "[$time]($style)";
        };
        line_break.disabled = true;
      };
    };
  };
}
