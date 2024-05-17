run_lang(){
    file=$1
    fwe=$2
    if ! command -v nodejs   &> /dev/null; then
        importFunctions "install.sh" "install_packages" "nodejs"
    fi
    node "$file"
}