#!/bin/sh
#
# ISC License
#
# Copyright (c) 2022 Philip Munksgaard
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

# Script to add new files to external-data.txt. Should be run from the root of
# the repository. If the file already exists, we don't add it to
# external-data.txt.

set -e

if [ $# != 2 ]; then
    echo "Usage: $0 URL OUTPUT"
    echo
    echo "For example: $0 https://sid.erda.dk/share_redirect/FlhwY8rtfk/accelerate/canny/lena256.in accelerate/canny/data/lena256.in"
    exit 1
fi

SHA=$(curl "$1" | LC_ALL=en_US.UTF-8 shasum -a 256 - | cut -f 1 -d ' ')

ln -s -r "external-data/$2" "$2"

echo "external-data/$2 $1 $SHA" >> external-data.txt

