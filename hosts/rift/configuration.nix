{
  config,
  pkgs,
  profiles,
  ...
}:
let
  id = config.sqwer.identity;
in
{
  imports = [
    profiles.hardware.ct.proxmox-lxc
  ];

  sqwer.system = {
    ssh.enable = true;

    tailscale = {
      enable = true;
      acceptRoutes = false;
      operator = id.username;
    };

    games.terraria = {
      enable = true;
      dataDir = "/srv/games/terraria";
      noUPnP = true;
      openFirewall = true;
      groupMembers = [ id.username ];

      instances.world_m1 = {
        enable = true;
        maxPlayers = 4;
        memoryMax = "1.5G";
        cpuQuota = "50%";
        worldSize = "medium";
        port = 7777;
      };
    };

    games.minecraft = {
      enable = true;
      groupMembers = [ id.username ];
      plugins = with pkgs.sqpkgs.minecraftPlugins; [
        geysermc
        floodgate
      ];
    };
  };

  # ------------------------------------------------------------
  # Host-specific Home Manager deltas
  # ------------------------------------------------------------
  home-manager.users.${id.username}.imports = [ ./home-configuration.nix ];
}
