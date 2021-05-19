# ImageMagick

## Windows 10

On Windows, there is a "magick" executable with sub-commands.

    magick identify …
    magick convert …

## Use-Cases

Create an empty image (placeholder).

    convert -size 210x210 canvas:transparent PNG32:blank.png

Delete all EXIF data (not ImageMagick, but related).

    exiftool -all= "$image"

Resize image into bounding box keeping its aspect ratio, with transparent fill and border.

    geom="240x340"
    border=1
    convert "$image" -alpha on -channel rgba -background transparent \
        -resize $geom -gravity center -extent $geom \
        -bordercolor transparent -border $border \
        "${image%.*}.png"
