run_lang(){
    file=$1
    fwe=$2
    arguments="$3"
    if ! command -v g++ &> /dev/null; then
        importFunctions "install.sh" "install_packages" "g++"
    fi
    g++ "$file" -o "${fwe}.out" && { 
        "./${fwe}.out" $arguments 
    } && {
        deleteFile "${fwe}.out"
    }
}