run_lang(){
    file=$1
    fwe=$2
    if ! command -v gcc &> /dev/null; then
        importFunctions "install.sh" "install_packages" "gcc"
    fi
    gcc "$file" -o "${fwe}.out" && "./${fwe}.out" && {
        deleteFile "${fwe}.out"
    }
}