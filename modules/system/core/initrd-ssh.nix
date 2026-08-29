{
  lib,
  config,
  pkgs,
  ...
}:
let
  id = config.sqwer.identity;
  cfg = config.sqwer.system.boot.initrdSsh;
  tsCfg = cfg.tailscale;
  netCfg = config.sqwer.system.network;

  tsSocket = "/run/tailscale-initrd.sock";

  luksDevices = lib.filterAttrs (_: dev: dev.enable or false) config.boot.initrd.luks.devices;

  unlockCmd = lib.concatStringsSep " && " (
    map (n: "${pkgs.systemd}/bin/systemd-cryptsetup unlock ${n}") (builtins.attrNames luksDevices)
  );

  tsUpScript = pkgs: ts: ''
    T="${pkgs.tailscale}/bin/tailscale" --socket=${tsSocket}
    timeout 20 $T up --hostname=${ts.hostname} || true
    # `up` returns before tailscale0 is programmed with the node address;
    # wait for it so sshd can bind it.
    i=0
    while [ $i -lt 20 ]; do
      [ -n "$($T ip -4 2>/dev/null)" ] && break
      i=$((i + 1))
      sleep 1
    done
  '';

  manualDns =
    if cfg.network.mode == "manual" && cfg.network.manualConfiguration != null then
      cfg.network.manualConfiguration.dns
    else
      [ ];

  resolvConfServers =
    if manualDns != [ ] then
      manualDns
    else
      [
        "1.1.1.1"
        "8.8.8.8"
      ];

  manualNetwork = {
    matchConfig.Name = cfg.interface;
    address = [ cfg.network.manualConfiguration.address ];
    networkConfig.DNS = manualDns;
    routes = [
      {
        routeConfig.Gateway = cfg.network.manualConfiguration.gateway;
      }
    ];
  };

  dhcpNetwork = {
    matchConfig.Name = cfg.interface;
    networkConfig.DHCP = "yes";
  };

  listenAll = !tsCfg.enable || cfg.publicFallback || tsCfg.ip == null;

  listenConfig = lib.optionalString (!listenAll) ''
    ListenAddress 127.0.0.1
    ListenAddress ${tsCfg.ip}
  '';

  sshExtraConfig = ''
    ${listenConfig}
    ForceCommand ${unlockCmd}
  '';
in
{
  options.sqwer.system.boot.initrdSsh = {
    enable = lib.mkEnableOption ''
      SSH access in the initrd for remote LUKS unlock.
      Unlock: ssh -tt -p <port> root@<initrd-ssh-target> — the LUKS
      unlock runs automatically; enter the passphrase when prompted.
      No shell is provided (sshd ForceCommand; -tt is required to
      allocate the tty the passphrase prompt needs).
    '';

    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "Port for the initrd SSH daemon.";
    };

    hostKey = lib.mkOption {
      type = lib.types.str;
      default = "/etc/ssh/initrd_host_ed25519_key";
      description = ''
        Path of the initrd SSH host key. It is used both as the sshd
        HostKey inside the initrd and as the source appended to the
        initrd via `boot.initrd.secrets` (supported by systemd-boot).
        Generated during activation if missing, so run
        `nixos-rebuild switch` once before the first remote unlock.
        On impermanence hosts this should point into the preserved tree.
      '';
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = id.sshPublicKeys;
      description = "Authorized keys for root in the initrd SSH daemon.";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = if netCfg.enable then netCfg.interface else "en*";
      description = "Interface glob to configure in the initrd.";
    };

    publicFallback = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Listen on all interfaces in the initrd. When
        `tailscale.enable` and `tailscale.ip` are set and this is
        false, the initrd sshd binds only the tailnet address, making
        the unlock window reachable solely over the tailnet.
      '';
    };

    network = lib.mkOption {
      type = lib.types.submodule {
        options = {
          mode = lib.mkOption {
            type = lib.types.enum [
              "auto"
              "manual"
            ];
            default = "auto";
            description = ''
              How the initrd interface is configured. `auto` uses DHCP;
              `manual` uses `manualConfiguration`.
            '';
          };

          manualConfiguration = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  address = lib.mkOption {
                    type = lib.types.strMatching ".+/.+";
                    example = "203.0.113.5/24";
                    description = "Static IPv4 address in CIDR notation.";
                  };

                  gateway = lib.mkOption {
                    type = lib.types.str;
                    example = "203.0.113.1";
                    description = "Default gateway for the initrd interface.";
                  };

                  dns = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                    example = [
                      "203.0.113.53"
                    ];
                    description = ''
                      DNS servers for the initrd interface. When empty,
                      public resolvers are used for the tailscale path.
                    '';
                  };
                };
              }
            );
            default = null;
            example = lib.literalExpression ''
              {
                address = "203.0.113.5/24";
                gateway = "203.0.113.1";
                dns = [ "192.0.2.53" ];
              }
            '';
            description = "Static configuration used when mode is `manual`.";
          };
        };
      };
      default = { };
      description = "IP configuration for the initrd interface.";
    };

    tailscale = {
      enable = lib.mkEnableOption ''
        Tailscale in the initrd, so unlock SSH can be reached over
        the tailnet without exposing a public port. The initrd node
        is a separate tailnet identity that must be enrolled once on
        the running system, then picked up by the next rebuild:

        ```
        mkdir -p <stateDir>
        tailscaled --statedir=<stateDir> \
          --socket=/run/tailscale-initrd-setup.sock \
          --tun=userspace-networking &
        tailscale --socket=/run/tailscale-initrd-setup.sock up \
          --auth-key=<key> --hostname=<hostname>
        tailscale --socket=/run/tailscale-initrd-setup.sock ip -4
        kill %tailscaled
        ```

        Record the printed IP in `tailscale.ip`, rebuild, and set
        `publicFallback = false` to close the public unlock port.
      '';

      stateDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/tailscale-initrd";
        description = ''
          Runtime directory for the initrd tailscaled state (the node
          key lives in `tailscaled.state` here). The whole directory is
          appended to the initrd via `boot.initrd.secrets`, so it must
          contain the enrolled state when the system is built. On
          impermanence hosts this must point into the preserved tree
          (tailscaled replaces its state file atomically, so symlink
          preservation breaks); the enrollment procedure is documented
          on `tailscale.enable`.
        '';
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "${config.sqwer.platform.hostName}-initrd";
        description = "Tailscale hostname announced by the initrd node.";
      };

      ip = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "100.101.102.103";
        description = ''
          Tailnet IPv4 of the initrd node. Used to bind sshd when
          `publicFallback` is false.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !tsCfg.enable || cfg.publicFallback || tsCfg.ip != null;
        message = "sqwer.system.boot.initrdSsh: set tailscale.ip when publicFallback is false";
      }
      {
        assertion = cfg.network.mode != "manual" || cfg.network.manualConfiguration != null;
        message = "sqwer.system.boot.initrdSsh: network.mode is manual but network.manualConfiguration is null";
      }
      {
        assertion = luksDevices != { };
        message = "sqwer.system.boot.initrdSsh: enabled but no boot.initrd.luks.devices found — did the storage layout set encrypted.method = \"ssh\"?";
      }
    ];

    warnings = lib.optionals (tsCfg.enable && cfg.publicFallback) [
      "sqwer.system.boot.initrdSsh: publicFallback is on, the initrd sshd is reachable on the public interface — disable it after enrolling the initrd tailnet node"
    ];

    boot.initrd = {
      enable = true;

      network = {
        enable = true;
        ssh = {
          enable = true;
          inherit (cfg)
            port
            authorizedKeys
            ;
          hostKeys = [ cfg.hostKey ];
          extraConfig = sshExtraConfig;
        };
      };

      secrets = lib.mkIf tsCfg.enable (
        lib.mkDefault {
          "${tsCfg.stateDir}" = null;
        }
      );

      kernelModules = lib.optionals tsCfg.enable [ "tun" ];

      systemd = {
        enable = true;

        contents = lib.mkIf tsCfg.enable {
          "/etc/resolv.conf".text = lib.concatMapStrings (s: "nameserver ${s}\n") resolvConfServers;
        };

        network.networks."00-initrd-ssh" =
          if cfg.network.mode == "manual" && cfg.network.manualConfiguration != null then
            manualNetwork
          else
            dhcpNetwork;

        storePaths =
          lib.optionals tsCfg.enable [
            "${pkgs.tailscale}/bin/tailscale"
            "${pkgs.tailscale}/bin/tailscaled"
            (pkgs.writeShellScript "initrd-ssh-up" (tsUpScript pkgs tsCfg))
          ]
          ++ [ "${pkgs.systemd}/bin/systemd-cryptsetup" ];

        services = lib.mkMerge [
          (lib.optionalAttrs tsCfg.enable {
            tailscale-initrd = {
              description = "Tailscale node for initrd SSH unlock";
              wantedBy = [ "initrd.target" ];
              after = [
                "systemd-networkd.service"
                "initrd-nixos-copy-secrets.service"
              ];
              before = [ "initrd-ssh-up.service" ];
              unitConfig.DefaultDependencies = false;
              serviceConfig = {
                ExecStart = "${pkgs.tailscale}/bin/tailscaled --statedir=${tsCfg.stateDir} --socket=${tsSocket}";
                Restart = "on-failure";
              };
            };

            initrd-ssh-up = {
              description = "Activate initrd tailscale identity";
              wantedBy = [ "initrd.target" ];
              after = [ "tailscale-initrd.service" ];
              before = [ "sshd.service" ];
              unitConfig.DefaultDependencies = false;
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                TimeoutStartSec = 90;
                ExecStart = "${pkgs.writeShellScript "initrd-ssh-up" (tsUpScript pkgs tsCfg)}";
              };
            };
          })

          {
            sshd = {
              after = lib.optionals tsCfg.enable [ "initrd-ssh-up.service" ];
              wants = lib.optionals tsCfg.enable [ "initrd-ssh-up.service" ];
            };
          }
        ];
      };
    };

    system.activationScripts.initrdSshHostKey =
      lib.stringAfter
        [
          "groups"
          "users"
        ]
        ''
          mkdir -p ${dirOf cfg.hostKey}
          if [ ! -e ${cfg.hostKey} ]; then
            ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" -f ${cfg.hostKey}
          fi
          ${lib.optionalString tsCfg.enable "mkdir -p ${tsCfg.stateDir}"}
        '';

    preservation.preserveAt."/persistent/nixos".files =
      lib.mkIf (config.sqwer.system.impermanence.enable && !lib.hasPrefix "/persistent" cfg.hostKey)
        [
          {
            file = cfg.hostKey;
            how = "symlink";
            configureParent = true;
          }
        ];
  };
}
