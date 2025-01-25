update_run(){

    # calling the fecth data fucntion and collecting the data from server

    fencth_data
    
    latest_version=$(echo "$json" | jq -r '.version');

    if [[ ${latest_version} == ${curent_version} ]];then
        echo "you have the latest version"
        exit
    fi

    echo "update avaliable $latest_version"
    echo "upgrading from  $curent_version --> $latest_version"

    install_run   

    echo -e "\e[32mupdated sucessfully from $curent_version to $latest_version version\e[0m\n"
}

reinstall_run(){
    echo "reinstalling the run..."
    fencth_data
    install_run
    echo -e "\e[32mreinstalled run sucessfully...\e[0m\n"
}

fencth_data(){
    if ! command -v jq &> /dev/null  || ! command -v curl &> /dev/null ; then
        echo "installing some dependencies"
        importFunctions "install.sh" "install_packages" "jq"
        importFunctions "install.sh" "install_packages" "curl"
    fi
    curent_version=$(jq -r '.version' "${src}/details.json")

    url=$(jq -r '.url' "${src}/details.json")

    json=$(curl -s "$url")


    if [ $? -ne 0 ]; then
        echo "Failed to fetch JSON data from $url"
        exit 1
    fi
}

install_run(){
    # requires some data from parent funcntion (nedded a variable json)
    readarray -t array < <(echo "$json" | jq -r '.installCommands[]')

    if [ $? -ne 0 ]; then
        echo "Failed to parse JSON data"
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        echo "installing some dependencies"
        importFunctions "install.sh" "install_packages" "git"
    fi
    
    for element in "${array[@]}"; do
        $element
        if [[ $? != 0 ]];then
            echo "something went wrong while updating pls try again";
            exit 11
        fi
    done
}


install_dependencies(){
    echo "installing dependecies...."  
    declare -a dependencies=(
        "python3"
        "curl"
        "lsof"
        "tar"
        "nano"
        "ipcalc"
        "gsocket"
    )
    
    for de in "${dependencies[@]}";do
        if ! command -v ${de} 1>/dev/null;then
             importFunctions "install.sh" "install_packages" "${de}" 
        fi
    done

    if ! command -v ifconfig &> /dev/null; then
        importFunctions "install.sh" "install_packages" "net-tools"
    fi
    if ! grep -q "^Subsystem.*sftp" /etc/ssh/sshd_config; then
            importFunctions "install.sh" "install_packages" "openssh-server"
            echo -e "\033[0;33m***Waring if error persisted please make sure to run the sftp-server***\033[0m"
    fi

    libraries=("requests" )
    for lib in "${libraries[@]}"; do
        install_python_library "$lib"
    done
    echo "installed depencies sucessfully..."
}

install_python_library() {
    local library=$1

    python3 -c "import $library" 2>/dev/null 1>/dev/null
    if [ $? -ne 0 ]; then
        echo "$library is not available. Installing..."

        if ! command -v pip3 &> /dev/null ; then
            echo "pip3 is not installed. Installing pip3..."
            sudo apt update
            sudo apt install -y python3-pip
        fi

        pip3 install $library
        if [ $? -eq 0 ]; then
            echo "$library has been installed successfully."
        else
            echo "Failed to install $library."
        fi
    fi
}
