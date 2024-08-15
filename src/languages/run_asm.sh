run_lang(){
    file=$1
    fwe=$2
    arguments=$3
    if ! command -v nasm  &> /dev/null; then
        importFunctions "install.sh" "install_packages" "nasm"
    fi
    nasm -f elf -o "${fwe}.o" "$file" && {
        ld -m elf_i386 -o "${fwe}.out" "${fwe}.o"
    } && 
    {
        "./${fwe}.out" $arguments
    }&& {
        deleteFile "${fwe}.out" "${fwe}.o"
    }
}