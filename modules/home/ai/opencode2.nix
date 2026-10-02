# Home Manager module for OpenCode v2.
#
# Converted from the upstream v1 module
# (https://github.com/nix-community/home-manager/blob/master/modules/programs/opencode.nix)
# with the v2 configuration schema (https://opencode.ai/v2/docs/config/).
#
# Notable v1 -> v2 changes reflected here:
# - MCP servers live under `mcp.servers` (not directly under `mcp`) and use
#   `disabled` instead of `enabled` to keep a server from connecting.
# - Permissions are an ordered list of `{ action, resource, effect }` rules
#   (last matching rule wins), not a per-tool map, so plain JSON preserves
#   rule order and the ordered-DAG renderer is no longer needed.
# - TUI/client settings moved from `tui.json` to `cli.json`
#   (https://opencode.ai/v2/docs/cli/config/).
# - The `opencode serve` web service is gone; v2 exposes the web UI via
#   `opencode pair`, so the v1 systemd/launchd web unit is dropped.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    ;

  cfg = config.programs.opencode2;

  jsonFormat = pkgs.formats.json { };

  # Transform a `programs.mcp.servers` entry into the OpenCode v2 server
  # shape (https://opencode.ai/v2/docs/mcp-servers/).
  toOpencode2Shape =
    s:
    let
      isRemote = s ? url && s.url != null;
      renderedEnv = lib.hm.mcp.renderEnv (p: "{file:${p}}") (s.env or { });
    in
    {
      type = if isRemote then "remote" else "local";
    }
    // (
      if isRemote then
        { inherit (s) url; } // lib.optionalAttrs (s.headers or { } != { }) { inherit (s) headers; }
      else
        {
          command = [ s.command ] ++ (s.args or [ ]);
        }
        // lib.optionalAttrs (renderedEnv != { }) { environment = renderedEnv; }
    );

  # Resolve the effective enabled state (`enabled`/`disabled` are mutually
  # exclusive in programs.mcp.servers). Mirrors lib.hm.mcp.resolveEnabled,
  # which is not exported.
  resolveEnabled =
    server:
    if server ? enabled && server.enabled != null then
      server.enabled
    else if server ? disabled && server.disabled != null then
      !server.disabled
    else
      null;

  transformedMcpServers =
    if cfg.enableMcpIntegration && config.programs.mcp.enable && config.programs.mcp.servers != { } then
      lib.mapAttrs (
        _: server:
        # transformMcpServer resolves `disabled` away into `enabled` and
        # strips it, so re-derive the v2 `disabled` field afterwards.
        lib.hm.mcp.transformMcpServer {
          inherit server;
          extraTransforms = [ toOpencode2Shape ];
          exclude = [
            "args"
            "env"
            "enabled"
          ];
        }
        // (
          let
            resolved = resolveEnabled server;
          in
          lib.optionalAttrs (resolved != null && resolved != true) { disabled = !resolved; }
        )
      ) config.programs.mcp.servers
    else
      { };

  settingsMcp = cfg.settings.mcp or { };

  # Merge MCP servers: transformed `programs.mcp.servers` + user settings,
  # with user settings taking precedence. `mcp` must be v2-shaped, i.e. the
  # servers live under `mcp.servers`.
  mergedMcp = {
    servers = transformedMcpServers // (settingsMcp.servers or { });
  }
  // builtins.removeAttrs settingsMcp [ "servers" ];

  mergedSettings =
    builtins.removeAttrs cfg.settings [ "mcp" ]
    // (lib.optionalAttrs (mergedMcp.servers != { } || settingsMcp != { }) { mcp = mergedMcp; });

  packageWithExtraPackages =
    if cfg.package != null && cfg.extraPackages != [ ] then
      pkgs.symlinkJoin {
        inherit (cfg.package) meta;
        name = "${lib.getName cfg.package}-wrapped-${lib.getVersion cfg.package}";
        paths = [ cfg.package ];
        preferLocalBuild = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/${cfg.package.meta.mainProgram} \
            --suffix PATH : ${lib.makeBinPath cfg.extraPackages}
        '';
      }
    else
      cfg.package;

  normalizeDirectory =
    name: source:
    if lib.isPath source then
      source
    else
      pkgs.runCommandLocal name { } ''
        if [[ ! -d ${lib.escapeShellArg (toString source)} ]]; then
          echo ${lib.escapeShellArg "programs.opencode2.skills must be a directory"} >&2
          exit 1
        fi
        ln -s ${lib.escapeShellArg (toString source)} "$out"
      '';

  normalizeSkill =
    source:
    pkgs.runCommandLocal "opencode-skill" { } ''
      source=${lib.escapeShellArg (toString source)}
      if [[ -d "$source" ]]; then
        ln -s "$source" "$out"
      elif [[ -f "$source" ]]; then
        mkdir "$out"
        ln -s "$source" "$out/SKILL.md"
      else
        echo "OpenCode skill source must be a file or directory: $source" >&2
        exit 1
      fi
    '';

  # OpenCode v1 keys that no longer work in a v2 `opencode.json`, and where
  # their configuration moved.
  deprecatedKeys = {
    autoshare = "share";
    autoupdate = "update";
    agent = "default_agent";
    permission = "permissions (ordered list of { action, resource, effect } rules)";
    plugin = "plugins";
    theme = "programs.opencode2.cli (written to cli.json)";
    keybinds = "programs.opencode2.cli (written to cli.json)";
    tui = "programs.opencode2.cli (written to cli.json)";
  };
in
{
  meta.maintainers = with lib.maintainers; [ delafthi ];

  options.programs.opencode2 = {
    enable = mkEnableOption "OpenCode v2";

    package = mkPackageOption pkgs "opencode" { nullable = true; };

    extraPackages = mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = literalExpression "[ pkgs.uv ]";
      description = "Extra packages available to OpenCode.";
    };

    enableMcpIntegration = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to integrate the MCP servers config from
        {option}`programs.mcp.servers` into
        {option}`programs.opencode2.settings.mcp.servers`.

        Note: Settings defined in {option}`programs.mcp.servers` are merged
        with {option}`programs.opencode2.settings.mcp.servers`, with OpenCode
        settings taking precedence.
      '';
    };

    settings = mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        model = "anthropic/claude-sonnet-4-5";
        default_agent = "build";
        update = "notify";
        share = "manual";
        permissions = [
          {
            action = "shell";
            resource = "git push *";
            effect = "ask";
          }
        ];
      };
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/opencode/opencode.json`.
        See <https://opencode.ai/v2/docs/config/> for the documentation.

        The `mcp` key must be v2-shaped: servers live under
        {option}`mcp.servers`, with optional global `mcp.timeout`.

        The `permissions` key is an ordered list of
        `{ action, resource, effect }` rules where the last matching rule
        wins, so rule order in the generated JSON is significant.

        The `plugin` key from OpenCode v1 is now `plugins`, which accepts a
        list of plugin names, local paths to plugin directories or files,
        derivations (e.g. `fetchFromGitHub`), or
        `{ package, options }` objects for plugins that take options.

        Note, `"$schema": "https://opencode.ai/config.json"` is automatically
        added to the configuration.
      '';
    };

    cli = mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        theme = {
          name = "tokyonight";
          mode = "system";
        };
        keybinds.leader = "alt+b";
      };

      description = ''
        CLI (terminal client) configuration written to
        {file}`$XDG_CONFIG_HOME/opencode/cli.json`.

        This includes theme, keybinds, cursor, tabs, diffs, notifications,
        and other terminal-only options. It replaces the OpenCode v1
        `tui.json`.

        See <https://opencode.ai/v2/docs/cli/config/> for the documentation.

        Note that `"$schema": "https://opencode.ai/v2/cli.json"` is
        automatically added. Unknown settings are rejected by OpenCode v2.
      '';
    };

    context = lib.mkOption {
      type = lib.types.either lib.types.lines lib.types.path;
      default = "";
      description = ''
        Global context for OpenCode.

        The value is either:
        - Inline content as a string
        - A path to a file containing the content

        The configured content is written to
        {file}`$XDG_CONFIG_HOME/opencode/AGENTS.md`.
      '';
      example = lib.literalExpression ''
        '''
          # TypeScript Project Rules

          ## External File Loading

          CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

          Instructions:

          - Do NOT preemptively load all references - use lazy loading based on actual need
          - When loaded, treat content as mandatory instructions that override defaults
          - Follow references recursively when needed
        '''
      '';
    };

    commands = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
      default = { };
      description = ''
        Custom slash commands for opencode.

        This option can either be:
        - An attribute set defining commands
        - A path to a directory containing multiple command files

        If an attribute set is used, the attribute name becomes the command filename,
        and the value is either:
        - Inline content as a string (creates `opencode/commands/<name>.md`)
        - A path to a file (creates `opencode/commands/<name>.md`)

        If a path is used, it is expected to contain command files.
        The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/commands/`.

        Alternatively, commands can be defined inline in
        {option}`programs.opencode2.settings.commands` as
        `{ description, template }` entries.
      '';
      example = lib.literalExpression ''
        {
          changelog = '''
            # Update Changelog Command

            Update CHANGELOG.md with a new entry for the specified version.
            Usage: /changelog [version] [change-type] [message]
          ''';
          fix-issue = ./commands/fix-issue.md;
          commit = '''
            # Commit Command

            Create a git commit with proper message formatting.
            Usage: /commit [message]
          ''';
        }
      '';
    };

    agents = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
      default = { };
      description = ''
        Custom agents for opencode.

        This option can either be:
        - An attribute set defining agents
        - A path to a directory containing multiple agent files

        If an attribute set is used, the attribute name becomes the agent filename,
        and the value is either:
        - Inline content as a string (creates `opencode/agents/<name>.md`)
        - A path to a file (creates `opencode/agents/<name>.md`)

        If a path is used, it is expected to contain agent files.
        The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/agents/`.

        Agent frontmatter uses the v2 fields (`mode` accepting `primary`,
        `subagent`, or `all`, and `permissions` as an ordered rule list).
        Agents can also be defined inline in
        {option}`programs.opencode2.settings.agents`.
      '';
      example = lib.literalExpression ''
        {
          code-reviewer = '''
            ---
            description: Reviews changes for correctness and regressions
            mode: subagent
            permissions:
              - action: edit
                resource: "*"
                effect: deny
            ---

            You are a senior software engineer specializing in code reviews.
            Focus on code quality, security, and maintainability.
          ''';
          documentation = ./agents/documentation.md;
        }
      '';
    };

    skills = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.lines
          lib.types.path
          lib.types.str
        ]
      )) lib.types.path;
      default = { };
      description = ''
        Custom skills for OpenCode.

        This option can be either:
        - An attribute set defining skills
        - A path to a directory containing skill folders

        If an attribute set is used, the attribute name becomes the
        skill directory name, and the value is either:
        - Inline content as a string (creates `opencode/skills/<name>/SKILL.md`)
        - A path to a file (creates `opencode/skills/<name>/SKILL.md`)
        - A path to a directory (creates `opencode/skills/<name>/` with all files)

        This also accepts Nix store paths, for example a skill directory
        from a package.

        If a path is used, it is expected to contain one folder per
        skill name, each containing a {file}`SKILL.md`. The directory is
        symlinked to {file}`$XDG_CONFIG_HOME/opencode/skills/`.

        Additional skill directories and URLs can be declared via the
        `skills` key in {option}`programs.opencode2.settings`.

        See <https://opencode.ai/v2/docs/skills/> for the documentation.
      '';
      example = lib.literalExpression ''
        {
          git-release = '''
            ---
            name: git-release
            description: Create consistent releases and changelogs
            ---

            ## What I do

            - Draft release notes from merged PRs
            - Propose a version bump
            - Provide a copy-pasteable `gh release create` command
          ''';

          # A skill can also be a directory containing SKILL.md and other files.
          data-analysis = ./skills/data-analysis;

          # A skill can also be a subdirectory within a package source (store path)
          beads = "''${pkgs.beads.src}/claude-plugin/skills/beads";
        }
      '';
    };

    themes = mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either jsonFormat.type lib.types.path)) lib.types.path;
      default = { };
      description = ''
        Custom themes for opencode.

        This option can either be:
        - An attribute set defining themes
        - A path to a directory containing multiple theme files

        If an attribute set is used, the attribute name becomes the theme filename,
        and the value is either:
        - An attribute set that is converted to a JSON file (creates `opencode/themes/<name>.json`)
        - A path to a file (creates `opencode/themes/<name>.json`)

        If a path is used, it is expected to contain theme files.
        The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/themes/`.

        Set `programs.opencode2.cli.theme.name` to enable the custom theme.
        Note that v2 themes declare a complete `base` token tree plus at
        least one `light` or `dark` hue palette.
        See <https://opencode.ai/v2/docs/themes/> for the documentation.
      '';
    };

    tools = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
      default = { };
      description = ''
        Custom tools for opencode.

        This option can either be:
        - An attribute set defining tools
        - A path to a directory containing multiple tool files

        If an attribute set is used, the attribute name becomes the tool filename,
        and the value is either:
        - Inline content as a string (creates `opencode/tools/<name>.ts`)
        - A path to a file (creates `opencode/tools/<name>.ts` or `opencode/tools/<name>.js`)

        If a path is used, it is expected to contain tool files.
        The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/tools/`.

        See <https://opencode.ai/v2/docs/tools/> for the documentation.
      '';
      example = lib.literalExpression ''
        {
          database-query = '''
            import { tool } from "@opencode-ai/plugin"

            export default tool({
              description: "Query the project database",
              args: {
                query: tool.schema.string().describe("SQL query to execute"),
              },
              async execute(args) {
                // Your database logic here
                return `Executed query: ''${args.query}`
              },
            })
          ''';

          # Or reference an existing file
          api-client = ./tools/api-client.ts;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !lib.isPath cfg.commands || lib.pathIsDirectory cfg.commands;
        message = "`programs.opencode2.commands` must be a directory when set to a path";
      }
      {
        assertion = !lib.isPath cfg.agents || lib.pathIsDirectory cfg.agents;
        message = "`programs.opencode2.agents` must be a directory when set to a path";
      }
      {
        assertion = !lib.isPath cfg.tools || lib.pathIsDirectory cfg.tools;
        message = "`programs.opencode2.tools` must be a directory when set to a path";
      }
      {
        assertion = !lib.isPath cfg.skills || lib.pathIsDirectory cfg.skills;
        message = "`programs.opencode2.skills` must be a directory when set to a path";
      }
      {
        assertion = !lib.isPath cfg.themes || lib.pathIsDirectory cfg.themes;
        message = "`programs.opencode2.themes` must be a directory when set to a path";
      }
    ];

    warnings = lib.optionals (cfg.settings != { }) (
      let
        found = lib.filter (k: deprecatedKeys ? ${k}) (lib.attrNames cfg.settings);
      in
      lib.optionals (found != [ ]) [
        ''
          programs.opencode2.settings contains OpenCode v1 keys that changed in v2:

          ${lib.concatStringsSep "\n" (map (k: "  - ${k} -> use ${deprecatedKeys.${k}}") found)}

          See https://opencode.ai/v2/docs/config/ for the v2 configuration schema.
        ''
      ]
    );

    home.packages = mkIf (packageWithExtraPackages != null) [ packageWithExtraPackages ];

    xdg.configFile = {
      "opencode/opencode.json" = mkIf (mergedSettings != { }) {
        source = jsonFormat.generate "opencode.json" (
          {
            "$schema" = "https://opencode.ai/config.json";
          }
          // mergedSettings
        );
      };

      "opencode/cli.json" = mkIf (cfg.cli != { }) {
        source = jsonFormat.generate "cli.json" (
          {
            "$schema" = "https://opencode.ai/v2/cli.json";
          }
          // cfg.cli
        );
      };

      "opencode/AGENTS.md" = (
        if lib.isPath cfg.context then
          { source = cfg.context; }
        else
          (mkIf (cfg.context != "") {
            text = cfg.context;
          })
      );

      "opencode/commands" = mkIf (lib.isPath cfg.commands) {
        source = cfg.commands;
        recursive = true;
      };

      "opencode/agents" = mkIf (lib.isPath cfg.agents) {
        source = cfg.agents;
        recursive = true;
      };

      "opencode/tools" = mkIf (lib.isPath cfg.tools) {
        source = cfg.tools;
        recursive = true;
      };

      "opencode/skills" = mkIf (lib.hm.strings.isPathLike cfg.skills) {
        source = normalizeDirectory "opencode-skills" cfg.skills;
        recursive = true;
      };

      "opencode/themes" = mkIf (lib.isPath cfg.themes) {
        source = cfg.themes;
        recursive = true;
      };
    }
    // lib.optionalAttrs (builtins.isAttrs cfg.commands) (
      lib.mapAttrs' (
        name: content:
        lib.nameValuePair "opencode/commands/${name}.md" (
          if lib.isPath content then { source = content; } else { text = content; }
        )
      ) cfg.commands
    )
    // lib.optionalAttrs (builtins.isAttrs cfg.agents) (
      lib.mapAttrs' (
        name: content:
        lib.nameValuePair "opencode/agents/${name}.md" (
          if lib.isPath content then { source = content; } else { text = content; }
        )
      ) cfg.agents
    )
    // lib.optionalAttrs (builtins.isAttrs cfg.tools) (
      lib.mapAttrs' (
        name: content:
        lib.nameValuePair "opencode/tools/${name}.ts" (
          if lib.isPath content then { source = content; } else { text = content; }
        )
      ) cfg.tools
    )
    // lib.mapAttrs' (
      name: content:
      if lib.isPath content && lib.pathIsDirectory content then
        lib.nameValuePair "opencode/skills/${name}" {
          source = content;
          recursive = true;
        }
      else if lib.hm.strings.isPathLike content && !lib.isPath content then
        lib.nameValuePair "opencode/skills/${name}" {
          source = normalizeSkill content;
          recursive = true;
        }
      else
        lib.nameValuePair "opencode/skills/${name}/SKILL.md" (
          if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
        )
    ) (if builtins.isAttrs cfg.skills then cfg.skills else { })
    // lib.optionalAttrs (builtins.isAttrs cfg.themes) (
      lib.mapAttrs' (
        name: content:
        lib.nameValuePair "opencode/themes/${name}.json" (
          if lib.isPath content then
            {
              source = content;
            }
          else
            {
              source = jsonFormat.generate "opencode-${name}.json" content;
            }
        )
      ) cfg.themes
    );
  };
}
