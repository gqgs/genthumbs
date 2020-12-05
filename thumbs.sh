#!/usr/bin/sh

samples=16
geometry=+4+4

if [ $# -gt 0 ]; then
	files=$@
else
	files=*.mp4
fi

for file in $files; do
    duration=$(ffprobe "$file" -show_entries format=duration -v quiet -of csv="p=0")
    duration=${duration/.*}
    size=$(ls -sh $file)
    size=${size/\ *}
    md5=$(md5sum $file)
    md5=${md5/\ *}
    tmpdir=$(mktemp -d)
    ffmpeg -i "$file" -vf fps=$samples/$duration,scale=320:-1 -threads 0 -vsync 0 -vframes $samples -c:v png -y -loglevel info $tmpdir/cap%002d.png
    date="@$duration"
    duration=$(date -u --date=$date +"%T")
    montage -title "$size / $duration / $md5" -fill "#cccccc" -pointsize 18 -font /usr/share/fonts/TTF/DejaVuSans.ttf -geometry $geometry $tmpdir/cap*.png ${file/.*/.jpg}
    rm $tmpdir/cap*.png
    rm -d $tmpdir
done
