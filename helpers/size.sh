#!/usr/bin/env bash

normalize_to_mb() {
    local raw="$1"
    local num
    local unit

    if [[ "$raw" =~ ^[0-9]+$ ]]; then
        echo "$raw"
        return
    fi

    if [[ "$raw" =~ ^([0-9]+)([gGmM])$ ]]; then
        num="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"
        if [ "$unit" = "G" ] || [ "$unit" = "g" ]; then
            echo $((num * 1024))
        else
            echo "$num"
        fi
        return
    fi

    warn "Invalid size: $raw (use MB or G)"
    exit 1
}

detect_ram_mb() {
    local total_kb
    local total_mb
    total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    total_mb=$(( (total_kb + 1023) / 1024 ))
    echo "$total_mb"
}

compute_zram_mb() {
    local total_mb
    local size_mb

    if [ -n "$ZRAM_SIZE_TARGET" ]; then
        size_mb=$(normalize_to_mb "$ZRAM_SIZE_TARGET")
        ok "ZRAM manual size: ${size_mb}MiB" >&2
        echo "$size_mb"
        return
    fi

    total_mb=$(detect_ram_mb)

    if [ "$total_mb" -le 8192 ]; then
        size_mb=$((total_mb * 2))
    elif [ "$total_mb" -le 16384 ]; then
        size_mb="$total_mb"
    else
        size_mb=$((total_mb / 2))
    fi

    if [ "$ZRAM_MAX_MB" -gt 0 ] && [ "$size_mb" -gt "$ZRAM_MAX_MB" ]; then
        size_mb="$ZRAM_MAX_MB"
    fi

    ok "ZRAM auto size: ${size_mb}MiB (RAM=${total_mb}MiB)" >&2
    echo "$size_mb"
}
