{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  # il server polystrata-lmcache gira solo su mattone
  full = osConfig.networking.hostName == "mattone";
  model = "qwen3.6-35b-a3b-hauhau-q4_k_m";
in {
  home.packages = lib.optionals full [pkgs.pi-coding-agent];

  # Provider locale: polystrata-lmcache (~/git/palmathron/polystrata-lmcache),
  # API OpenAI-compatibile su 127.0.0.1:8003. Nessuna chiave richiesta.
  home.file.".pi/agent/models.json" = lib.mkIf full {
    text = builtins.toJSON {
      providers.polystrata = {
        baseUrl = "http://127.0.0.1:8003/v1";
        api = "openai-completions";
        apiKey = "none";
        models = [
          {
            id = model;
            name = "Qwen3.6 35B-A3B (polystrata-lmcache)";
            reasoning = true;
            input = ["text" "image"];
            contextWindow = 262144;
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
