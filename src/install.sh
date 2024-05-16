
install_packages() {
    local package_name="$1"
    local type="${2:-1}"  # Setting a default value if $2 is not provided
    local pm=''  # Package manager
    local epm=''  # Extra pm

    case "$type" in
        1) pm='apt-get'; epm='install' ;;
        2) pm='yum'; epm='install' ;;
        3) pm='pacman'; epm='-S' ;;
        *)
            echo "Package manager not found. Please install $package_name manually."
            exit 2
            ;;
    esac

    echo "$package_name is getting installed with $pm..."
    sleep 2

    if [ -x "$(command -v "$pm")" ]; then
        sudo "$pm" "$epm" -y "$package_name" &&
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