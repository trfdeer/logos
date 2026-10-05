{ lib, config, ... }:
{
  options.logos.home.starship = {
    enable = lib.mkEnableOption "Enable Starship prompt" // {
      default = true;
    };
  };

  config = lib.mkIf config.logos.home.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = config.logos.home.zsh.enable;
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
