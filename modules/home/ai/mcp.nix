{
  lib,
  config,
  ...
}:
let
  cfg = config.logos.home.mcp;
in
{
  options.logos.home.mcp = {
    enable = lib.mkEnableOption "shared MCP servers";
  };

  config = lib.mkIf cfg.enable {
    programs.mcp = {
      enable = true;
      servers = {
        mcp-nixos.command = "mcp-nixos";
        context7.url = "https://mcp.context7.com/mcp";
        microsoft-learn.url = "https://learn.microsoft.com/api/mcp";
        linear.url = "https://mcp.linear.app/mcp";
      };

    };
  };
}
