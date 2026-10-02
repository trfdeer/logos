{ config, ... }:
{
  sqwer.home = {
    tmux.enable = false;
    opencode.enable = true;
    _1password.enable = true;

    git = {
      enable = true;
      inherit (config.sqwer.identity.git) identities;
    };

    hax = {
      enable = true;
      provider = "hyper";
      model = "glm-5.3-flash";
      effort = "high";

      secretEnv = {
        HYPER_API_KEY = "op://pc2farykihzsz2kaadkggavqu4/hyper/opencode2";
      };

      settings = {
        theme = "dark";
        show_reasoning = true;
        providers.hyper = {
          display_name = "Charm Hyper";
          api = "openai-completions";
          base_url = "https://hyper.charm.land/v1";
          api_key_env = "HYPER_API_KEY";
        };
      };
    };
  };
}
