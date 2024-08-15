run_lang(){
    file=$1
    fwe=$2
    arguments=$3
    if ! command -v java  &> /dev/null; then
        importFunctions "install.sh" "install_packages" "openjdk-21-jdk"
    fi
    javac "$file" && {
        java "${fwe}" $arguments
    } && {
        deleteFile "${fwe}.class"
    }
}