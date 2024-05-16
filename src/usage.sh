usage() {
       cat << EOF
This is a code runner command.
Supported languages: asm, c, cpp, java, py, node.js, sh.
Usage:
    <filename> - Detects file type and runs.
    -i <packages> - Installs or upgrades packages.
    -d  - Deletes the executable code and keeps the source.
    -m  - Uses grep to find pattern.
    -c  - Will provide comments while running multiple files used when -m is used 
Examples:
    run myfile.cpp           # Run a C++ file.
    run -i python            # Install or upgrade python
    run -d myfile.c          # Delete the executable of a C file.
    run -m "[1-9].c$"        # Runs all numbered c files eg:-1.c,12.c
    run -m .                 # Runs all files in that dictionary that are supported
EOF
}