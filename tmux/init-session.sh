#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    selected_path=$( (echo ~; echo /etc/nixos; fd . ~/Dev --type d --max-depth 5 -E Resources -E target -E vendor -E node_modules -E src) | fzf)

    [ -z $selected_path ] && exit 0

    # session_name=${selected_path}           
    session_name=${selected_path#$HOME/Dev/}           
    session_name=${session_name%*/}
    # session_name=$(echo $session_name | sed s#$HOME#home#g)
    session_name=$(echo $session_name | sed s#/#_#g)

    tmux_running=$(pgrep tmux)

    if [[ -z $tmux_running ]]; then
        tmux new-session -s $session_name -c $selected_path 2> /dev/null;
        exit 0
    fi

    if ! tmux has-session -t $session_name 2> /dev/null; then
        tmux new-session -ds $session_name -c $selected_path 2> /dev/null;
    fi

    [[ -z $TMUX ]] &&
        tmux a -t $session_name || 
        tmux switch-client -t $session_name

elif [[ "$1" == "l" ]]; then
    tmux_ls=$(tmux ls 2> /dev/null)

    if [[ -z $tmux_ls ]]; then
        echo "No tmux sessions"
        exit 0
    fi

    selected_session=$(tmux ls | fzf | cut -d: -f1)

    if [[ ! -z $selected_session ]]; then
        [[ -z $TMUX ]] && tmux a -t $selected_session || 
            tmux switch-client -t $selected_session
    fi
fi
