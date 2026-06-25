set -eu

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export DESKTOP_SESSION=i3

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

xsetroot -solid black || true

if [ -x "$HOME/.xsession" ]; then
  exec dbus-run-session "$HOME/.xsession"
fi

if [ -x "$HOME/.hm-xsession" ]; then
  exec dbus-run-session "$HOME/.hm-xsession"
fi

exec dbus-run-session i3
