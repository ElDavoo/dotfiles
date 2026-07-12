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
    shellAliases = {
      lofi = "mpv --no-video https://www.youtube.com/watch?v=jfKfPfyJRdk";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };
}
