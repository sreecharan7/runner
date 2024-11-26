windows_src="C:\Program Files\runner"

start_the_broadcast_in_windows(){
    echo "Optimising for WSL..."
    data=$(powershell.exe -Command 'Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" } | Select-Object IPAddress, PrefixLength' | awk 'NR>3 {print $1, $2}')
    ip_data=""
    port="$1"
    name="$2"
 
    if ! command -v ipcalc &> /dev/null ; then
        echo -e "installing some dependencies..."
        importFunctions "install.sh" "install_packages" "ipcalc"
    fi

    while IFS= read -r line; do
        ip=$(echo "$line" | cut -d ' ' -f1| tr -d '\n\r' | tr -d ' ')
        subnet=$(echo "$line" | cut -d ' ' -f2 | tr -d '\n\r' | tr -d ' ')
        if [[ $subnet =~ ^[0-9]+$ ]]; then
            broadcast=$(convert_ip_subnet_broadcast "$ip" "$subnet")
            ip_data+="$ip $broadcast"$'\n'
        fi
    done <<< "$data"

    
    script_src="${windows_src}\\Runbroadcast.exe"
    ctfpon
    #running the broadcsting script in windows in powershell mode and capaturing pid
    perssmision_redirecting_traffic_to_wsl $port
    #runnig the broadcast.exe which is exe file broacast.py
    powershell.exe  -Command "Start-Process  -WindowStyle Hidden '${script_src}' -ArgumentList  '\"${ip_data}\"', '\"${port}\"', '\"${name}\"'  -PassThru | Select-Object -ExpandProperty Id" 1>/dev/null
}

convert_ip_subnet_broadcast(){
    ip="$1"
    sub="$2"
    broadcast=$(ipcalc -b $ip/$sub | grep Broadcast | awk '{print $2}')
    echo "$broadcast"
}

perssmision_redirecting_traffic_to_wsl(){
    listenPort=$1
    connectPort=$1
    listenAddress="0.0.0.0"
    currentWSLIP=$(ip addr | grep eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)

    existingRule=$(powershell.exe -Command "netsh interface portproxy show v4tov4 | Select-String -Pattern $listenPort")

    if [[ $existingRule == *"$listenAddress"* && $existingRule == *"$listenPort"* && $existingRule == *"$currentWSLIP"* && $existingRule == *"$connectPort"* ]]; then
        echo "Port forwarding rule for port $listenPort with IP $currentWSLIP already exists."
    else
        echo "Adding port forwarding rule for port $listenPort..."
        echo "This may ask for the permission for running as administration mode (press yes if asked)"
        sleep 2
        powershell.exe -Command "& {Start-Process powershell -ArgumentList '-Command \"netsh interface portproxy add v4tov4 listenport=$listenPort listenaddress=$listenAddress connectport=$connectPort connectaddress=$currentWSLIP; netsh advfirewall firewall add rule name=\\\"WSL Port $listenPort\\\" dir=in action=allow protocol=TCP localport=$listenPort\"' -Verb RunAs}"
        echo "Port forwarding rule added."
    fi
}

start_the_mediator_in_windows(){
    echo "Optimising for WSL..."
    script_src="${windows_src}/Runreceive.exe"
    router_id=$(ip route | grep default | awk '{print $3}')
    broadcast_address=$(ip addr show eth0 | grep 'inet ' | awk '{print $4}' | cut -d'/' -f1)
    ctfpon
    #runnig the broadcast.exe which is exe file mediator.py
    powershell.exe  -Command "Start-Process  -WindowStyle Hidden  '${script_src}' -ArgumentList  '\"${broadcast_address}\"', '\"${router_id}\"'  -PassThru | Select-Object -ExpandProperty Id" 1>/dev/null
}

ctfpon(){ #check the files present or not if so copy
    local wsl_windows_path=$(wslpath "${windows_src}")
    if [[ ! -f "${wsl_windows_path}/Runbroadcast.exe" || ! -f "${wsl_windows_path}/Runreceive.exe" ]];then
        echo "This may ask for the permission for running as administration mode (press yes if asked)"
        echo "for coping nesscarry files to windows to run properly"
        sleep 2
        copy_the_winodws_exe
    fi
}

copy_the_winodws_exe(){
    local dest="${windows_src}"
    local runbroadcastsouce="$(wslpath -w ${src}/wsl/Runbroadcast.exe)"
    local runrecivesouce="$(wslpath -w ${src}/wsl/Runreceive.exe)"
    powershell.exe -Command "& {Start-Process powershell -ArgumentList '-Command \"New-Item -ItemType Directory -Path \\\"${dest}\\\";copy \\\"${runbroadcastsouce}\\\" \\\"${dest}\\\";copy \\\"${runrecivesouce}\\\" \\\"${dest}\\\";\"' -Verb RunAs}"
}