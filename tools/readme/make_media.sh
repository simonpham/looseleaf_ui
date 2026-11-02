#!/usr/bin/env bash
# Turns the frames from modules/gallery/test/render/readme_media_test.dart
# into doc/demo.gif and doc/home.jpg. Needs ImageMagick and ffmpeg.
set -euo pipefail

frames="${1:?usage: make_media.sh <README_MEDIA_DIR>}"
root="$(cd "$(dirname "$0")/../.." && pwd)"
out="$root/doc"
work="$frames/cursor"
mkdir -p "$out" "$work"

desk_crop="1160x1220+280+580"

while read -r index x y; do
  magick "$frames/frame_$index.png" \
    -fill '#1f1d1a' -stroke '#fffdf6' -strokewidth 2 \
    -draw "polygon $x,$y $x,$((y + 22)) $((x + 5)),$((y + 17)) $((x + 9)),$((y + 26)) $((x + 13)),$((y + 24)) $((x + 9)),$((y + 16)) $((x + 16)),$((y + 16))" \
    -crop "$desk_crop" +repage "$work/frame_$index.png"
done < "$frames/cursor.txt"

ffmpeg -loglevel error -y -framerate 25 -i "$work/frame_%04d.png" \
  -vf "scale=720:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
  "$out/demo.gif"

magick "$frames/still.png" -crop 1440x1100+0+0 +repage -quality 85 "$out/home.jpg"

ls -lh "$out/demo.gif" "$out/home.jpg"
