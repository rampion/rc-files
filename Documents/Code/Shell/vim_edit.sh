#!/bin/sh
open -a Terminal.app
/usr/local/bin/tmux new-window "/usr/bin/vim \"$*\""
