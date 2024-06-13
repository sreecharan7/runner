
install_packages() {
    local package_name="$1"
    local type="${2:-1}"  # Setting a default value if $2 is not provided
    local pm=''  # Package manager
    local epm=''  # Extra pm
    local bpm='sudo'  # before pm
    local options='' #options

    case "$type" in
        1) pm='apt-get'; epm="install" options='-y';;
        2) pm='yum'; epm='install'; options='-y' ;;
        3) pm='pacman'; options='-S';;
        4) bpm='';pm='pkg';epm='intall' ;;
        *)
            echo "Package manager not found. Please install $package_name manually."
            exit 2
            ;;
    esac

    echo "$package_name is getting installed with $pm..."
    sleep 2

    if [ -x "$(command -v "$pm")" ]; then
        "$bpm" "$pm" "$epm" "$options" "$package_name" &&
        echo "$1 installed successfully using $pm" ||
        {
            ((type++))
            install_packages "$1" "$type"
        }
    else
        ((type++))
        install_packages "$1" "$type"
    fi
}