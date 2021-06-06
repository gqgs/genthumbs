-- mpv user script

utils = require('mp.utils')

function genthumbs()
    local cwd = utils.getcwd()
    local filename = mp.get_property("filename")
    local path = utils.join_path(cwd, filename)
    local zx = "$ZX_BIN"
    local genthumbs = "$GENTHUMBS_BIN"
    t = {}
    t.args = {zx, genthumbs, path, "--open", "--nohash"}
    mp.osd_message("Creating thumbs preview:" .. path)
    res = utils.subprocess(t)
    if res.status == 0 then
        mp.osd_message("Preview created")
    else
        mp.osd_message("Preview creation error")
    end
end


mp.add_key_binding("g", "genthumbs", genthumbs)