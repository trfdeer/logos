{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.system.games.terraria;

  enabledInstances = lib.filterAttrs (_: inst: inst.enable) cfg.instances;
  worldSizeMap = {
    small = 1;
    medium = 2;
    large = 3;
  };

  worldDifficultyMap = {
    classic = 0;
    expert = 1;
    master = 2;
    journey = 3;
  };

in
{
  options.sqwer.system.games.terraria = {
    enable = lib.mkEnableOption "Terraria game servers";

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/srv/games/terraria";
      description = "Base directory for terraria server data";
    };

    noUPnP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable UPnP.";
    };

    openFirewall = lib.mkEnableOption "Open firewall ports for instances.";

    groupMembers = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
      description = "Users to be added to terraria group.";
    };

    instances = lib.mkOption {
      description = "Terraria server instance";
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              enable = lib.mkEnableOption "Terraria instance ${name}";

              worldSize = lib.mkOption {
                type = lib.types.enum [
                  "small"
                  "medium"
                  "large"
                ];
                description = "world size";
                default = "medium";
              };

              worldDifficulty = lib.mkOption {
                type = lib.types.enum [
                  "classic"
                  "expert"
                  "master"
                  "journey"
                ];
                description = "world difficulty";
                default = "classic";
              };

              memoryMax = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "systemd memory limit for this Terraria instance (e.g. \"3G\").";
              };

              cpuQuota = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  systemd CPU quota for this Terraria instance.
                  Examples: "50%", "100%", "200%".
                '';
              };

              maxPlayers = lib.mkOption {
                type = lib.types.int;
                description = "Maximum number of players allowed";
                default = 9;
              };

              port = lib.mkOption {
                type = lib.types.port;
                description = "TCP port this instance listens on";
                default = 7777;
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = enabledInstances != { };
        message = "sqwer.system.games.terraria.enable is true, but no instances are enabled";
      }
      {
        assertion =
          lib.length (lib.unique (map (i: i.port) (lib.attrValues enabledInstances)))
          == lib.length (lib.attrValues enabledInstances);
        message = "sqwer.system.games.terraria: multiple instances are configured with the same port";
      }
    ];

    users.groups.terraria = { };

    users.users.terraria = {
      description = "Terraria server service user";
      group = "terraria";
      home = cfg.dataDir;
      isSystemUser = true;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 terraria terraria -"
      "d ${cfg.dataDir}/worlds 0750 terraria terraria -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall) (
      map (inst: inst.port) (lib.attrValues enabledInstances)
    );

    systemd.services = lib.mapAttrs' (
      name: inst:
      lib.nameValuePair "terraria-${name}" {
        description = "Terraria server (${name})";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          User = "terraria";
          Group = "terraria";
          UMask = 7;

          Type = "simple";
          TimeoutStopSec = "2min";
          WorkingDirectory = cfg.dataDir;

          # --- Hardening ---
          PrivateTmp = true;

          ProtectSystem = "strict";
          ProtectHome = true;

          NoNewPrivileges = true;

          RestrictSUIDSGID = true;
          RestrictRealtime = true;

          LockPersonality = true;

          CapabilityBoundingSet = "";
          AmbientCapabilities = "";

          ReadWritePaths = [
            cfg.dataDir
          ];

          ExecStart = ''
            ${pkgs.terraria-server}/bin/TerrariaServer \
              -port ${toString inst.port} \
              -maxplayers ${toString inst.maxPlayers} \
              -world "${cfg.dataDir}/worlds/${name}.wld" \
              -autocreate ${toString worldSizeMap.${inst.worldSize}} \
              -difficulty ${toString worldDifficultyMap.${inst.worldDifficulty}} \
              ${lib.optionalString cfg.noUPnP "-noupnp"}
          '';

          StandardOutput = "journal";
          StandardError = "journal";

          Restart = "on-failure";
        }
        // lib.optionalAttrs (inst.memoryMax != null) {
          MemoryMax = inst.memoryMax;
        }
        // lib.optionalAttrs (inst.cpuQuota != null) {
          CPUQuota = inst.cpuQuota;
        };
      }
    ) enabledInstances;

    users.extraGroups.terraria.members = cfg.groupMembers;
  };
}
