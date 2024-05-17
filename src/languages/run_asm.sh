run_lang(){
    file=$1
    fwe=$2
    if ! command -v nasm  &> /dev/null; then
        importFunctions "install.sh" "install_packages" "nasm"
    fi
    nasm -f elf -o "${fwe}.o" "$file" && {
        ld -m elf_i386 -o "${fwe}.out" "${fwe}.o"
    } && "./${fwe}.out" && {
        deleteFile "${fwe}.out" "${fwe}.o"
    }
}