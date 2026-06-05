#!/usr/bin/env bash

check_root() {
    if [ "${EUID}" -ne 0 ]; then
        warn "Run with sudo: sudo bash $0"
        exit 1
    fi
}

show_status() {
    log "--------------------------------------------------"
    log "Memory status:"
    sleep 2
    free -h
    log "Swap devices:"
    swapon --show
}
