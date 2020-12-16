#!/usr/bin/sh

font="/usr/share/fonts/truetype/freefont/FreeSerif.ttf"

for file in "$@"; do
    echo "Processing: '$file'"
    duration=$(ffprobe "$file" -show_entries format=duration -v quiet -of csv="p=0")
    duration=${duration/.*}
    date="@$duration"
    timestamp=$(date -u --date=$date +"%T")

    size=$(ls -sh "$file")
    size=${size/\ *}

    digest=$(sha1sum "$file")
    digest=${digest/\ *}

    text="$size / $timestamp / $digest"
    text=${text//":"/"\:"}

    tmpdir=$(mktemp -d)

    start=$((duration/20))
    pos=$start
    while [ $pos -lt $duration ]
    do
        pos=$((pos+start))
        ffmpeg -loglevel error -skip_frame nokey -ss "$pos"s -i "$file" -vf scale=320:-1 -vsync 0 -frames:v 1 -y "$tmpdir/${file/.*/_$pos.jpg}"
    done
    ffmpeg -loglevel error -pattern_type glob -i "$tmpdir/*.jpg" -vf tile=4x4:color=white:padding=5:margin=50,drawtext="fontfile=$font: text='$text':fontsize=30:y=10:x=50" -vsync 0 -frames:v 1 -y "${file/.*/.jpg}"
    rm -r "$tmpdir"
done