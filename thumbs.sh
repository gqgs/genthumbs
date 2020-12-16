#!/usr/bin/sh

font="/usr/share/fonts/truetype/freefont/FreeSerif.ttf"

for file in "$@"; do
    echo "Processing: '$file'"
    duration=$(ffprobe "$file" -show_entries format=duration -v quiet -of csv="p=0")
    duration=${duration/.*}
    date="@$duration"
    duration=$(date -u --date=$date +"%T")

    size=$(ls -sh "$file")
    size=${size/\ *}

    digest=$(sha1sum "$file")
    digest=${digest/\ *}

    text="$size / $duration / $digest"
    text=${text//":"/"\:"}

    total=$(ffprobe -select_streams v:0 "$file" -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 -v quiet)
    pos=$((total/20))

    ffmpeg -loglevel error -i "$file" -vf select="isnan(prev_selected_n) + gte(n-prev_selected_n\,$pos)",scale=320:-1,tile=4x4:color=white:padding=5:margin=50,drawtext="fontfile=$font: text='$text':fontsize=30:y=10:x=50" -vsync 0 -frames:v 1 -y "${file/.*/.jpg}"
done