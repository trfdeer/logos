{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.home.opencode;
in
{
  options.logos.home.opencode = {
    enable = lib.mkEnableOption "OpenCode";
    package = lib.mkPackageOption pkgs.llm-agents "opencode2" { nullable = false; };
  };

  config = lib.mkIf cfg.enable {
    logos.home.mcp.enable = true;

    programs.opencode2 = {
      enable = true;
      package = cfg.package;
      enableMcpIntegration = true;
      extraPackages = [
        pkgs.mcp-nixos
        pkgs.bun
        pkgs.uv
      ];

      settings = {
        model = "hyper/glm-5.3-flash";
        agents = {
          title.model = "hyper/glm-5.3-flash";
        };

        websearch.provider = "random";

        disabled_providers = [ "opencode" ];
        formatter = true;
        share = "disabled";
        update = "disable";
      };

      cli.theme.name = "rosepine";
    };

    home.activation.copyOpencodeSkillsAgents = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      rm -rf -- "$HOME/.config/opencode/skills" "$HOME/.config/opencode/agents"
      cp -r --no-preserve=mode ${./skills} "$HOME/.config/opencode/skills"
      cp -r --no-preserve=mode ${./agents} "$HOME/.config/opencode/agents"
    '';

    home.shellAliases.oc = cfg.package.pname;
  };
}
