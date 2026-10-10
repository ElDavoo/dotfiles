_: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # Auto-start Hyprland on login on tty1. getty auto-logs "dave" into a
    # login shell, so .bash_profile runs; `uwsm check may-start` ensures we
    # only launch on tty1 at login (not over SSH, other TTYs, or nested shells).
    profileExtra = ''
      if uwsm check may-start; then
        exec uwsm start hyprland.desktop
      fi
    '';
    # Tutto quello che parte da un terminale diventa la prima vittima degli OOM
    # killer (kernel ed earlyoom), prima delle app grafiche che stanno a 200.
    # Alzare il proprio oom_score_adj non richiede privilegi e i figli lo
    # ereditano. Non sulla shell di login del tty1, da cui parte la sessione.
    initExtra = ''
      shopt -q login_shell || echo 1000 > /proc/$$/oom_score_adj 2>/dev/null
    '';
    shellAliases = {
      lofi = "mpv --no-video https://www.youtube.com/watch?v=jfKfPfyJRdk";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };
}
