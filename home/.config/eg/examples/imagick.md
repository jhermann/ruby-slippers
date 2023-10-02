# Image Magick

Edit `/etc/ImageMagick-6/policy.xml` to enable PDF handling.

## Windows 10

On Windows, there is a "magick" executable with sub-commands.

    magick identify …
    magick convert …

## Use-Cases

Increase contrast, reduce brightness

    mogrify -brightness-contrast -20x40 *.png

Reduce size of a text scan (75% threshold in case of very light elements)

    mogrify -auto-level -geometry 1200x9999 -white-threshold 60% -unsharp 2x2 *.png

Convert PDF to PNG (use "...pdf[n]" to select pages)

    convert -background white -alpha off doc.pdf doc-%d.png  # bad quality
    convert -font Verdana -colorspace gray -antialias -flatten -geometry 1600x2250 doc.pdf[0] frontpage.png

Convert set of images to PDF (size A4)

    convert -page 595x842 -density 72 -units pixelsperinch +repage doc*.png doc.pdf

Create an empty image (placeholder).

    convert -size 210x210 canvas:transparent PNG32:blank.png

Delete all EXIF data (not ImageMagick, but related).

    exiftool -all= "$image"

Create gallery of covers.

    montage -background '#222' -stroke '#fff' -font DejaVu-Sans-Condensed -pointsize 9 \
        -tile 3x -geometry 220x160 -label "%t" 0*.jpg folder.jpg

Resize image into bounding box keeping its aspect ratio, with transparent fill and border.

    geom="240x340"
    border=1
    convert "$image" -alpha on -channel rgba -background transparent \
        -resize $geom -gravity center -extent $geom \
        -bordercolor transparent -border $border \
        "${image%.*}.png"

Increase contrast, reduce brightness

    mogrify -brightness-contrast -20x40 *.png

Convert PDF to PNG (use "...pdf[n]" to select pages)

    convert -background white -alpha off doc.pdf doc-%d.png  # bad quality
    convert -font Verdana -colorspace gray -antialias -flatten -geometry 1600x2250 doc.pdf[0] frontpage.png

Convert set of images to PDF (size A4)

    convert -page 595x842 -density 72 -units pixelsperinch +repage doc*.png doc.pdf
