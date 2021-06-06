
install:
	npm link

zx: install

genthumbs: install

# Linux only
mpv: zx genthumbs
	ZX_BIN=`which zx` GENTHUMBS_BIN=`which genthumbs` envsubst < thumbs.lua > ~/.config/mpv/scripts/genthumbs.lua