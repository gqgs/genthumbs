#!/usr/bin/bash

usage() {
    echo "Usage: genthumbs [videos]"
    echo "-t: draw timestamps"
    echo
    exit 1
}

while getopts "t" opt; do
    case "${opt}" in
    t)
        timetext=",drawtext=text='\$text':fontsize=15:y=10:x=10:box=1:boxcolor=white@0.15"
        shift
        ;;
    *)
        usage
        ;;
    esac
done

if [ $# -eq "0" ]; then
    usage
fi

function parsetime() {
    date="@$1"
    echo $(date -u --date=$date +"%T")
}

for file in "$@"; do
    echo "processing: '$file'"
    duration=$(ffprobe "$file" -show_entries format=duration -v quiet -of csv="p=0")
    duration=${duration/.*}

    if [[ $duration == "N/A" ]]; then
        echo "invalid duration '$duration'"
        continue
    fi

    timestamp=$(parsetime $duration)

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

        timestamp=$(parsetime $pos)
        timestr=${timetext/"\$text"/"$timestamp"}
        timestr=${timestr//":"/"\:"}

        ffmpeg -nostdin -loglevel error -ss "$pos"s -i "$file" -vf thumbnail=10,scale=320:-1$timestr -vsync 0 -q:v 1 -frames:v 1 -y "$tmpdir/${file/.*/_$possuffix.jpg}" &
    done
    wait
    ffmpeg -nostdin -loglevel error -pattern_type glob -i "$tmpdir/*.jpg" -vf tile=4x4:color=white:padding=5:margin=50,drawtext="text='$text':fontsize=30:y=10:x=50" -vsync 0 -frames:v 1 -q:v 1 -y "${file/.*/.jpg}"
    rm -r "$tmpdir"
done