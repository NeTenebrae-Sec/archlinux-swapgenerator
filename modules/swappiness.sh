#!/usr/bin/env bash

SWAP_CONF="/etc/sysctl.d/99-swappiness.conf"

write_swappiness_conf() {
    local current
    local desired

    desired="vm.swappiness = ${SWAPPINESS_VALUE}"
    if [ -f "$SWAP_CONF" ]; then
        current=$(cat "$SWAP_CONF" 2>/dev/null || true)
    else
        current=""
    fi

    if [ "$current" != "$desired" ]; then
        log "--> Updating $SWAP_CONF"
        if [ "$DRY_RUN" = true ]; then
            warn "dry-run: write $SWAP_CONF"
        else
            mkdir -p /etc/sysctl.d
            printf "%s\n" "$desired" > "$SWAP_CONF"
        fi
        return 0
    fi

    ok "Swappiness already set"
    return 1
}

ensure_swappiness_applied() {
    local current

    current=$(cat /proc/sys/vm/swappiness 2>/dev/null || true)
    if [ "$current" = "$SWAPPINESS_VALUE" ]; then
        ok "Swappiness already applied"
        return
    fi

    log "--> Applying swappiness to kernel"
    if [ "$DRY_RUN" = true ]; then
        warn "dry-run: sysctl -w vm.swappiness=${SWAPPINESS_VALUE}"
    else
        sysctl -w "vm.swappiness=${SWAPPINESS_VALUE}"
    fi
}
