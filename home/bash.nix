_: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      lofi = "mpv --no-video https://www.youtube.com/watch?v=jfKfPfyJRdk";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };
}
