#!/usr/bin/env zx

const usage = () => {
    console.log("Usage: genthumbs [videos]")
    console.log("--open open the thumbnail after creation")
    process.exit(2)
}

const args = process.argv.splice(3)
const help = args.filter(arg => arg === "--help").length > 0
const open = args.filter(arg => arg === "--open").length > 0
const nohash = args.filter(arg => arg === "--nohash").length > 0
const files = args.filter(arg => !arg.startsWith("-"))

if (files.length == 0 || help) {
    usage()
}

const gridText = async (file, size, timestamp) => {
    if (nohash) return `${size} / ${timestamp}`
    const digest = await $`xxh128sum ${file} 2>/dev/null | awk '{print $1}'`
    return `${size} / ${timestamp} / ${digest}`
}

files.forEach(async file => {
    const duration = await $`ffprobe ${file} -show_entries format=duration -v quiet -of csv="p=0"`
    const timestamp = await $`date -u --date=@${duration} +"%T"`
    const size = await $`ls -sh ${file} | awk '{print $1}'`

    const text = (await gridText(file, size, timestamp)).replaceAll(":", "\\:").replaceAll("\n", "")
    const tmpdir = await $`mktemp -d`
    const step = parseFloat(duration)/20
    const jobs = []

    const basedir = await $`dirname ${file}`
    const filename = await $`basename ${file}`
    const output = `${basedir}/${filename}.jpg`.replaceAll("\n", "")

    for (let pos = step, i = 0; pos < duration; pos += step, i++) {
        const index = i.toString().padStart(4, 0)
        jobs.push($`ffmpeg -nostdin -loglevel error -ss "${pos}"s -i ${file} -vsync 0 -q:v 1 -frames:v 1 -y "${tmpdir}/${index}.jpg"`)
    }

    await Promise.all(jobs)
    await $`ffmpeg -nostdin -loglevel error -pattern_type glob -i "${tmpdir}/*.jpg" \
            -vf tile=4x4:color=white:padding=5:margin=50,drawtext="text=${text}:fontsize=30:y=10:x=50" \
            -vsync 0 -frames:v 1 -q:v 1 -y ${output}`

    await $`rm -rf ${tmpdir}`

    if (open) $`xdg-open ${output}`
})