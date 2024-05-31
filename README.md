---

# Runner

Runner is a  command-line tool (run) designed to execute code files in various supported languages and provide additional functionalities. Supports only linux

## Installation

To install Command Runner, clone the repository and run the installation script:

```bash
sudo git clone https://github.com/sreecharan7/runner.git && cd runner && sudo bash install.sh && cd .. && sudo rm -rf runner
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
- `-t`: Run the latest edited file in the current directory (no need for arguments).
- `-b <batch name>`: Run specific batch commands defined by `<batch name>`.

### More Options

- `--help`: Display how the command works.
- `--version`: Show version information.
- `--update`: Update to the latest version of the command.
- `--addb`: Add a new batch for batch execution.
- `--editb`: Edit an existing batch.

### Examples

```bash
run myfile.cpp       # Run a C++ file.
run -i python        # Install or upgrade Python packages.
run -d myfile.c      # Delete executable of a C file.
run -m "[1-9].c$"    # Find and run numbered C files (e.g., 1.c, 12.c).
run -m .             # Run all supported files in the current directory.
run -b batch1        # Run commands defined in batch1.
```

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions, please create an issue or submit a pull request in this repository.


---
