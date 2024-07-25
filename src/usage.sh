usage() {
    cat << EOF
Usage: run [options] <filename>
    
This command runs code files in various supported languages.
Supported languages: asm, c, cpp, java, py, node.js.

Options:
    -i <packages>    Install or upgrade packages.
    -d               Delete the executable file after running (keeps source).
    -m <pattern>     Use's grep to find pattern in files.
    -c               Provide filename and separate code with lines after execution.
    -t               Run the latest edited file in the current directory (no need of arguments).
    -b <batch name>  Run the specific batch commands.

More Options:
    --help           Display's the how command work's.
    --version        Show version information.
    --update         Update's to the latest version of the command.
    --uninstall      Uninstall the command.
    --cleanup        Removes all files end with *.exe | *.o | *.out
    --addb           Add a new batch.
    --editb          Edit an existing batch.

Examples:
    run myfile.cpp      # Run a C++ file.
    run -i python       # Install or upgrade Python packages.
    run -d myfile.c     # Delete executable of a C file.
    run -m "[1-9].c$"   # Find and run numbered C files (e.g., 1.c, 12.c).
    run -m .            # Run all supported files in the current directory.
EOF
}

addb_create_file_usage() {
    cat << EOF

Now, nano will open. Write your commands as you want.
Do not change the file name as it will create issues.
To save the file in nano, press Ctrl+S.
To exit the file in nano, press Ctrl+X.

Examples of bundling commands:

1) Separate commands:
    npm i
    npm run dev

2) Combined commands with '&&':
    npm i && npm run dev

3) Combined commands with '&&' and '||' for error handling:
    { npm i && npm run dev } || { sudo apt-get install npm }

EOF
}