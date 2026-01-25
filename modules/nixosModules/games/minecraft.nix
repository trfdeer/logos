{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sqwer.system.games.minecraft;
in
{
  options.sqwer.system.games.minecraft = {
    enable = lib.mkEnableOption "Minecraft Server";

    groupMembers = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
      description = "Users to be added to minecraft group.";
    };

    plugins = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = "Minecraft plugin packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      package = pkgs.sqpkgs.papermc;

      openFirewall = true;
      declarative = true;
      dataDir = "/srv/games/minecraft";

      serverProperties = {
        difficulty = 2; # peaceful, easy, normal, hard
        gamemode = 0; # survival, creative, adventure, sepctator
        max-players = 5;
      };
      jvmOpts = "-Xms1G -Xmx2G";
    };
    systemd.tmpfiles.rules =
      let
        pluginsDir = "${config.services.minecraft-server.dataDir}/plugins";
      in
      [
        "d ${pluginsDir} 0755 minecraft minecraft - -"
      ]
      ++ map (
        plugin:
        let
          jar = plugin.passthru.pluginJar or null;
        in
        assert lib.assertMsg (jar != null) "Plugin ${plugin.name} does not define passthru.pluginJar";
        "L+ ${pluginsDir}/${plugin.pname}.jar - - - - ${plugin}/${jar}"
      ) cfg.plugins;

    users.extraGroups.minecraft.members = cfg.groupMembers;

  };
}
