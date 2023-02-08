#!/bin/bash

set -e

target="/mnt/mirror/termux"

lock="/tmp/.termux-sync-lock"

bwlimit=0

source_url='rsync://packages.termux.dev/termux'

#### END CONFIG

[ ! -d "${target}" ] && mkdir -p "${target}"

exec 9>"${lock}"
flock -n 9 || exit

rsync_cmd() {
        local -a cmd=(rsync -rtlH --safe-links --delete-after ${VERBOSE} "--timeout=600" "--contimeout=60" -p \
                --delay-updates --no-motd)

        if stty &>/dev/null; then
                cmd+=(-h -v --progress)
        else
                cmd+=(-h -v)
        fi

        if ((bwlimit>0)); then
                cmd+=("--bwlimit=$bwlimit")
        fi

        "${cmd[@]}" "$@"
}


rsync_cmd "${source_url}" "${target}"

echo "Last sync was $(date -d @$(cat ${target}/lastsync))"