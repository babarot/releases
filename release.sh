#!/bin/bash

# Logging stuff.
e_header()   { echo -e "\n\033[1m$@\033[m"; }
e_success()  { echo -e " \033[1;32m\U2B55\033[m  $@"; }
e_error()    { echo -e " \033[1;31m\U274C\033[m  $@"; }
e_arrow()    { echo -e " \033[1;34m=>\033[m  $@"; }

# OS detection
is_osx() {
    [[ "$OSTYPE" =~ ^darwin ]] || return 1
}
is_ubuntu() {
    [[ "$(cat /etc/issue 2> /dev/null)" =~ Ubuntu ]] || return 1
}
get_os() {
    for os in osx ubuntu; do
        is_$os; [[ $? == ${1:-0} ]] && echo $os
    done
}

# Display a fancy multi-select menu.
# Inspired by http://serverfault.com/a/298312
prompt_menu() {
    local exitcode prompt nums
    exitcode=0
    if [[ "$exitcode" == 0 ]]; then
        prompt="Toggle options (Separate options with spaces, ENTER when done): "
        while clear; _prompt_menu_draws "$1" 1 && read -rp "$prompt" nums && [[ "$nums" ]]
        do
            _prompt_menu_adds $nums
        done
    fi 1>&2
    _prompt_menu_adds
}

_prompt_menu_iter() {
    local i sel state
    local fn=$1; shift
    for i in "${!menu_options[@]}"; do
        state=0
        for sel in "${menu_selects[@]}"; do
            [[ "$sel" == "${menu_options[i]}" ]] && state=1 && break
        done
        $fn $state $i "$@"
    done
}

_prompt_menu_draws() {
    e_header "$1"
    _prompt_menu_iter _prompt_menu_draw "$2"
}

_prompt_menu_draw() {
    local modes=(error success)
    if [[ "$3" ]]; then
        e_${modes[$1]} "$(printf "%2d) %s\n" $(($2+1)) "${menu_options[$2]}")"
    else
        e_${modes[$1]} "${menu_options[$2]}"
    fi
}

_prompt_menu_adds() {
    _prompt_menu_result=()
    _prompt_menu_iter _prompt_menu_add "$@"
    menu_selects=("${_prompt_menu_result[@]}")
}

_prompt_menu_add() {
    local state i n keep match
    state=$1; shift
    i=$1; shift
    for n in "$@"; do
        if [[ $n =~ ^[0-9]+$ ]] && (( n-1 == i )); then
            match=1; [[ "$state" == 0 ]] && keep=1
        fi
    done
    [[ ! "$match" && "$state" == 1 || "$keep" ]] || return
    _prompt_menu_result=("${_prompt_menu_result[@]}" "${menu_options[i]}")
}

init_files() {
    local i f dirname
    f=("$@")
    menu_options=(); menu_selects=()
    for i in "${!f[@]}"
    do
        menu_options[i]="$(basename "${f[i]}")"
    done
    prompt_menu "Run the following init scripts?" $prompt_delay
    for i in "${!menu_selects[@]}"
    do
        dir=$(
        for q in "${f[@]}"
        do
            echo "$q"
        done | grep "${menu_selects[i]}"
        )
        echo "https://github.com$dir"
    done
}

list=($(
curl -sSf -L https://github.com/b4b4r07/gomi/releases/latest \
    | egrep -o '/b4b4r07/gomi/releases/download/[^"]*'
curl -sSf -L https://github.com/peco/peco/releases/latest \
    | egrep -o '/peco/peco/releases/download/[^"]*'
))
clear
files=($(init_files "${list[@]}"))

for f in "${files[@]}"
do
    wget "$f"
    case "$f" in
        *.zip)
            unzip "${f##*/}"
            ;;
        *.tar.gz)
            tar xvf "${f##*/}"
            ;;
    esac
    rm -f *.zip *.tar.gz
done
