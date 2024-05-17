usage() {
    cat << EOF
Usage: run [options] <filename>
    
This command runs code files in various supported languages.
Supported languages: asm, c, cpp, java, py, node.js.

Options:
    -i <packages>    Install or upgrade packages.
    -d               Delete the executable file after running (keeps source).
    -m <pattern>     Use grep to find pattern in files.
    -c               Provide filename and separate code with lines after execution.
    -t               Run the latest edited file in the current directory (no need of arguments).

More Options:
    --help           Display this help message.
    --version        Show version information.
    --update         Update to the latest version of the command.

Examples:
    run myfile.cpp      # Run a C++ file.
    run -i python       # Install or upgrade Python packages.
    run -d myfile.c     # Delete executable of a C file.
    run -m "[1-9].c$"   # Find and run numbered C files (e.g., 1.c, 12.c).
    run -m .            # Run all supported files in the current directory.
EOF
}
