{ config, ... }: {
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
  ];

  services.hermes-agent = {
    enable = true;
    user = "dave";
    group = "users";
    stateDir = "/home/dave/hermes";
    createUser = false;
    container.enable = false;
    extraDependencyGroups = [
      "messaging"
      "voice"
      "hindsight"
      "web"
      "google"
      "computer-use"
      "cli"
    ];
    environmentFiles = [ "/home/dave/hermes/.env" ];
    environment = {
      HERMES_STREAM_READ_TIMEOUT = "1000000";
      HERMES_STREAM_STALE_TIMEOUT = "1000000";
      TELEGRAM_HOME_CHANNEL_THREAD_ID = "2999565";
      TELEGRAM_HOME_CHANNEL = "573963993";
      TELEGRAM_ALLOWED_USERS = "573963993";
    };

    # ── Model ──────────────────────────────────────────────────────────
    settings = {

      #approvals.gateway_timeout
      approvals = {
        gateway_timeout = 0;
        mode = "smart";
      };

      model = {
        default = "deepseek/deepseek-v4-flash";
        provider = "openrouter";
        timeout = 0;
        request_timeout_seconds = 0;
      };

      provider_routing = {
        data_collection = "deny";
      };

      custom_providers = [
        {
          name = "GPU";
          base_url = "http://127.0.0.1:8001/";
          model = "qwen3.6";
          request_timeout_seconds = 0;
        }
        {
          name = "CPU";
          base_url = "http://127.0.0.1:8002/";
          model = "qwen3.54b";
          request_timeout_seconds = 0;
        }
      ];
      toolsets = [ "all" ];
      max_turns = 100;
      terminal = {
        backend = "local";
        cwd = ".";
        timeout = 18000;
      };

      browser = {
        inactivity_timeout = 18000;
      };

      compression = {
        enabled = true;
        threshold = 0.85;
      };

      auxiliary = {
        # We are blocked while using compression anyway
        compression = {
          model = "qwen3.6";
          provider = "GPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        vision = {
          model = "qwen3.54b";
          max_concurrency = 1;
          provider = "CPU";
          timeout = 18000;
        };
        web_extract = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        session_search = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        title_generation = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        approval = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        triage_specifier = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        kanban_decomposer = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        profile_describer = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        skills_hub = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        mcp = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
        curator = {
          model = "qwen3.54b";
          provider = "CPU";
          max_concurrency = 1;
          timeout = 18000;
        };
      };

      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };

      agent = {
        max_turns = 60;
        #verbose = true;
        reasoning_effort = "high";
        gateway_timeout = 0;
        restart_drain_timeout = 60;
        gateway_notify_interval = 1000;
      };

      # Plugin
      plugins.enabled = [
        "rtk-rewrite"
      ];

      streaming = {
        enabled = true;
        transport = "draft";
      };

      platforms = {
        telegram = {
          enabled = true;
          allowed_chats = [ 573963993 ];
          extra = {
            rich_messages = false;
            dm_topics = [
              {
                chat_id = 573963993;
                topics = [
                  {
                    name = "General";
                    icon_color = 7322096;
                    thread_id = 2999565;
                  }
                ];
              }
            ];
          };
        };

      };

      unauthorized_dm_behavior = "ignore";
      timezone = "Europe/Paris";

      display = {
        compact = true;
        tool_progress = "verbose";

        platforms = {
          telegram = {
            tool_progress = "verbose";
          };
        };

        show_reasoning = true;
      };

      stt = {
        enabled = true;
        provider = "local";
        local = {
          model = "large-v3";
        };
      };

    };

    # ── Secrets ────────────────────────────────────────────────────────

    # ── Documents ──────────────────────────────────────────────────────
    #documents = {
    #  "USER.md" = ./documents/USER.md;
    #};

    # ── MCP Servers ────────────────────────────────────────────────────
    mcpServers.cua-driver = {
      command = "/run/current-system/sw/bin/steam-run";
      args = [
        "/home/dave/hermes/.local/bin/cua-driver"
        "mcp"
      ];
      env = {
        WAYLAND_DISPLAY = "wayland-1";
        XDG_RUNTIME_DIR = "/run/user/1000";
        DISPLAY = ":0";
        XCURSOR_SIZE = "24";
        XCURSOR_THEME = "Adwaita";
      };
    };

    # ── Container options ──────────────────────────────────────────────
    #container = {
    #  image = "ubuntu:26.04";
    #  backend = "docker";
    #  hostUsers = [ "dave" ];
    #  extraVolumes = [ "/home/dave/hermes:/real:rw" ];
    #d};

    # ── Service tuning ─────────────────────────────────────────────────
    addToSystemPackages = true;
    restart = "always";
    restartSec = 5;
  };

}
