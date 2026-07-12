# Firefox gestito in modo dichiarativo via home-manager.
# Il profilo riusa la directory esistente (24pbhc1e.default-esr-...),
# così cronologia, login e cookie restano al loro posto.
# Le estensioni "note" arrivano da rycee/firefox-addons (input flake);
# quelle di nicchia restano installabili a mano da AMO.
{
  pkgs,
  config,
  ...
}: let
  # pkgs.firefox-addons è fornito dall'overlay in flake.nix.
  addons = pkgs.firefox-addons;
in {
  programs.firefox = {
    enable = true;

    # Path XDG (nuovo default): ~/.config/mozilla/firefox.
    # La dir del profilo è stata spostata qui dalla vecchia ~/.mozilla/firefox.
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    profiles.default = {
      # Riusa il profilo esistente: Firefox identifica il profilo dal path,
      # quindi puntando a questa dir non si perde nulla dei dati attuali.
      id = 0;
      isDefault = true;
      path = "24pbhc1e.default-esr-1717858650152";

      # force = true serve perché il profilo ha già estensioni installate
      # a mano: permette a home-manager di prenderne il controllo.
      extensions = {
        force = true;
        packages = with addons; [
          ublock-origin
          sponsorblock
          noscript
          metamask
          tampermonkey
          facebook-container
          simple-tab-groups
          user-agent-string-switcher
          cookie-editor
          tree-style-tab
          snowflake
          wallabagger
          joplin-web-clipper
        ];
      };

      # Preferenze about:config portate dal profilo attuale.
      settings = {
        # Avvio: ripristina la sessione precedente.
        "browser.startup.page" = 3;

        # Content blocking in modalità "strict".
        "browser.contentblocking.category" = "strict";
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.annotate_channels.strict_list.enabled" = true;

        # Fingerprinting + HTTPS-only.
        "privacy.fingerprintingProtection" = true;
        "dom.security.https_only_mode" = true;

        # Do Not Track / Global Privacy Control.
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;

        # Rimozione parametri di tracciamento dagli URL.
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;

        # Bounce tracking protection.
        "privacy.bounceTrackingProtection.mode" = 1;

        # Pulizia alla chiusura (cookie preservati, cronologia/form no).
        "privacy.sanitize.timeSpan" = 0;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "privacy.clearSiteData.cookiesAndStorage" = false;
        "privacy.clearSiteData.historyFormDataAndDownloads" = true;

        # Container tabs abilitate.
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;

        # Regione di ricerca.
        "browser.search.region" = "FR";

        # New tab: niente storie/sponsor/Pocket, sì highlights.
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = true;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

        # Media / DRM.
        "media.eme.enabled" = true;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;

        # UX.
        "general.autoScroll" = true;
        "browser.tabs.warnOnOpen" = false;
      };
    };
  };
}
