#!/bin/bash

# Translations for the 'welcome' app.

tr_indexes=()

# Declare variable that hold translations:
declare -A tr_strings

# Helper functions:
_tr_add() {
    local lang="$1"
    local ix="$2"
    local str="$3"

    tr_strings["Lang_${lang}__$ix"]="$str"

    tr_indexes+=("$ix")
}
_tr_add2() {
    local ix="$1"
    local str="$2"

    # local lang="$_tr_lang"
    # test -n "$lang" || lang="$SELECTED_LANGUAGE_WELCOME"

    if [ -z "$_tr_lang" ] ; then
        echo "Warning: variable '_tr_lang' is not set in the translation file!" >&2
        _tr_lang=en
    fi

    _tr_add "$_tr_lang" "$ix" "$str"
}

ltr() {                                              # puts string to stdout
    local ix="$1"
    local str="${tr_strings["Lang_${SELECTED_LANGUAGE_WELCOME}__$ix"]}"
    test -n "$2" && str+="$2"                        # remove this line some day...
    echo "$str"
}
ltr2() {                                             # puts string to stderr
    ltr "$@" >&2
}

_translate_with_fixes() {
    # Translate English strings to a language stored in variable $lang.
    #
    # Assume strings like the following example:
    #
    #     "<pre1>$PRETTY_PROGNAME</pre1> app is disabled. To start it anyway, use option <pre2>--enable</pre2>."
    #
    # So phrases that may not be modified in any way are surrounded with HTML like prefix and suffix
    #
    #      <preN>this will not be modified</preN>
    #
    # The N in <preN> must be an ordinal number 1...M. Do not bypass numbers, e.g. 1 2 3 5 fails after 3!

    # First, translate the given string.
    local eng2="$1"
    local to="$(echo "$eng2" | sed 's|&#\([0-9]*\);|<bacd\1>|g')"
    local to="$(trans -e $tr_engine -no-autocorrect -no-auto -b "en:$lang" "$to")"

    if [ -z "$to" ] ; then
        echo "$eng2"           # translation failed!
        echo "Warning: translating ix '$ix' failed." > "$HOME/.welcome-translation-${lang}-issue.log"
        return 1
    fi

    # Then fix those parts that weren't supposed to be modified.
    local baN ix=0
    while true ; do
        ((ix++))
        baN="$(echo "$eng2" | sed 's|.*<ba'$ix'(\([^)]*\))>.*|\1|')"
        if [ "$baN" != "$eng2" ] ; then
            to="$(echo "$to" | sed -e 's|<[ ]*ba'$ix'[ ]*([^)]*)[ ]*>|'"$baN"'|g')"  # e.g. every pre1 stuff is changed
        else
            break
        fi
    done
    to="$(echo "$to" | sed 's|<bacd38>|\&#38;|g')"                 # '&'
    to="$(echo "$to" | sed 's|[ ]*<bacd\([0-9]*\)>|\&#\1;|g')"     # '!' and '?'

    #to="$(echo "$to" | sed 's|<bab>|<b>|g')"
    #to="$(echo "$to" | sed 's|</bab>|</b>|g')"
    #to="$(echo "$to" | sed 's|<babr>|<br>|g')"

    echo "$to"
}

_tr_generate() {
    # Automatic translation to "any" language!

    mkdir -p "$trdir2"

    echo "Translating to $lang ..." >&2
    export SELECTED_LANGUAGE_WELCOME="$lang"
    #silent_lang_warnings=yes   # give no more warnings about this language...

    cat <<EOF > $target_gen
# Automatic translation (language: $lang) for the Welcome app.

_tr_lang=$lang

_exclamation='&#33;' # '!'
_and='&#38;'         # '&'
_question='&#63;'    # '?'

EOF

    local tr_indexes_en=(${tr_indexes[*]})
    local ix xx
    local count="${#tr_indexes_en[@]}" j=0

    for ix in "${tr_indexes_en[@]}" ; do
        #echo "$ix"                                          # show something because this is slow...
        ((j++))
        printf "\r%d%% " "$(echo 100*$j/$count | bc)" >&2

        xx="${tr_strings[Lang_en__$ix]}"
        xx="$(_translate_with_fixes "$xx")"
        _tr_add "$lang" "$ix" "$xx"
        xx="$(ltr "$ix")"
        printf "_tr_add2 %-25s \"%s\"\n" "$ix" "$xx" >> $target_gen
    done
    echo "... ${#tr_indexes_en[@]} translations done!" >&2
}

# Initialize translations for the app:
_init_translations() {
    local lang=""
    local generate=no
    local arg
    local tr_engine=""
    local tr_prefer=manual    # or generated
    local trlist trfile
    local errlog=$(mktemp -u /tmp/translations-welcome-XXXXX.errlog)

    for arg in "$@" ; do
        case "$arg" in
            --generate) generate=yes ;;
            --tr-engine=*) tr_engine="${arg#*=}" ;;
            --tr-prefer=*) tr_prefer="${arg#*=}" ;;
            -*) echo "Error: $FUNCNAME: unsupported option '$arg'." >&2 ; return 1 ;;
            *) lang="$arg" ;;
        esac
    done

    local trdir="$translations_dir"   # from Welcome app
    local f1 f2

    # We may have $lang as 'pt' or 'pt_BR' or something else...

    if [ -z "$lang" ] ; then
        f1="$(echo "$LANG" | cut -d '_' -f 1)"
        f2="$(echo "$LANG" | sed "s|^${f1}_\([A-Z@]*[a-z]*\).*$|\1|")"
        if [ -r "$trdir/translations-welcome-${f1}_$f2.bash" ] ; then
            lang="${f1}_$f2"
        elif [ -r "$trdir/translations-welcome-$f1.bash" ] ; then
            lang="$f1"
        fi
    fi

    if [ ! -r "$trdir/translations-welcome-$lang.bash" ] ; then
        echo "Warning: $FUNCNAME: language '$lang' is not recognized, using en." >&2
    fi

    local trdir2="$HOME/.config/ba-generated-translations"              # generated translations go here
    local target_gen="$trdir2/translations-welcome-${lang}-generated.bash"

    if [ "$generate" = "yes" ] ; then
        if [ -z "$tr_engine" ] ; then
            tr_engine=bing
        fi
        source $trdir/translations-welcome-reference.bash
        _tr_generate
        return
    fi

    case "$tr_prefer" in
        manual)
            trlist=(
                "$trdir/translations-welcome-en.bash"
                "$trdir2/translations-welcome-en-generated.bash"
            )
            ;;
        generated)
            trlist=(
                "$trdir2/translations-welcome-en-generated.bash"
                "$trdir/translations-welcome-en.bash"
            )
            ;;
        *)
            echo "option --tr-prefer has unsupported value '$tr_prefer'." >&2
            return 1
            ;;
    esac

    for trfile in "${trlist[@]}" ; do
        if [ -r "$trfile" ] ; then
            #echo "$trfile" >&2
            source "$trfile"
            break
        fi
    done

    local xx ix
    local silent_lang_warnings=no
    local pname="$PRETTY_PROGNAME"
    local selected=0

    export SELECTED_LANGUAGE_WELCOME=en
    if [ "$lang" != "en" ] ; then
        case "$tr_prefer" in
            manual)
                trlist=(
                    "$trdir/translations-welcome-"$lang".bash"
                    "$trdir2/translations-welcome-"$lang"-generated.bash"
                )
                ;;
            generated)
                trlist=(
                    "$trdir2/translations-welcome-"$lang"-generated.bash"
                    "$trdir/translations-welcome-"$lang".bash"
                )
                ;;
        esac

        for trfile in "${trlist[@]}" ; do
            if [ -r "$trfile" ] ; then
                #echo "$trfile" >&2
                export SELECTED_LANGUAGE_WELCOME="$lang"
                source "$trfile"
                selected=1
                if [ "$tr_prefer" = "manual" ] ; then
                    case "$lang" in
                        "de") silent_lang_warnings=yes ;;   # de is not fully translated yet...
                    esac
                fi
                break
            fi
        done

        if [ $selected -eq 0 ] ; then
            echo "Warning: $pname: no translations file for language '$lang' - falling back to '$SELECTED_LANGUAGE_WELCOME'." >&2
            silent_lang_warnings=yes   # give no more warnings about this language...
        fi
    fi

    if [ "$SELECTED_LANGUAGE_WELCOME" != "en" ] ; then
        # Check we have all strings translated. Copy the missing strings from 'en'.
        for ix in "${tr_indexes[@]}" ; do
            xx="${tr_strings["Lang_${lang}__$ix"]}"
            if [ -z "$xx" ] ; then
                if [ "$silent_lang_warnings" = "no" ] ; then
                    echo "Warning: $pname: language '$lang' placeholder '$ix': translation not found, 'en' used as fallback." >> $errlog
                fi
                tr_strings["Lang_${lang}__$ix"]="${tr_strings[Lang_en__$ix]}"
            fi
        done
    fi
    if [ -r $errlog ] ; then
        echo "Info: translation issues detected, see file '$errlog'."
    fi
}
