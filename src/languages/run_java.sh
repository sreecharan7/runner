run_lang(){
    file=$1
    fwe=$2
    if ! command -v java  &> /dev/null; then
        importFunctions "install.sh" "install_packages" "openjdk"
    fi
    javac "$file" && {
        cpf=$(java "$file" 2>&1 | awk '{print $NF}')
        java "${cpf}"
    } && {
        deleteFile "${cpf}.class"
    }
}