final: prev: {
  terraria-server = prev.terraria-server.overrideAttrs (old: rec {
    version = "1.4.5.4";
    dontAutoPatchelf = true;
    #    autoPatchelfIgnoreMissingDeps = true;

    src = prev.fetchzip {
      url = "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${
        prev.lib.replaceStrings [ "." ] [ "" ] version
      }.zip";
      sha256 = "sha256-0yxPGpF86onS49M51tmFEvrs79BWykr3Z8VznVsfsI8=";
    };
  });
}
