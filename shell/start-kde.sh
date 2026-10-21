#!/usr/bin/env bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2026-04-08
# @version  1.1
# @license  GPL-2.0+

set -euo pipefail

# CURRENT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
# EXECUTE_FILENAME=$(readlink -f "$0")
# EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

export GDK_DPI_SCALE=1
# A tty login shell doesn't set these; exporting them here is
# required for the import-environment below to have any effect
# (importing an unset variable is a silent no-op). startplasma only
# sets XDG_CURRENT_DESKTOP itself — without this the user manager
# keeps whatever a previous session left there (XFCE via .xinitrc,
# user manager survives across sessions because Linger=yes).
export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_DESKTOP=plasma
export DESKTOP_SESSION=plasma
# systemd --user starts before xinitrc and inherits an empty env,
# so dbus-activated services like xdg-desktop-portal-gtk won't
# see GDK_DPI_SCALE. Import it (and related) into the user bus
# manager so new activations pick it up.
if hash systemctl 2>/dev/null; then
    systemctl --user import-environment \
        GDK_DPI_SCALE DISPLAY XAUTHORITY \
        XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP DESKTOP_SESSION \
        2>/dev/null
    # xdg-desktop-portal freezes its backend choice at process
    # start: kde.portal declares UseIn=KDE, gtk.portal is only the
    # fallback. With Linger=yes the portal survives session switches
    # holding the previous desktop env (e.g. XFCE), so restart it to
    # re-select the backend per the env imported above. The gtk
    # backend is restarted as well to drop leftover state.
    systemctl --user try-restart \
        xdg-desktop-portal.service xdg-desktop-portal-gtk.service \
        2>/dev/null || true
fi

/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
