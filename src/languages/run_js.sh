run_lang(){
    file=$1
    fwe=$2
    arguments=$3
    source ~/.nvm/nvm.sh  2>/dev/null
    if ! command -v node   &> /dev/null; then
        echo "installing the nodejs ( latest version ) using nvm ...."
        sleep 2
        if ! command -v curl   &> /dev/null; then
            importFunctions "install.sh" "install_packages" "curl"
        fi
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
        source ~/.nvm/nvm.sh
        if ! command -v nvm   &> /dev/null; then
            echo "unable to install nvm, install nodejs manually"
            exit 76
        fi
        nvm install node
        if ! command -v node   &> /dev/null; then
            echo "unable to install nodejs, install manually"
            exit 76
        fi
    fi
    node "$file" $arguments
}