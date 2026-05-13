#!/usr/bin/env bash

# yayfzf - bash completion

_yayfzf_complete() {
    local cur prev words cword
    local -a themes opts long_opts short_opts

    _init_completion || return

    COMPREPLY=()

    themes=(
        default
        light
        tokyo-night
        neon
        catppuccin-mocha
        catppuccin-latte
        dracula
        gruvbox-dark
        gruvbox-light
        nord
        solarized-dark
        solarized-light
        rose-pine
        rose-pine-moon
        rose-pine-dawn
        onedark
        kanagawa
    )

    long_opts=(
        --help
        --help-man
        --keybindings
        --init-config
        --show-config
        --theme
        --theme=
        --verbose
        --version
    )

    short_opts=(
        -h
        -k
        -i
        -s
        -t
        -v
        -V
    )

    opts=(
        "${short_opts[@]}"
        "${long_opts[@]}"
    )

    # Complete theme names after: yayfzf -t <TAB>
    case "${prev}" in
        -t|--theme)
            mapfile -t COMPREPLY < <(compgen -W "${themes[*]}" -- "${cur}")
            return 0
            ;;
    esac

    # Complete theme names after: yayfzf --theme=<TAB>
    if [[ ${cur} == --theme=* ]]; then
        local theme_prefix
        theme_prefix="${cur#--theme=}"

        mapfile -t COMPREPLY < <(compgen -W "${themes[*]}" -- "${theme_prefix}")

        # Add the --theme= prefix back onto each completion result.
        COMPREPLY=("${COMPREPLY[@]/#/--theme=}")
        return 0
    fi

    # Complete long options.
    if [[ ${cur} == --* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "${long_opts[*]}" -- "${cur}")
        return 0
    fi

    # Complete short options.
    if [[ ${cur} == -* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "${short_opts[*]}" -- "${cur}")
        return 0
    fi

    # If we're at position 1, show options only.
    if (( cword == 1 )); then
        mapfile -t COMPREPLY < <(compgen -W "${opts[*]}" -- "${cur}")
        return 0
    fi

    # After any recognized no-argument option, complete nothing.
    case "${prev}" in
        -h|--help|--help-man|-k|--keybindings|-i|--init-config|-s|--show-config|-v|--verbose|-V|--version)
            return 0
            ;;
    esac

    # Fallback: complete nothing.
    return 0
}

complete -F _yayfzf_complete yayfzf
