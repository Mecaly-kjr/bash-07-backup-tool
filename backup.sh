#!/usr/bin/env bash

# Default settings
DEST="$HOME/backups"
KEEP=5

usage() {
    cat <<'EOF'
Usage: backup.sh [-d DEST] [-k KEEP] SOURCE

Create a compressed, timestamped backup of a directory.

Options:
  -d DEST   Directory where backups are stored (default: ~/backups)
  -k KEEP   Number of newest backups to keep (default: 5)
  -h        Show this help message

Exit codes:
  0  Success or help displayed
  1  Backup or filesystem operation failed
  2  Invalid usage or invalid KEEP value
EOF
}

die() {
    local exit_code="$1"
    shift
    printf 'Error: %s\n' "$*" >&2
    exit "$exit_code"
}

create_backup() {
    local source_path="$1"
    local destination="$2"
    local folder_name="$3"
    local timestamp
    local archive

    timestamp=$(date '+%Y%m%d-%H%M%S') ||
        die 1 "Could not generate timestamp."

    archive="$destination/$folder_name-$timestamp.tar.gz"

    if ! tar -czf "$archive" \
        -C "$(dirname -- "$source_path")" "$folder_name"; then
        rm -f -- "$archive"
        die 1 "Backup creation failed."
    fi

    printf '%s\n' "$archive"
}

rotate_backups() {
    local destination="$1"
    local folder_name="$2"
    local keep="$3"
    local file
    local base
    local timestamp
    local -a archives=()
    local -a valid_archives=()

    shopt -s nullglob
    archives=( "$destination/$folder_name-"*.tar.gz )
    shopt -u nullglob

    # Keep only files with the exact expected timestamp format.
    for file in "${archives[@]}"; do
        base="${file##*/}"
        timestamp="${base#"$folder_name"-}"

        if [[ "$base" == "$folder_name-"* &&
              "$timestamp" =~ ^[0-9]{8}-[0-9]{6}\.tar\.gz$ ]]; then
            valid_archives+=( "$file" )
        fi
    done

    # Nothing to rotate if there are no valid backup files.
    if ((${#valid_archives[@]} == 0)); then
        return 0
    fi

    # Newest timestamps sort first in reverse lexical order.
    mapfile -t valid_archives < <(
        printf '%s\n' "${valid_archives[@]}" | sort -r
    )

    # Delete backups beyond the KEEP limit.
    for ((i = keep; i < ${#valid_archives[@]}; i++)); do
        file="${valid_archives[$i]}"

        if ! rm -- "$file"; then
            die 1 "Could not remove old backup: $file"
        fi
    done
}

main() {
    local source
    local source_path
    local folder_name
    local archive
    local destination
    local OPTIND=1
    local OPTARG
    local option

    while getopts ':d:k:h' option; do
        case "$option" in
            d)
                DEST="$OPTARG"
                ;;
            k)
                KEEP="$OPTARG"
                ;;
            h)
                usage
                return 0
                ;;
            :)
                usage >&2
                die 2 "Option -$OPTARG requires an argument."
                ;;
            \?)
                usage >&2
                die 2 "Unknown option: -$OPTARG"
                ;;
        esac
    done

    shift "$((OPTIND - 1))"

    if [[ "$#" -ne 1 ]]; then
        usage >&2
        die 2 "Exactly one SOURCE directory is required."
    fi

    source="$1"

    if [[ ! "$KEEP" =~ ^[1-9][0-9]*$ ]]; then
        die 2 "KEEP must be a positive whole number."
    fi

    if [[ ! -d "$source" ]]; then
        die 1 "SOURCE is not an existing directory: $source"
    fi

    source_path=$(cd -- "$source" && pwd -P) ||
        die 1 "Could not resolve SOURCE."

    folder_name=$(basename -- "$source_path")
    destination="$DEST"

    if ! mkdir -p -- "$destination"; then
        die 1 "Could not create destination: $destination"
    fi

    destination=$(cd -- "$destination" && pwd -P) ||
        die 1 "Could not resolve destination."

    archive=$(create_backup "$source_path" "$destination" "$folder_name") ||
        die 1 "Backup creation failed."

    rotate_backups "$destination" "$folder_name" "$KEEP"

    printf 'Backup created: %s\n' "$archive"
}

main "$@"
