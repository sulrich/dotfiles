# -*- mode: shell-script; fill-column: 78; comment-column: 50; tab-width: 2 -*-
# host specific aliases, etc.
#


# this should really only be run on heliox.botwerks.net - it provides a means to
# archive pictures based on date/time info into a prescribed hierarchy.
function arch-photos () {
    local PHOTO_ARCH="/mnt/snuffles/media/GCP-MediaBackup/photo-archive"
    exiftool "-Directory<DateTimeOriginal" -d "${PHOTO_ARCH}/%Y/%m/%d" $@
}

