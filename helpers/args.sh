#!/usr/bin/env bash

print_help() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --zram-size <MB|G>   Manual ZRAM size (MiB). Examples: 12288 or 12G
  --max-zram-mb <MB>   Cap for auto ZRAM size (default: 16384)
  --swappiness <N>     vm.swappiness value (default: 150)
  --algo <name>        Compression algorithm (default: zstd)
  --skip-earlyoom      Do not install/enable earlyoom
  --dry-run            Show changes without applying
  -h, --help           Show this help
EOF
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --zram-size)
                ZRAM_SIZE_TARGET="${2:-}"
                shift 2
                ;;
            --max-zram-mb)
                ZRAM_MAX_MB="${2:-}"
                shift 2
                ;;
            --swappiness)
                SWAPPINESS_VALUE="${2:-}"
                shift 2
                ;;
            --algo)
                ZRAM_ALGO_TARGET="${2:-}"
                shift 2
                ;;
            --skip-earlyoom)
                SKIP_EARLYOOM=true
                shift 1
                ;;
            --dry-run)
                DRY_RUN=true
                shift 1
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done
}
