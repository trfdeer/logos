{ lib, config, ... }:
{
  options = {
    sqwer.starship.enable = lib.mkEnableOption "Enable Starship prompt";
  };

  config = lib.mkIf config.sqwer.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = config.sqwer.zsh.enable;
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

    catppuccin.starship = {
      enable = true;
      flavor = "mocha";
    };
  };
}
