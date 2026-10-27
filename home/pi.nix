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

  # settings.json resta un file normale perché pi ci scrive da sé (packages, lastChangelogVersion): qui si
  # fondono solo le chiavi gestite, il resto non si tocca.
  # httpIdleTimeoutMs: Flash-Next scrive un parametro non stringa di una tool call (gli `edits` di `edit`) tutto
  # in una volta alla fine, senza byte né heartbeat nel frattempo; a ~5 tok/s un edit grande supera i 300 s di
  # default e pi chiude la connessione ("terminated"), all'infinito.  0: nessun timeout di inattività.
  home.activation.piSettings = lib.mkIf full (lib.hm.dag.entryAfter ["writeBoundary"] ''
    f="$HOME/.pi/agent/settings.json"
    run mkdir -p "$(dirname "$f")"
    [ -s "$f" ] || echo '{}' > "$f"
    tmp="$(mktemp)"
    ${pkgs.jq}/bin/jq '. + {httpIdleTimeoutMs: 0}' "$f" > "$tmp" && run mv "$tmp" "$f" || rm -f "$tmp"
  '');

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
