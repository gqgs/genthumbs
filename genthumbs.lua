#!/usr/bin/env lua

utils = require('mp.utils')

local help = false
local open = false
local nohash = false

local function execute_command(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result:gsub("[\r\n]+$", "")
end

local function grid_text(file, size, timestamp)
    if nohash then
        return size .. " / " .. timestamp
    end
    local digest = execute_command("xxh128sum " .. file .. " 2>/dev/null | awk '{print $1}'")
    return size .. " / " .. timestamp .. " / " .. digest
end

local function generate_thumbnail(file)
    local duration = execute_command("ffprobe " .. file .. " -show_entries format=duration -v quiet -of csv=\"p=0\"")
    local timestamp = execute_command("date -u --date=@" .. duration .. " +\"%T\"")
    local size = execute_command("ls -sh " .. file .. " | awk '{print $1}'")

    local text = grid_text(file, size, timestamp):gsub(":", "\\:")
    local tmpdir = execute_command("mktemp -d")
    local step = tonumber(duration) / 20

    local basedir = execute_command("dirname " .. file)
    local filename = execute_command("basename " .. file)
    local output = basedir .. "/" .. filename .. ".jpg"

    -- Generate thumbnails in parallel using multiple processes
    local commands = {}
    local i = 0
    local pos = step

    while tonumber(tostring(pos)) < tonumber(duration) do
        local index = string.format("%04d", i)
        local cmd = "ffmpeg -nostdin -loglevel error -ss " .. pos .. "s -i " .. file .. 
                   " -vsync 0 -q:v 1 -frames:v 1 -y \"" .. tmpdir .. "/" .. index .. ".jpg\""
        os.execute(cmd)
        i = i + 1
        pos = pos + step
    end

    -- Create the thumbnail grid
    local grid_cmd = "ffmpeg -nostdin -loglevel error -pattern_type glob -i \"" .. tmpdir .. "/*.jpg\" " ..
                    "-vf tile=4x4:color=white:padding=5:margin=50,drawtext=\"text='" .. text .. "'" .. 
                    ":fontsize=30:y=10:x=50\" " ..
                    "-vsync 0 -frames:v 1 -q:v 1 -y " .. output
    
    status = os.execute(grid_cmd)

    -- Clean up temporary directory
    os.execute("rm -rf " .. tmpdir)

    -- Open the generated thumbnail if requested
    if open then
        os.execute("xdg-open " .. output)
    end

    return status
end

function genthumbs()
    mp.osd_message("Creating preview")
    local cwd = utils.getcwd()
    local filename = mp.get_property("filename")
    local path = utils.join_path(cwd, filename)
    if generate_thumbnail(path) == 0 then
        mp.osd_message("Preview created")
    else
        mp.osd_message("Preview creation error")
    end
end

mp.add_key_binding("g", "genthumbs", genthumbs)