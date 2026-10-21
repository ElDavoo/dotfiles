{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  # il server polystrata-lmcache gira solo su mattone
  full = osConfig.networking.hostName == "mattone";
  model = "qwen3.8-flash-next";
in {
  home.packages = lib.optionals full [pkgs.pi-coding-agent];

  # Provider locale: polystrata-lmcache (~/git/palmathron/polystrata-lmcache),
  # API OpenAI-compatibile su gpu-proxy (127.0.0.1:8005), che avvia Flash-Next alla prima richiesta. Nessuna chiave richiesta.
  home.file.".pi/agent/models.json" = lib.mkIf full {
    text = builtins.toJSON {
      providers.polystrata = {
        baseUrl = "http://127.0.0.1:8005/v1";
        api = "openai-completions";
        apiKey = "none";
        models = [
          {
            id = model;
            name = "Qwen3.8 Flash-Next (polystrata-lmcache)";
            reasoning = true;
            input = ["text"];
            contextWindow = 180000;
            maxTokens = 32768;
            cost = {
              input = 0;
              output = 0;
              cacheRead = 0;
              cacheWrite = 0;
            };
          }
        ];
      };
    };
  };
}
