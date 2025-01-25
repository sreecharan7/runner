
send() {
    echo "starting the sending service";

    filepath=$(check_path_and_compress "$1");
    if [ $? -ne 0 ]; then
        echo "$filepath"
        echo "File/Folder not found or something went wrong"
        exit 43
    fi

    if [ ! $? -eq 0  ];then
        echo ${filepath}
    fi

    

    password=""
    name=""
    global=""

    shift

    while getopts ":p:n:sg" opt; do
        case ${opt} in
            p ) password="$OPTARG" ;;
            n ) name="$OPTARG";;
            s ) if [ -n "$password" ]; then
                    echo "Error: -s and -p cannot be used together." 1>&2
                    exit 3
                fi
                read -sp "Enter the password:-" password;;
            g )  global="true";;
            \? ) recommd_command "--share send ${@}";echo -e "Invalid option: -$OPTARG\nto know more type \033[1;32mrun --share help\033[0m" 1>&2
                 exit 3 ;;
            : ) echo "Option -$OPTARG requires an argument." 1>&2
                exit 3 ;;
        esac
    done
    scripts_src="${src}/scripts";

    if [[ "${global}" == "true" ]];then
        if [[ -z "${password}" ]];then
            echo -e "\e[31mpassword is required for global option\nuse -p or -s option after filename/foldername\e[0m"
            echo "to know more run --share help"
            exit
        fi
        sha=$(echo "${password}"| sha256sum | cut -d ' ' -f1 )
        mkdir -p "/tmp/runner/${sha}" 2>/dev/null
        mv "${filepath}" "/tmp/runner/${sha}/file"
        echo "$(basename "${filepath}")" > "/tmp/runner/${sha}/filename"
        cd "/tmp/runner/${sha}"
        echo -e "\033[0;35m\n(press (ctrl+c) to stop)\033[0m"
        if ! command -v gsocket &> /dev/null;then
            importFunctions "install.sh" "install_packages" "gsocket"
        fi
        if ! grep -q "^Subsystem.*sftp" /etc/ssh/sshd_config; then
            importFunctions "install.sh" "install_packages" "openssh-server"
            echo -e "\033[0;33m***Waring if error persisted please make sure to run the sftp-server***\033[0m"
        fi
        gs-sftp -s "${password}" -l
        if [[ $! != 0 ]];then
            echo -e "\e[31mchange the password that may aldready in use\e[0m"
        fi
        exit
    fi

    if ! command -v python3 &> /dev/null ; then
        importFunctions "install.sh" "install_packages" "python3"
    fi
    
    python3  "${scripts_src}/filehosting.script.py" "${filepath}" --password ${password}  &
    SERVER_FILE_HOSTING_PID=$!

    sleep 2

    if ! command -v lsof &> /dev/null || ! command -v ifconfig &> /dev/null; then
        echo -e "installing some dependencies..."
        importFunctions "install.sh" "install_packages" "lsof"
        importFunctions "install.sh" "install_packages" "net-tools"
    fi

   port=$(lsof -nP -iTCP -sTCP:LISTEN | grep $(ps -p $SERVER_FILE_HOSTING_PID -o comm=) | awk '{print $9}' | cut -d: -f2 | tail -n 1)

    if [[ -z "$port" ]];then
        echo -e "\033[1;31msomething went wrong, try again\033[0m";
        kill $SERVER_FILE_HOSTING_PID
        exit 45
    fi

    
    if [ -z "$name" ]; then
        name=$(echo $USER)
    fi

    SERVER_BROADCASATING_kill=""
    ip_data=""

    if grep -q "microsoft" /proc/version; then
        echo "Detected, Running on WSL"
        importFunctions "wsl/share.sh" 
        start_the_broadcast_in_windows "${port}" "${name}"
    else
        ip_data=$(for iface in $(ls /sys/class/net/); do
                BROADCAST_IP=$(ifconfig $iface 2>/dev/null | grep 'broadcast' | awk '{print $6}')
                IP4_ADDR=$(ifconfig $iface 2>/dev/null | grep 'inet ' | awk '{print $2}')
                if [ -n "$BROADCAST_IP" ] && [ -n "$IP4_ADDR" ]; then
                    echo "$IP4_ADDR $BROADCAST_IP"
                fi
            done );
        python3  "${scripts_src}/broadcast.script.py" "${ip_data}" "${port}" "${name}" 1>/dev/null &
        SERVER_BROADCASATING_PID=$!
        SERVER_BROADCASATING_kill="kill ${SERVER_BROADCASATING_PID}"
    fi

    # extracting the ip adress data
    ip_result=$(echo "$ip_data" | awk '{print $1}' | awk '{printf "%s, ", $0}' | sed 's/, $//')


    echo -e "\033[1;32mStarted the broadcasting service
By Name:- \033[1;34m${name}\033[1;32m , Port:- \033[1;34m${port}\033[1;32m
Ip adress are  \033[1;34m${ip_result}\033[0m
(press (ctrl+c) to stop)"

    cleanup(){
        echo -e "\033[1;31mstoping the broadcasting service\033[0m"
        kill $SERVER_FILE_HOSTING_PID
        if grep -q "microsoft" /proc/version; then
            SERVER_BROADCASTING_PIDS=$(powershell.exe -Command "Get-Process -Name 'Runbroadcast' | Select-Object -ExpandProperty Id")
            if [[ -n "$SERVER_BROADCASTING_PIDS" ]]; then
                for PID in $SERVER_BROADCASTING_PIDS; do
                    powershell.exe -Command "Stop-Process -Id $PID" 2>/dev/null
                done
            else
                echo "No 'broadcast' process found."
            fi
        fi
        eval $SERVER_BROADCASATING_kill 2>/dev/null
        wait $SERVER_FILE_HOSTING_PID 2>/dev/null
        wait $SERVER_BROADCASATING_PID 2>/dev/null
        echo -e "\033[1;32mstoped the broadcasting service, sucessfully\033[0m"
        exit
    }
    
    trap cleanup SIGINT
    while true; do
        sleep 10000
    done
}


check_path_and_compress() {
    if [ -z "$1" ]; then
        echo -e "please provide the file/folder path.
to know more type \033[1;32mrun --share help\033[0m"
        exit 42
    fi
    path="$1"
    if [ -d "$path" ]; then
        if ! command -v tar &> /dev/null; then
            importFunctions "install.sh" "install_packages" "tar" 1>/dev/null
        fi
        mkdir -p /tmp/runner 2>/dev/null
        tar -czvf "/tmp/runner/$(basename "${path}").tar.gz" -C "${path}" . 1>/dev/null
        if [ ! $? -eq 0 ]; then
            echo -e "\033[1;31mUnable to process the folder, please try again\033[0m";
            exit 44
        fi
        echo "/tmp/runner/$(basename "${path}").tar.gz"
    elif [ -f "$path" ]; then
        cp "$path" "/tmp/runner/$(basename "${path}")" 
        echo "/tmp/runner/$(basename "${path}")"
    else
        echo "$path does not exist, please provide the path that exist"
        exit 43
    fi
}

is_valid_ipv4() {
    local ip=$1
    local IFS=.
    local -a octets=($ip)
    if [ ${#octets[@]} -ne 4 ]; then
        return 1
    fi
    for octet in "${octets[@]}"; do
        if ! [[ $octet =~ ^[0-9]+$ ]] || [ $octet -lt 0 ] || [ $octet -gt 255 ]; then
            return 1
        fi
    done
    return 0
}

is_valid_port() {
    local port=$1
    if [[ $port =~ ^[0-9]+$ ]] && [ $port -ge 1 ] && [ $port -le 65535 ]; then
        return 0
    else
        return 1
    fi
}

receive() {
    scripts_src="${src}/scripts"
    echo "starting the receiving service"
    output="."
    ipaddress=""
    port=""
    global=""
   

    library="requests"
    importFunctions "update.sh" "install_python_library" "requests"

    while getopts ":o:i:p:g" opt; do
        case ${opt} in
            o ) output="$OPTARG" ;;
            i ) ipaddress="$OPTARG" ;;
            p ) port="$OPTARG" ;;
            g ) global="true" ;;
            \? ) recommd_command "--share receive ${@}";echo -e "Invalid option: -$OPTARG\nto know more type \033[1;32mrun --share help\033[0m" 1>&2
                exit 3 ;;
            : )  echo "Option -$OPTARG requires an argument." 1>&2
                exit 3 ;;
        esac
    done
    if [[ "${global}" == "true" ]];then
        read -p "Enter the password: " "password"
        while [[ -z "${password}" ]];do
            read -p "Password should not be empty :" "password"
        done
        sha="$(echo "${password}"| sha256sum | cut -d ' ' -f1 )-receive"
        mkdir -p "/tmp/runner/${sha}/" 2>/dev/null
        if ! command -v gsocket &> /dev/null;then
            importFunctions "install.sh" "install_packages" "gsocket"
        fi
        if ! grep -q "^Subsystem.*sftp" /etc/ssh/sshd_config; then
            importFunctions "install.sh" "install_packages" "openssh-server"
            echo -e "\033[0;33m***Waring if error persisted please make sure to run the sftp-server***\033[0m"
        fi
        gs-sftp -s ${password} <<< "mget file* /tmp/runner/${sha}/"
        if [[ $? != 0 ]];then
            echo -e "\e[31mpassword was wrong or try again\e[0m"
            exit 3
        fi
        filename="$(cat "/tmp/runner/${sha}/filename")" 
        mv "/tmp/runner/${sha}/file" "${filename}"
        if [[ $filename == *.tar.gz ]]; then
            folder_name="${filename%.*.*}"
            mkdir -p "${folder_name}" 2>/dev/null
            tar -xvzf "${filename}" -C "./${folder_name}" &>/dev/null
            rm "${filename}"
            echo -e "\e[32mrecived file sucessfully as ${folder_name}\e[0m"
        else 
            echo -e "\e[32mrecived file sucessfully as ${filename}\e[0m"
        fi
        exit
    fi

    if [ ! -d "$output" ] || [ ! -w "$output" ]; then
        echo "Error: $output is either not a directory or not writable." 1>&2
        exit 48
    fi

    if { [ -z "${ipaddress}" ] || [ -z "${port}" ]; } && { [ -n "${ipaddress}" ] || [ -n "${port}" ]; }; then
        echo "You need to either mention both the IP address and port or neither."
        exit 45
    fi

    if [ -n "${ipaddress}" ] && [ -n "${port}" ]; then
        if ! is_valid_ipv4 "${ipaddress}"; then
            echo "IP address is not a valid IPv4 address."
            exit 46
        fi
        if ! is_valid_port "${port}"; then
            echo "Port is not valid. It must be an integer between 1 and 65535."
            exit 47
        fi
        if ! command -v python3 &> /dev/null ; then
            importFunctions "install.sh" "install_packages" "python3"
        fi
        python3 "${scripts_src}/download.py" -o "${output}" -a "${ipaddress}:${port}"
        exit 
    fi
    
    cleanuprecive(){
        echo -e "\033[1;31mstoping the receiving service\033[0m"
        if grep -q "microsoft" /proc/version; then
            SERVER_BROADCASTING_PIDS=$(powershell.exe -Command "Get-Process -Name 'Runreceive' | Select-Object -ExpandProperty Id")
            if [[ -n "$SERVER_BROADCASTING_PIDS" ]]; then
                for PID in $SERVER_BROADCASTING_PIDS; do
                    powershell.exe -Command "Stop-Process -Id $PID" 2>/dev/null
                done
            fi
        fi
        echo -e "\033[1;32mstoped the receiving service, sucessfully\033[0m"
        exit
    }

    trap cleanuprecive SIGINT
    # dectecting wsl
    if grep -q "microsoft" /proc/version; then
        echo "Detected, Running on WSL"
        importFunctions "wsl/share.sh"
        start_the_mediator_in_windows
    fi

    echo "use up and down arrow to navigate
(press (ctrl+c) to exit) or select exit option"
    sleep 2
    python3 "${scripts_src}/receive.script.py" -o "${output}"  2>/dev/null
    
    #stopting the .exe file process that is running in windows background
    cleanuprecive
}

share() {
    if [ "$2" == "send" ]; then
        send "${@:3}"
    elif [ "$2" == "receive" ]; then
        receive "${@:3}"
    elif [ "$2" == "help" ]; then
        importFunctions "usage.sh" "share_usage";
    else
        recommd_command "${@}"
        echo -e "\033[0;31mIn share, only 'send' and 'receive' options are available. 
Please choose one of them.\n
to know more type \033[1;32mrun --share help\033[0m"
        exit 41
    fi
}