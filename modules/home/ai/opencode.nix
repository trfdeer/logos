{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.logos.home.opencode;

  agents = [
    "monday"
    "victor"
  ];
  skills = [
    "commit-conventions"
    "budget-categorize"
  ];
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
      ];

      settings = {
        model = "hyper/glm-5.3-flash";
        agents = {
          title.model = "hyper/glm-5.3-flash";
        };

        plugins = [
          "opencode-models-discovery@1.6.1"
        ];

        websearch.provider = "random";

        formatter = true;
        share = "disabled";
        update = "disable";
      };

      cli.theme.name = "rosepine";

      agents = lib.listToAttrs (map (name: lib.nameValuePair name ./agents/${name}.md) agents);

      skills = lib.listToAttrs (map (name: lib.nameValuePair name ./skills/${name}/SKILL.md) skills);
    };

    home.shellAliases.oc = cfg.package.pname;
  };
}
