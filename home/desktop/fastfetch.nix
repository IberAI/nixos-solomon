{
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        type = "auto";
        source = "nixos";
        padding = {
          top = 2;
          left = 3;
        };
      };

      display = {
        separator = " ";
        color = {
          keys = "blue";
          output = "default";
        };
      };

      modules = [
        "break"

        {
          type = "custom";
          format = "┌────────────────────── Hardware ──────────────────────┐";
        }

        {
          type = "host";
          key = "│ 󰌢 Host      ";
          keyColor = "green";
        }

        {
          type = "cpu";
          key = "│  CPU       ";
          keyColor = "green";
        }

        {
          type = "gpu";
          key = "│ 󰍛 GPU       ";
          keyColor = "green";
        }

        {
          type = "memory";
          key = "│  Memory    ";
          keyColor = "green";
        }

        {
          type = "disk";
          key = "│  Disk      ";
          keyColor = "green";
          folders = "/";
        }

        {
          type = "display";
          key = "│ 󰍹 Display   ";
          keyColor = "green";
        }

        {
          type = "localip";
          key = "│ 󰩟 Local IP  ";
          keyColor = "green";
        }

        {
          type = "custom";
          format = "└──────────────────────────────────────────────────────┘";
        }

        "break"

        {
          type = "custom";
          format = "┌────────────────────── Software ──────────────────────┐";
        }

        {
          type = "os";
          key = "│  OS        ";
          keyColor = "yellow";
        }

        {
          type = "kernel";
          key = "│  Kernel    ";
          keyColor = "yellow";
        }

        {
          type = "bios";
          key = "│ 󰘚 BIOS      ";
          keyColor = "yellow";
        }

        {
          type = "packages";
          key = "│ 󰏖 Packages  ";
          keyColor = "yellow";
        }

        {
          type = "shell";
          key = "│  Shell     ";
          keyColor = "yellow";
        }

        {
          type = "de";
          key = "│ 󰧨 DE        ";
          keyColor = "yellow";
        }

        {
          type = "wm";
          key = "│  WM        ";
          keyColor = "yellow";
        }

        {
          type = "wmtheme";
          key = "│ 󰉼 WM Theme  ";
          keyColor = "yellow";
        }

        {
          type = "terminal";
          key = "│  Terminal  ";
          keyColor = "yellow";
        }

        {
          type = "terminalfont";
          key = "│  Font      ";
          keyColor = "yellow";
        }

        {
          type = "custom";
          format = "└──────────────────────────────────────────────────────┘";
        }

        "break"

        {
          type = "custom";
          format = "┌────────────────────── Session ───────────────────────┐";
        }

        {
          type = "command";
          key = "│ 󰔚 OS Age    ";
          keyColor = "magenta";
          text = ''
            birth_install=$(stat -c %W / 2>/dev/null || echo 0)
            current=$(date +%s)

            if [ "$birth_install" -le 0 ]; then
              echo "unknown"
            else
              days_difference=$(( (current - birth_install) / 86400 ))
              echo "$days_difference days"
            fi
          '';
        }

        {
          type = "uptime";
          key = "│ 󰅐 Uptime    ";
          keyColor = "magenta";
        }

        {
          type = "datetime";
          key = "│  Date      ";
          keyColor = "magenta";
          format = "{1}-{3}-{11} {14}:{17}";
        }

        {
          type = "command";
          key = "│  Session   ";
          keyColor = "magenta";
          text = ''
            echo "X11 / i3"
          '';
        }

        {
          type = "command";
          key = "│ 󰑓 VM        ";
          keyColor = "magenta";
          text = ''
            systemd-detect-virt 2>/dev/null || echo "unknown"
          '';
        }

        {
          type = "custom";
          format = "└──────────────────────────────────────────────────────┘";
        }

        "break"

        {
          type = "colors";
          paddingLeft = 2;
          symbol = "circle";
        }
      ];
    };
  };
}
