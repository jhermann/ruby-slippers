# ffmpeg

## Use-Cases

Get chapter information in JSON format.

    videofile="…"
    ffprobe -i "$videofile" -print_format json -show_chapters -loglevel error

Create thumbnail gallery.

    videofile="…"
    ffmpeg -loglevel error -ss 00:00:10 \
           -i "$videofile" -vf 'select=not(mod(n\,1000)),scale=340:190,tile=2x4' \
           -y thumbs.png

