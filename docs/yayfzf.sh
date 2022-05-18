#!/usr/bin/env bash
#yayfzf2.sh
########################################
#[============== YAYFZF ==============]#
########################################

##-------- OPTIONS --------##
packages_sort_by="votes"
use_color="always"
REQUESTSPLITN=100

#searchFunction="yay --sync --search --quiet --sortby $packages_sort_by $SearchInput" #(not currently used)
detailedPreview="yay --sync --info --info --verbose --color $use_color "
installPackage="yay --sync --verbose --color $use_color --nobatchinstall --confirm"
##-------------------------##

PRODUCTNAME="yayfzf"
VERSION="0.1.2"
LICENSE="GNU General Public License, version 3"
WEBSITE="https://github.com/ConnerWill/yayfzf"
AUTHOR="ConnerWill"
DATE="2022-05-05"

source ./KEYBINDINGS.conf
#KEYBINDINGS="\
#        Alt+d       Install Package(s)
#        PageDn      Scroll One Page Down
#        PageUp      Scroll One Page Up
#        Home        Top
#        End         Bottom
#        Tab         Select
#        Ctrl+d      Deselect All
#        Ctrl+l      Clear Query
#        Ctrl+v      Toggle Preview Window
#        Ctrl+/      Change Layout
#        Ctrl+h      Show Help
#        ?           Show Help
#        Ctrl+q      Exit
#        Esc         Exit"

function _version() {
	cat <<EOS
========================================================
    NAME    :    ${PRODUCTNAME}
    VERSION :    v${VERSION}
    DATE    :    ${DATE}
    LICENCE :    ${LICENSE}
    AUTHOR  :    ${AUTHOR}
    WEBSITE :    ${WEBSITE}/${AUTHOR}
========================================================
EOS
}

function _help() {
	cat <<EOS

    NAME
        yayfzf

    DESCRIPTION
        search and install packages from the AUR with fzf

    USAGE
        yayfzf    KEYWORDS...
        yayfzf    -h|--help
        yayfzf    -V|--version

    KEYBINDINGS
$KEYBINDINGS

========================================================
EOS
}

SHORTKEYBINDINGS="\
Alt+d           Install Package(s)
[Tab/Ctl+Tab]   [Select/Deselect]
Page[Dn/Up]     Page [Down/up]
[Home/End]      [Top/Bottom]
Ctrl+/          Change Layout
?|Ctl+h         Help
Esc|Ctl+q       Exit"

function _short_help() {
	cat <<EOS
$SHORTKEYBINDINGS
EOS
}

##---------------##
### Main Script ###
##---------------##

## Error messege
function _err() {
	printf "\n[\e[31m WARNING \e[m] %s\n" "${*}"
	echo -e -n "\nSearch yay\n\nInput Required!\nPlease Enter Initial Search Query: "
	read -r SearchInput
	[[ -z "$SearchInput" ]] && return 1
	_main "${SearchInput}"
}

## Check if user sent a search query when running.
## If no input received, show warning and the help menu,
## then prompt for input. If input is still empty, Exit.
function _main() {
	if [[ "${#}" -le 0 ]]; then
		_version
		_help
		_err "No Input Received ..."
		return 1
		_main
	fi
	for arg in "${@}"; do
		case "${arg}" in
		-h | --help)
			_help
			return 0
			;;
		-V | --version)
			_version
			return 0
			;;
		esac
	done
	clear
	_search_packagemgr "${*}" | _fzf
}

## Search package manager
function _search_packagemgr() {
	local searchQuery
	searchQuery="${*}"
	yay \
		--sync \
		--search \
		--requestsplitn "$REQUESTSPLITN" \
		--quiet \
		--sortby "$packages_sort_by" \
		--searchby name \
		"$SearchInput"
}

## Main script. Run fzf with package manager search results.
function _fzf() {
	fzf </dev/stdin \
		--query "$SearchInput" \
		--print-query \
		--select-1 \
		--exit-0 \
		--no-clear \
		--extended \
		--tac \
		--no-sort \
		--keep-right \
		--header "${KEYBINDINGS}" \
		--header-first \
		--header-lines=0 \
		--multi \
		--marker="✔ " \
		--prompt="> " \
		--pointer="[>" \
		--info=inline \
		--height=100% \
		--ansi \
		--color='16,bg:#1A1A1A,bg+:#333333,info:#999999,border:#999999,spinner:#F5F5F5' \
		--color='hl+:#BD2C00,hl:#4078C0,fg:#C1C1C1,fg+:#FFFFFF,header:#666666,preview-bg:#333333' \
		--color='header:#666666,query:#4183c4,pointer:#BD2C00,marker:#6CC644,prompt:#F5F5F5' \
		--color='gutter:#141414' \
		--layout 'default' \
		--preview "$detailedPreview {}" \
		--preview-window "right:65%" \
		--margin 0%,0% \
		--padding 3%,2% \
		--border "rounded" \
		--delimiter=" " \
		--tabstop=4 \
		--filepath-word \
		--scroll-off=0 \
		--hscroll-off=100 \
		--expect=ctrl-c,esc \
		--bind "alt-d:execute: echo 'Installing: {+}' && sleep 1 && $installPackage {+} || echo '\nERROR Installing: {+}\nReturn to yayfzf? (Y/n' ; read -s -q || exit ||  echo  'Return to yayfzf? (Y/n)' ; read -s -q || exit" \
		--bind 'pgdn:page-down' \
		--bind 'pgup:page-up' \
		--bind 'home:last' \
		--bind 'end:first' \
		--bind 'ctrl-/:change-preview-window(up,border-rounded|up,40%,border-rounded|left,border-rounded|left,border-rounded,40%|down,border-rounded|down,40%,border-rounded|down,10%,border-rounded|hidden|right,40%,border-rounded|right,70%,border-rounded|right,90%,border-rounded)' \
		--bind 'ctrl-v:toggle-preview' \
		--bind "?:preview: less $SHORTKEYBINDINGS" \
		--bind "f1:preview: echo $SHORTKEYBINDINGS" \
		--bind "ctrl-h:preview: echo $SHORTKEYBINDINGS" \
		--bind 'tab:select' \
		--bind 'shift-tab:deselect' \
		--bind 'ctrl-d:deselect-all' \
		--bind 'alt-left:kill-word' \
		--bind 'alt-bspace:clear-query' \
		--bind 'ctrl-l:clear-query' \
		--bind 'ctrl-q:print-query' \
		--bind "esc:accept-non-empty"
}

function yayfzf() {
	_main "${@}"
}

##---------------##
###  END MAIN   ###
##---------------##


### TODO:
##
##      Add Next/Previous page function
###
#        --bind "ctrl-n:reload(_next_page)"  \
#        --bind "ctrl-p:reload(_previous_page)
#
#   gh_page_number_max=3
#
#    function _next_page(){
#        [[ "$gh_page_number" -lt "$gh_page_number_max" ]] && gh_page_number=$((gh_page_number-1))
#        _main "$query"
#        return
#    }
#
#    function _previous_page(){
#        [[ "$gh_page_number" -gt 1 ]] && gh_page_number=$((gh_page_number-1))
#        _main "$query"
#        return
#    }
###

### TODO
#        --bind "ctrl-i:header ${SHORTKEYBINDINGS}" \
