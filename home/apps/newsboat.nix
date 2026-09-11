{pkgs, ...}: {
  programs.newsboat = {
    enable = true;
    package = pkgs.newsboat;

    # Normal links open in your browser.
    browser = "$BROWSER";

    autoReload = false;
    reloadThreads = 5;

    # 0 = unlimited articles per feed.
    maxItems = 0;

    autoFetchArticles = {
      enable = true;
      onCalendar = "hourly";
    };

    autoVacuum = {
      enable = true;
      onCalendar = "weekly";
    };

    urls = [
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCG1ll_JKswdPuwc2xcMINrQ";
        title = "John Kleinbauer";
        tags = [
          "youtube"
          "radio"
          "electronics"
        ];
      }

      {
        url = "http://makingembeddedsystems.libsyn.com/rss";
        title = "Making Embedded Systems";
        tags = [
          "podcast"
          "embedded"
        ];
      }

      {
        url = "https://api.substack.com/feed/podcast/865289/s/339273.rss";
        title = "Casey Muratori";
        tags = [
          "podcast"
          "software"
        ];
      }
    ];

    queries = {};

    extraConfig = ''
      # Play the current article with mpv.
      macro p set browser "${pkgs.mpv}/bin/mpv --player-operation-mode=pseudo-gui -- %u &"; open; set browser "$BROWSER"
    '';
  };
}
