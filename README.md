---

# Runner

Runner is a  command-line tool (run) designed to execute code files in various supported languages and provide additional functionalities. Supports only in linux

## Installation

To install Command Runner, clone the repository and run the installation script:
### Linux Installation Steps

```bash
sudo apt install -y git && sudo git clone https://github.com/sreecharan7/runner.git && cd runner && sudo bash install.sh && cd .. && sudo rm -rf runner
```

### Windows Installation Steps

1. **Install WSL (Windows Subsystem for Linux)**:
   Open PowerShell as Administrator and run the following command:
   ```powershell
   wsl --install
   ```
   Follow the prompts to complete the installation of WSL.

2. **Install Command Runner**:
   Once WSL is installed , open the WSL terminal ( just type "wsl" in terminal ) and run the following commands:
   ```bash
   sudo apt install -y git && sudo git clone https://github.com/sreecharan7/runner.git && cd runner && sudo bash install.sh && cd .. && sudo rm -rf runner
   ```

This command clones the repository, runs the installation script, and cleans up after installation.

## Usage

```
run [options] <filename>
```

### Supported Languages

Command Runner supports the following languages:
- asm
- c
- cpp
- java
- py (Python)
- node.js

### Options

- `-i <packages>`: Install or upgrade packages for the specified language.
- `-d`: Delete the executable file after running (keeps source).
- `-m <pattern>`: Uses grep to find a pattern in files before execution.
- `-c`: Provide filename and separate code with lines after execution.
- `-a`: Provide arguments to the running program (use quotations for better results)
- `-t`: Run the latest edited file in the current directory (no need for arguments).
- `-b <batch name>`: Run specific batch commands defined by `<batch name>`.

### More Options

- `--help`: Display how the command works.
- `--version`: Show version information.
- `--update`: Update to the latest version of the command.
- `--uninstall`: To unistall command.
- `--cleanup`: Removes all files end with *.exe | *.o | *.out
- `--addb`: Add a new batch for batch execution.
- `--editb`: Edit an existing batch.
- `--listb`: List the all bacth.
- `--deleteb`: Delete an existing batch.
- `--share`: This  is used for sharing files in same network

**Usage:** `run --share <operation type>`

**Operation Types:**
1. `share`
2. `receive`

**All options are optional.**

**run --share send <filepath/folderpath>**

**Share Options:**
- `-p`  Specify the password for the sharing file (if not provided, the password will not be saved).
- `-s`  Enter the password after the command is run for secure password entry without displaying it.
- `-n`  Set the name that receivers will see.

**Receive Options:**
- `-o`  Specify where the downloaded or received file should be stored (default is the current directory).
- `-i`  Specify the IP address to receive from.
- `-p`  Specify the port from which the file is being hosted.


### Examples

```bash
run myfile.cpp       # Run a C++ file.
run -i python        # Install or upgrade Python packages.
run -d myfile.c      # Delete executable of a C file.
run -m "[1-9].c$"    # Find and run numbered C files (e.g., 1.c, 12.c).
run -m .             # Run all supported files in the current directory.
run -b batch1        # Run commands defined in batch1.
run --share send ./  # to share a file to local network
run -a 'argument' 1.py # Gives argument to the program 
run --share receive  # to recive a file from local neetwork
```

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions, please create an issue or submit a pull request in this repository.


---
