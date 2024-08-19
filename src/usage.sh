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
    -a               Provide arguments to the running program (use quotations for better results)
    -t               Run the latest edited file in the current directory (no need of arguments).
    -b <batch name>  Run the specific batch commands.

More Options:
    --help           Display's the how command work's.
    --version        Show version information.
    --update         Update's to the latest version of the command.
    --uninstall      Uninstall the command.
    --reinstall      Reinstalls the command.
    --cleanup        Removes all files end with *.exe | *.o | *.out.
                     Can pass arguments (using -a) to find. It uses find command to search files
    --addb           Add a new batch.
    --editb          Edit an existing batch.
    --listb          List the all bacth
    --deleteb        Delete an existing batch.
    --installdepend  Installs all the dependencies.
    --share          This  is used for sharing files in same network. 
                     To know more about this, type (run --share help).

Examples:
    run myfile.cpp      # Run a C++ file.
    run -i python       # Install or upgrade Python packages.
    run -d myfile.c     # Delete executable of a C file.
    run -a 'argument' 1.py # Gives argument to the program  
    run -m "[1-9].c$"   # Find and run numbered C files (e.g., 1.c, 12.c).
    run -m .            # Run all supported files in the current directory.
    run --cleaup -a '-maxdepth 3' # Delete all executable files at a depth of 3 folders.      
    run --share send .  # This will start the broadcasting or sending of 
                          all files in the current directory
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

share_usage(){
    cat << EOF
Usage: run --share <operation type>

Operation Types:
  1) share
  2) receive

All options are optional.

run --share send <filepath/folderpath>

Share Options:
  -p  Specify the password for the sharing file (without this, the password will not be kept and password should have spaces).
  -s  Enter the password after the command is run for secure password entry without displaying it.
  -n  Set the name that receivers will see.

Receive Options:
  -o  Specify where the downloaded or received file should be stored (default is the current directory).
  -i  Specify the IP address to receive from.
  -p  Specify the port from which the file is being hosted.

Examples:
    run --share send .
    run --share send ./file -p 123
    run --share send /home/user/folder -n user -s
    run --share receive
    run --share receive -o ./destination
    run --share receive -i 172.16.55.87 -p 4000
EOF
}
