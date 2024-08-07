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
        ip=$(echo "$line" | cut -d ' ' -f1| tr -d '\n' | tr -d ' '| tr -d '\r')
        subnet=$(echo "$line" | cut -d ' ' -f2 | tr -d '\n' | tr -d ' '| tr -d '\r')
        if [[ $subnet =~ ^[0-9]+$ ]]; then
            broadcast=$(convert_ip_subnet_broadcast "$ip" "$subnet")
            ip_data+="$ip $broadcast"$'\n'
        fi
    done <<< "$data"

    #script path from perspective of windows
    scripts_src=$(wslpath -w "${src}/scripts/broadcast.script.py")
    #running the broadcsting script in windows in powershell mode and capaturing pid
    SERVER_BROADCASATING_PID=$(powershell.exe  -Command "Start-Process -FilePath 'python3.exe' -ArgumentList '\"${scripts_src}\"', '\"${ip_data}\"', '\"${port}\"', '\"${name}\"'  -PassThru | Select-Object -ExpandProperty Id"| cut -d ' ' -f1| tr -d '\n' | tr -d ' '| tr -d '\r')
    #maing the kill command for the above command
    SERVER_BROADCASATING_kill="powershell.exe  -Command \"Stop-Process -Id ${SERVER_BROADCASATING_PID} -Force\""
}

convert_ip_subnet_broadcast(){
    ip="$1"
    sub="$2"
    broadcast=$(ipcalc -b $ip/$sub | grep Broadcast | awk '{print $2}')
    echo "$broadcast"
}

