set -eu

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export DESKTOP_SESSION=i3

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  XDG_RUNTIME_DIR="/run/user/$(id -u)"
  export XDG_RUNTIME_DIR
fi

# Force keyboard layout inside the XRDP X11 session.
setxkbmap -model pc105 -layout tr -variant "" -option ""

xsetroot -solid black || true

if [ -x "$HOME/.xsession" ]; then
  exec dbus-run-session "$HOME/.xsession"
fi

if [ -x "$HOME/.hm-xsession" ]; then
  exec dbus-run-session "$HOME/.hm-xsession"
fi

exec dbus-run-session i3
