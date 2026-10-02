{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.home.opencode;

  agents = [ "monday" ];
  skills = [
    "commit-conventions"
    "budget-categorize"
  ];
in
{
  options.sqwer.home.opencode = {
    enable = lib.mkEnableOption "OpenCode";
    package = lib.mkPackageOption pkgs.llm-agents "opencode2" { nullable = false; };
  };

  config = lib.mkIf cfg.enable {
    sqwer.home.mcp.enable = true;

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

        experimental.policies = [
          {
            action = "provider.use";
            effect = "deny";
            resource = "opencode";
          }
        ];

        formatter = true;
        share = "disabled";
        update = "disable";
      };

      cli.theme.name = "rosepine";

      agents = lib.listToAttrs (map (name: lib.nameValuePair name ./agents/${name}.md) agents);

      skills = lib.listToAttrs (map (name: lib.nameValuePair name ./skills/${name}/SKILL.md) skills);
    };

    home.packages = [ pkgs.llm-agents.nono ];

    home.shellAliases.oc =
      let
        nono = lib.getExe pkgs.llm-agents.nono;
      in
      "${nono} run --profile nolabs-ai/opencode --allow-cwd ${cfg.package.pname}";
  };
}
