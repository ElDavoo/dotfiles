# Xbox wireless controller via Bluetooth (xpadneo driver).
# Il bluetooth di base è già configurato in services.nix (con Experimental
# = true, necessario per il livello batteria dei controller Xbox). Qui
# aggiungiamo solo il driver xpadneo, che offre rumble e mappatura corretta.
_: {
  hardware.xpadneo.enable = true;

  # Alcuni controller Xbox restano bloccati in un loop di pairing: con
  # JustWorksRepairing = "always" bluez riaccetta la riassociazione senza
  # richiedere conferma, risolvendo la riconnessione.
  hardware.bluetooth.settings.General.JustWorksRepairing = "always";

  # I controller Xbox richiedono più tempo per stabilire la connessione:
  # FastConnectable riduce la latenza di riconnessione dopo il pairing.
  hardware.bluetooth.settings.General.FastConnectable = true;
}
