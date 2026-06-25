set -euo pipefail

dir="$HOME/Pictures/ScreenShots"
mkdir -p "$dir"

file="$dir/screenshot-$(date +%Y-%m-%d-%H%M%S).png"

maim -s "$file"

xclip \
  -selection clipboard \
  -target image/png \
  -in "$file"

notify-send "Screenshot saved" "$file"
