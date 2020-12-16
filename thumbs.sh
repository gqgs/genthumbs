#!/usr/bin/sh

font="/usr/share/fonts/truetype/freefont/FreeSerif.ttf"


usage() {
    echo "Usage: genThumbs [videos]"
    exit 1
}

while getopts ":*" opt; do
    case "${opt}" in
    *)
        usage
        ;;
    esac
done

if [ $# -eq "0" ]; then
    usage
fi

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

    start=$(bc <<< "scale=2; $duration/20")
    pos=$start
    while [ "$(bc <<< "$pos < $duration")" == "1" ]
    do
        pos=$(bc <<< "scale=2; $pos + $start")
        n=$(bc <<< "scale=0; 20*$pos/$duration")
        possuffix=`printf "%010.f" $n` # padding needed to keep natural sorting order
        ffmpeg -loglevel quiet -ss "$pos"s -i "$file" -vf thumbnail=10,scale=320:-1 -vsync 0 -frames:v 1 -y "$tmpdir/${file/.*/_$possuffix.jpg}" &
    done
    wait
    ffmpeg -loglevel quiet -pattern_type glob -i "$tmpdir/*.jpg" -vf tile=4x4:color=white:padding=5:margin=50,drawtext="fontfile=$font: text='$text':fontsize=30:y=10:x=50" -vsync 0 -frames:v 1 -y "${file/.*/.png}"
    rm -r "$tmpdir"
done