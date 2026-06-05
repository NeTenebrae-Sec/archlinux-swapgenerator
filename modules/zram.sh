#!/usr/bin/env bash

ZRAM_CONF="/etc/systemd/zram-generator.conf"

write_zram_conf() {
    local size_mb
    local desired
    local current

    size_mb=$(compute_zram_mb)
    desired="[zram0]\nzram-size = ${size_mb}\ncompression-algorithm = ${ZRAM_ALGO_TARGET}"

    if [ -f "$ZRAM_CONF" ]; then
        current=$(grep -v '^ *$' "$ZRAM_CONF" | tr -d '\r' | sort)
    else
        current=""
    fi

    if [ "$current" != "$(echo "$desired" | sort)" ]; then
        log "--> Updating $ZRAM_CONF"
        if [ "$DRY_RUN" = true ]; then
            warn "dry-run: write $ZRAM_CONF"
        else
            mkdir -p /etc/systemd
            if [ -f "$ZRAM_CONF" ]; then
                cp "$ZRAM_CONF" "${ZRAM_CONF}.bak"
            fi
            printf "%b\n" "$desired" > "$ZRAM_CONF"
        fi
        return 0
    fi

    ok "ZRAM config already correct"
    return 1
}

apply_changes() {
    local changed_sysctl="$1"
    local changed_zram="$2"

    if [ "$DRY_RUN" = true ]; then
        warn "dry-run: no changes applied"
        return
    fi

    if [ "$changed_sysctl" = true ]; then
        log "--> Applying sysctl"
        sysctl --system
    fi

    if [ "$changed_zram" = true ]; then
        log "--> Restarting zram setup"
        systemctl daemon-reload
        if swapon --show | grep -q "zram"; then
            swapoff /dev/zram0 2>/dev/null || true
        fi
        systemctl restart systemd-zram-setup@zram0.service || true
    fi
}
