{ lib, config, ... }:
let
  cfg = config.sqwer.system.firewall;
  cfgNetwork = config.sqwer.system.network;
  cfgTailscale = config.sqwer.system.tailscale;

  # Zoning is a layer on top of the nftables backend of `networking.firewall`:
  #
  #   - a zone matching interfaces renders its port sets through
  #     `networking.firewall.interfaces.<if>` (glob keys such as "en*" are
  #     valid; the nft backend emits `iifname <if> <proto> dport { ... } accept`)
  #     and its `extraRules` as `iifname { ... } <rule>` in `extraInputRules`;
  #   - a zone matching source ranges renders ports and `extraRules` raw as
  #     `ip saddr { ... } <rule>`;
  #   - a zone with neither (or with both, for the range part) applies to every
  #     interface;
  #   - a zone with both interfaces and ranges allows on its interfaces AND
  #     from its ranges (union of matches).
  #
  # Multiple zones sharing an interface union their port sets.
  #
  # Baseline is strict-deny: no global ports, ICMP echo requests blocked
  # (re-open per zone via `extraRules = [ "icmp type echo-request accept" ];`
  # or raise `networking.firewall.allowPing`), reverse-path filter in loose
  # mode for the tailscale mesh (netfilter-mode nodivert + subnet routes
  # produce asymmetric replies).
  zoneNames = lib.attrNames cfg.zones;

  # `lan`/`mesh` seeds apply only while the zone declares no interfaces,
  # so a host assignment to `match.interfaces` wins.
  seeds = lib.filterAttrs (_: v: v != [ ]) {
    lan = lib.optional cfgNetwork.enable cfgNetwork.interface;
    mesh = lib.optional cfgTailscale.enable "tailscale0";
  };

  zoneIfaces =
    n:
    if cfg.zones.${n}.match.interfaces != [ ] then
      cfg.zones.${n}.match.interfaces
    else
      seeds.${n} or [ ];
  zoneRanges = n: cfg.zones.${n}.match.ranges;

  ifaceZones = lib.filter (n: zoneIfaces n != [ ]) zoneNames;
  rawZones = lib.filter (n: zoneIfaces n == [ ] || zoneRanges n != [ ]) zoneNames;

  portExpr =
    ports: ranges:
    lib.concatStringsSep ", " (
      map toString ports ++ map (r: "${toString r.from}-${toString r.to}") ranges
    );

  tcpRule =
    zone:
    lib.optionalString (zone.allowedTCPPorts != [ ] || zone.allowedTCPPortRanges != [ ]) ''
      tcp dport { ${portExpr zone.allowedTCPPorts zone.allowedTCPPortRanges} } accept
    '';
  udpRule =
    zone:
    lib.optionalString (zone.allowedUDPPorts != [ ] || zone.allowedUDPPortRanges != [ ]) ''
      udp dport { ${portExpr zone.allowedUDPPorts zone.allowedUDPPortRanges} } accept
    '';

  iifPrefix =
    n:
    let
      ifaces = zoneIfaces n;
      quoted = lib.concatStringsSep ", " (map (i: ''"${i}"'') ifaces);
    in
    lib.optionalString (ifaces != [ ]) (
      if builtins.length ifaces == 1 then "iifname ${quoted} " else "iifname { ${quoted} } "
    );

  saddrPrefix =
    n:
    lib.optionalString (
      zoneRanges n != [ ]
    ) "ip saddr { ${lib.concatStringsSep ", " (zoneRanges n)} } ";

  # full rule list for a zone rendered without the `interfaces` option
  rawZoneRules =
    n:
    saddrPrefix n
    + lib.concatStringsSep ("\n" + saddrPrefix n) (
      lib.filter (r: r != "") (
        map (lib.removeSuffix "\n") (
          [
            (tcpRule cfg.zones.${n})
            (udpRule cfg.zones.${n})
          ]
          ++ cfg.zones.${n}.extraRules
        )
      )
    );

  # interface -> union of the port sets of every zone matching it
  ifaceZoneNames = lib.zipAttrs (map (n: lib.genAttrs (zoneIfaces n) (_: n)) ifaceZones);
  interfacePorts = lib.mapAttrs (_: names: {
    allowedTCPPorts = lib.unique (lib.concatMap (n: cfg.zones.${n}.allowedTCPPorts) names);
    allowedTCPPortRanges = lib.unique (lib.concatMap (n: cfg.zones.${n}.allowedTCPPortRanges) names);
    allowedUDPPorts = lib.unique (lib.concatMap (n: cfg.zones.${n}.allowedUDPPorts) names);
    allowedUDPPortRanges = lib.unique (lib.concatMap (n: cfg.zones.${n}.allowedUDPPortRanges) names);
  }) ifaceZoneNames;

  extraInputRules = lib.concatStringsSep "\n" (
    lib.filter (s: s != "") (
      (map rawZoneRules rawZones)
      ++ lib.concatMap (n: map (r: iifPrefix n + r) cfg.zones.${n}.extraRules) ifaceZones
    )
  );

  zoneOpts = {
    options = {
      match = {
        interfaces = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [
            "en*"
            "tailscale0"
          ];
          description = ''
            Interface names or globs this zone covers. An empty list makes
            the zone match every interface (modulo `ranges`).
          '';
        };
        ranges = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "10.1.0.0/24" ];
          description = ''
            Source CIDRs this zone covers. Zone rules are additionally
            rendered raw as `ip saddr` matches in
            `networking.firewall.extraInputRules`.
          '';
        };
      };

      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        example = [
          22
          80
          443
        ];
        description = "TCP ports this zone accepts.";
      };

      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        example = [
          53
          443
        ];
        description = "UDP ports this zone accepts.";
      };

      allowedTCPPortRanges = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.port);
        default = [ ];
        example = [
          {
            from = 5060;
            to = 5080;
          }
        ];
        description = "TCP port ranges this zone accepts ({ from, to }).";
      };

      allowedUDPPortRanges = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.port);
        default = [ ];
        description = "UDP port ranges this zone accepts ({ from, to }).";
      };

      extraRules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "tcp dport { 5060-5080 } accept"
          "ip protocol esp accept"
        ];
        description = ''
          Raw nftables rules, prefixed with the zone match
          (`iifname`/`ip saddr`) and appended to the firewall's
          `input-allow` chain.
        '';
      };
    };
  };
in
{
  options.sqwer.system.firewall = {
    enable = lib.mkEnableOption "zone-based nftables firewall";

    zones = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule zoneOpts);
      default = { };
      example = {
        lan = {
          match.interfaces = [ "en*" ];
          allowedTCPPorts = [
            22
            80
            443
          ];
        };
      };
      description = ''
        Firewall zones. Every allow must be attached to a zone; traffic
        matching no zone rule is dropped by the strict-deny baseline.
        `lan` is seeded with `sqwer.system.network.interface` and `mesh`
        with `tailscale0` (when those modules are enabled) as long as the
        zone's `match.interfaces` is left empty.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # selects `networking.firewall.backend = "nftables"`
    networking.nftables.enable = true;

    networking.firewall = {
      enable = true;

      # strict-deny baseline (hosts may raise these via mkForce)
      allowPing = lib.mkDefault false;
      # tailscale mesh + subnet routes under netfilter-mode=nodivert
      # produce asymmetric reply paths
      checkReversePath = lib.mkDefault "loose";

      interfaces = interfacePorts;
      extraInputRules = lib.mkIf (extraInputRules != "") extraInputRules;
    };

    assertions = [
      {
        assertion = config.networking.firewall.backend == "nftables";
        message = "sqwer.system.firewall requires the nftables backend (networking.nftables.enable = true)";
      }
    ];
  };
}
