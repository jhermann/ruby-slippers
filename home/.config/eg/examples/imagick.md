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
