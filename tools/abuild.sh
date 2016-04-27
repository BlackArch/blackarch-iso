#!/bin/bash
################################################################################
#                                                                              #
# abuild.sh - BlachArchIso Arch Wrapper                                        #
#                                                                              #
# FILE                                                                         #
# abuild.sh                                                                    #
#                                                                              #
# DATE                                                                         #
# 2014-01-03                                                                   #
#                                                                              #
# DESCRIPTION                                                                  #
# BlackArchIso Wrapper for build.sh - it will build one Arch (i686 or x86_64)  #
#                                                                              #
# AUTHOR                                                                       #
# nrz@nullsecurity.net                                                         #
#                                                                              #
################################################################################

VERSION="v0.1.1"

# true / false
FALSE="0"
TRUE="1"

# return codes
SUCCESS="1337"
FAILURE="31337"

# verbose mode - default: quiet
VERBOSE="/dev/null"

# colors
WHITE="$(tput bold ; tput setaf 7)"
GREEN="$(tput setaf 2)"
RED="$(tput bold; tput setaf 1)"
YELLOW="$(tput bold ; tput setaf 3)"
NC="$(tput sgr0)" # No Color


wprintf() {
    fmt=$1
    shift
    printf "%s${fmt}%s\n" "${WHITE}" "$@" "${NC}"

    return "${SUCCESS}"
}

# print warning
warn()
{
    printf "%s[!] WARNING: %s%s\n" "${RED}" "${*}" "${NC}"

    return "${SUCCESS}"
}

# print error and exit
err()
{
    printf "%s[-] ERROR: %s%s\n" "${RED}" "${*}" "${NC}"

    return "${SUCCESS}"
}

# print error and exit
cri()
{
    printf "%s[-] CRITICAL: %s%s\n" "${RED}" "${*}" "${NC}"

    exit "${FAILURE}"
}


# usage and help
usage()
{
    printf "%s" "${WHITE}"
    cat <<EOF
Usage: $0 <arg> | <misc>
OPTIONS:
    -a <ARCH>: build.sh only one arch
ARCH:
    i686
    x86_64
MISC:
    -V: print version and exit
    -H: print help and exit
EOF
    printf "%s" "${NC}"

    exit "${SUCCESS}"
}

# leet banner, very important
banner()
{
    printf "%s--==[ BlackArch build.sh Wrapper by nrz@nullsecurity.net ]==--%s\n" "${YELLOW}" "${NC}"

    return "${SUCCESS}"
}

check_env()
{
    return "${SUCCESS}"
}

# check argument count
check_argc()
{
    if [ ${#} -lt "1" ]; then
        usage
    fi

    return "${SUCCESS}"
}

# check if required arguments were selected
check_args()
{
    return "${SUCCESS}"
}

build_arch()
{
    arch=${1}

    case "${arch}" in
        "i686")
            wprintf "[+] Setting i686 configuration..."
            sed -i 's/dual/i686/' build.sh
            sed -i 's/for arch in i686 x86_64\; do/for arch in i686\; do/' build.sh
            sed -i 's/run_once make_efi/#run_once make_efi/' build.sh
            sed -i 's/run_once make_efiboot/#run_once make_efiboot/' build.sh
            sed -i 's|archiso_sys64.cfg|archiso_sys32.cfg|' syslinux/archiso_sys_both_inc.cfg
            ;;
        "x86_64")
            wprintf "[+] Setting x86_64 configuration..."
            sed -i 's/dual/x86_64/' build.sh
            sed -i 's/for arch in i686 x86_64\; do/for arch in x86_64\; do/' build.sh
            sed -i 's|archiso_sys32.cfg|archiso_sys64.cfg|' syslinux/archiso_sys_both_inc.cfg
            ;;
    esac

    wprintf "[+] Done! Building ISO..."
    ./build.sh -v

    return "${SUCCESS}"
}

# parse command line options
get_opts()
{
    while getopts a:vVH flags
    do
        case "${flags}" in
            a)
                optarg=${OPTARG}
                opt="arch"
                ;;
            v)
                VERBOSE="/dev/stdout"
                ;;
            V)
                printf "%s\n" "${VERSION}"
                exit "${SUCCESS}"
                ;;
            H)
                usage
                ;;
            *)
                err "WTF?! mount /dev/brain"
                ;;
        esac
    done

    return "${SUCCESS}"
}


# controller and program flow
main()
{
    banner
    check_argc ${*}
    get_opts ${*}
    check_args ${*}
    check_env

    # commented arg opt
    if [ "${opt}" == "arch" ]; then
        build_arch "${optarg}"
    fi

    return "${SUCCESS}"
}


# program start
main ${*}

# EOF
