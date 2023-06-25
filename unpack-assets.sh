#!/bin/bash

steam_library=$1
shift

while getopts ":aAu" opt; do
    case $opt in
        a|A) aflag=1;;
        u|U) uflag=1;;
    esac
done

shift $((OPTIND - 1))

if [[ $uflag -eq 1 ]]; then
    starbound="$steam_library/steamapps/common/Starbound - Unstable"
else
    starbound="$steam_library/steamapps/common/Starbound"
fi

starbound_workshop="$steam_library/steamapps/workshop/content/211820"
unpack="$starbound/linux/asset_unpacker"
starbound_assets="$starbound/assets/packed.pak"

unpack_starbound() {
    if [[ -e $starbound_assets ]]; then
        if [[ -d $starbound/_UnpackedAssets ]]; then
            echo "Removing Starbound's old unpacked assets..."
            rm -r $starbound/_UnpackedAssets
            echo "Done."
        fi
        
        echo "Unpacking Starbound's assets..."
        $unpack $starbound_assets $starbound/_UnpackedAssets >/dev/null 2>&1
        echo "Done."
        exit 0
    fi
    
    echo "Starbound's assets not found."
    exit 1
}

unpack_workshop() {
    if [[ -d $starbound_workshop/$1 ]]; then
        if [[ -d $starbound/mods/$1 ]]; then
            echo "Removing $1's old unpacked assets..."
            rm -r $starbound/mods/$1
            echo "Done."
        fi
        
        echo "Unpacking $1's assets..."
        $unpack $starbound_workshop/$1/contents.pak $starbound/mods/$1 >/dev/null 2>&1
        echo "Done."
    else
        echo "$1's assets not found."
        exit 1
    fi
}

unpack_workshop_all() {
    num_mods=0
    for id in $(ls -1 $starbound_workshop); do
        ((num_mods++))
        
        unpack_workshop $id
    done
    
    if [[ $num_mods -eq 0 ]]; then
        echo "No mods found."
        echo "Please install some workshop mods before trying to unpack them."
        exit 1
    fi
    
    echo "Finished unpacking $num_mods mod(s)."
    exit 0
}

if [[ $# -eq 0 || $uflag -eq 1 ]]; then unpack_starbound; fi
if [[ $aflag -eq 1 ]]; then unpack_workshop_all; fi
unpack_workshop $1
exit 0
