#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=helpers/config.sh
source "$ROOT_DIR/helpers/config.sh"
# shellcheck source=helpers/logger.sh
source "$ROOT_DIR/helpers/logger.sh"
# shellcheck source=helpers/system.sh
source "$ROOT_DIR/helpers/system.sh"
# shellcheck source=helpers/args.sh
source "$ROOT_DIR/helpers/args.sh"
# shellcheck source=helpers/size.sh
source "$ROOT_DIR/helpers/size.sh"
# shellcheck source=modules/earlyoom.sh
source "$ROOT_DIR/modules/earlyoom.sh"
# shellcheck source=modules/zram.sh
source "$ROOT_DIR/modules/zram.sh"
# shellcheck source=modules/swappiness.sh
source "$ROOT_DIR/modules/swappiness.sh"

main() {
    check_root
    parse_args "$@"

    log "=================================================="
    log "   ZRAM/SWAP OPTIMIZER"
    log "=================================================="

    ensure_earlyoom
    log "--------------------------------------------------"

    local zram_changed=false
    local sysctl_changed=false

    if write_zram_conf; then
        zram_changed=true
    fi

    log "--------------------------------------------------"

    if write_swappiness_conf; then
        sysctl_changed=true
    fi

    ensure_swappiness_applied

    log "--------------------------------------------------"
    apply_changes "$sysctl_changed" "$zram_changed"
    show_status
}

main "$@"
