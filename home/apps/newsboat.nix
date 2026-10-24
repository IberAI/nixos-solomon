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

      {
        url = "https://blog.rust-lang.org/feed.xml";
        title = "Rust Blog";
        tags = [
          "rust"
          "development"
          "releases"
        ];
      }

      {
        url = "https://blog.rust-lang.org/inside-rust/feed.xml";
        title = "Inside Rust";
        tags = [
          "rust"
          "development"
          "internals"
        ];
      }

      {
        url = "https://this-week-in-rust.org/atom.xml";
        title = "This Week in Rust";
        tags = [
          "rust"
          "development"
          "community"
        ];
      }

      {
        url = "https://rustsec.org/feed.xml";
        title = "RustSec Advisories";
        tags = [
          "rust"
          "security"
          "advisories"
          "cve"
        ];
      }

      {
        url = "https://kb.cert.org/vulfeed/";
        title = "CERT/CC Vulnerability Notes";
        tags = [
          "security"
          "advisories"
          "cve"
        ];
      }

      {
        url = "https://vulnerability.circl.lu/kev-catalogs/feed.atom";
        title = "CIRCL Known Exploited Vulnerabilities";
        tags = [
          "security"
          "cve"
          "exploited"
        ];
      }
    ];

    queries = {
      "Rust development" = ''(tags # "rust") and (tags # "development")'';
      "Rust security" = ''(tags # "rust") and (tags # "security")'';
      "Security advisories" = ''tags # "security"'';
    };

    extraConfig = ''
      # Play the current article with mpv.
      macro p set browser "${pkgs.mpv}/bin/mpv --player-operation-mode=pseudo-gui -- %u &"; open; set browser "$BROWSER"
    '';
  };
}
