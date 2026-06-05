#!/usr/bin/env bash

ensure_earlyoom() {
    if [ "$SKIP_EARLYOOM" = true ]; then
        log "--> earlyoom skipped"
        return
    fi

    log "--> Checking earlyoom..."
    if ! command -v pacman >/dev/null 2>&1; then
        warn "pacman not found, skipping earlyoom"
        return
    fi

    if ! pacman -Qs earlyoom >/dev/null; then
        log "--> Installing earlyoom..."
        if [ "$DRY_RUN" = true ]; then
            warn "dry-run: pacman -S --noconfirm earlyoom"
        else
            pacman -S --noconfirm earlyoom
            systemctl enable --now earlyoom
        fi
        ok "earlyoom installed"
    else
        ok "earlyoom already installed"
        if ! systemctl is-active --quiet earlyoom; then
            log "--> Enabling earlyoom..."
            if [ "$DRY_RUN" = true ]; then
                warn "dry-run: systemctl enable --now earlyoom"
            else
                systemctl enable --now earlyoom
            fi
        fi
    fi
}
