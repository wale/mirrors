#!/bin/bash

set -e

# This is a simple mirroring script. To save bandwidth it first checks a
# timestamp via HTTP and only runs rsync when the timestamp differs from the
# local copy. As of 2016, a single rsync run without changes transfers roughly
# 6MiB of data which adds up to roughly 250GiB of traffic per month when rsync
# is run every minute. Performing a simple check via HTTP first can thus save a
# lot of traffic.

# Directory where the repo is stored locally. Example: /srv/repo
target="/mnt/mirror/archlinux"

# Directory where files are downloaded to before being moved in place.
# This should be on the same filesystem as $target, but not a subdirectory of $target.
# Example: /srv/tmp
tmp="/var/tmp/arch-tmp"

# Lockfile path
lock="/tmp/.arch-sync-lock"

# If you want to limit the bandwidth used by rsync set this.
# Use 0 to disable the limit.
# The default unit is KiB (see man rsync /--bwlimit for more)
bwlimit=0

# The source URL of the mirror you want to sync from.
# If you are a tier 1 mirror use rsync.archlinux.org, for example like this:
# rsync://rsync.archlinux.org/ftp_tier1
# Otherwise chose a tier 1 mirror from this list and use its rsync URL:
# https://www.archlinux.org/mirrors/
source_url='rsync://mirror.aarnet.edu.au/archlinux/'
# source_url='rsync://fooo.biz/archlinux/'
# source_url='rsync://archlinux.mailtunnel.eu/archlinux/'

# An HTTP(S) URL pointing to the 'lastupdate' file on your chosen mirror.
# If you are a tier 1 mirror use: http://rsync.archlinux.org/lastupdate
# Otherwise use the HTTP(S) URL from your chosen mirror.
# lastupdate_url='https://fooo.biz/archlinux/lastupdate'
# lastupdate_url='https://archlinux.mailtunnel.eu/lastupdate'
lastupdate_url='https://mirror.aarnet.edu.au/pub/archlinux/lastupdate'

#### END CONFIG

[ ! -d "${target}" ] && mkdir -p "${target}"
[ ! -d "${tmp}" ] && mkdir -p "${tmp}"

exec 9>"${lock}"
flock -n 9 || exit

rsync_cmd() {
        local -a cmd=(rsync -rtlH --safe-links --delete-after ${VERBOSE} "--timeout=600" "--contimeout=60" -p \
                --delay-updates --no-motd "--temp-dir=${tmp}")

        if stty &>/dev/null; then
                cmd+=(-h -v --progress)
        else
                cmd+=(--quiet)
        fi

        if ((bwlimit>0)); then
                cmd+=("--bwlimit=$bwlimit")
        fi

        "${cmd[@]}" "$@"
}


# if we are called without a tty (cronjob) only run when there are changes
if [[ -f "$target/lastupdate" ]] && diff -b <(curl -Ls "$lastupdate_url") "$target/lastupdate" >/dev/null; then
        # keep lastsync file in sync for statistics generated by the Arch Linux website
        rsync_cmd "$source_url/lastsync" "$target/lastsync"
        exit
fi

rsync_cmd "${source_url}" "${target}"

echo "Last sync was $(date -d @$(cat ${target}/lastsync))"