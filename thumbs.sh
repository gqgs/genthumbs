#!/usr/bin/sh

font="/usr/share/fonts/truetype/freefont/FreeSerif.ttf"

if [ $# -gt 0 ]; then
	files=$@
else
	files=*.mp4
fi

for file in $files; do
    duration=$(ffprobe "$file" -show_entries format=duration -v quiet -of csv="p=0")
    duration=${duration/.*}
    date="@$duration"
    duration=$(date -u --date=$date +"%T")

    size=$(ls -sh $file)
    size=${size/\ *}

    md5=$(md5sum $file)
    md5=${md5/\ *}

    text="$size / $duration / $md5"
    text=${text//":"/"\:"}

    ffmpeg -skip_frame nokey -i "$file" -vf scale=320:-1,tile=4x4:color=white:padding=5:margin=50,drawtext="fontfile=$font: text='$text':fontsize=30:y=10:x=50" -vsync 0 -frames:v 1 -y ${file/.*/.jpg}
done