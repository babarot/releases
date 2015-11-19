#!/bin/bash

trap 'cleanup; exit 1' ERR INT

die() {
    echo "$@" >&2
    exit 1
}

cleanup() {
    rm -f *.zip *.tar.gz *.tgz
}

# Logging stuff.
e_header()   { echo -e "\n\033[1m$@\033[m"; }
e_arrow()    { echo -e " \033[1;34m=>\033[m  $@"; }
e_success()  { echo -e " [\033[1;31mx\033[m]  $@"; }
e_error()    { echo -e " [\033[1;31m \033[m]  $@"; }

# Display a fancy multi-select menu.
# Inspired by http://serverfault.com/a/298312
prompt_menu() {
    local prompt nums
    prompt="Toggle options (Separate options with spaces, ENTER when done): "
    while clear; _prompt_menu_draws "$1" 1 && read -rp "$prompt" nums && [[ "$nums" ]]
    do
        _prompt_menu_adds $nums
    done 1>&2
    _prompt_menu_adds
}

_prompt_menu_iter() {
    local i sel state
    local fn=$1; shift
    for i in "${!menu_options[@]}"
    do
        state=0
        for sel in "${menu_selects[@]}"
        do
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
    for n in "$@"
    do
        if [[ $n =~ ^[0-9]+$ ]] && (( n-1 == i )); then
            match=1; [[ "$state" == 0 ]] && keep=1
        fi
    done
    [[ ! "$match" && "$state" == 1 || "$keep" ]] || return
    _prompt_menu_result=("${_prompt_menu_result[@]}" "${menu_options[i]}")
}

releases_list() {
    local i f q
    f=("$@")
    menu_options=(); menu_selects=()
    for i in "${!f[@]}"
    do
        menu_options[i]="$(basename "${f[i]}")"
    done
    prompt_menu "Which binaries do you download?" $prompt_delay
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

main() {
    # Check L
    [[ $L ]] || die "please specify user/repo as the L variable"
    [[ $L =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]] || die "$L: L consists of username/reponame"

    local list files
    list=($(
    curl -sSf -L https://github.com/$L/releases/latest \
        | egrep -o '/'"$L"'/releases/download/[^"]*'
    ))

    if (( ${#list} < 1 )); then
        die "$L: there are no available releases"
    fi

    clear
    files=($(releases_list "${list[@]}"))

    local f
    for f in "${files[@]}"
    do
        wget "$f"
        case "$f" in
            *.zip)
                unzip "${f##*/}"
                ;;
            *.tar.gz|*.tgz)
                tar xvf "${f##*/}"
                ;;
        esac
        cleanup
    done
}

main
