run_lang(){
    file=$1
    fwe=$2
    if ! command -v python3   &> /dev/null; then
        importFunctions "install.sh" "install_packages" "python3"
    fi
    python3 "$file"
}