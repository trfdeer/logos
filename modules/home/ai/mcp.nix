{
  lib,
  config,
  ...
}:
let
  cfg = config.sqwer.home.mcp;
in
{
  options.sqwer.home.mcp = {
    enable = lib.mkEnableOption "shared MCP servers";
  };

  config = lib.mkIf cfg.enable {
    # Written to ~/.config/mcp/mcp.json; individual agents (e.g. opencode2
    # via `enableMcpIntegration`) merge these into their own server config.
    programs.mcp = {
      enable = true;
      servers = {
        mcp-nixos.command = "mcp-nixos";

        context7.url = "https://mcp.context7.com/mcp";

        microsoft-learn.url = "https://learn.microsoft.com/api/mcp";

        podman = {
          command = "bun";
          args = [
            "x"
            "podman-mcp-server@0.0.15"
          ];
        };
      };
    };
  };
}
