update_run(){
    # GitHub repository owner and name
    if ! command -v jq &> /dev/null; then
        echo "installing some dependencies"
        importFunctions "install.sh" "install_packages" "jq"
    fi
    curent_version=$(jq -r '.version' "${src}/details.json")

    url=""

    json=$(curl -s "$url")


    if [ $? -ne 0 ]; then
        echo "Failed to fetch JSON data from $url"
        exit 1
    fi

    latest_version=$(echo "$json" | jq -r '.version');

    if [[ ${latest_version} == ${curent_version} ]];then
        echo "you have the latest version"
        exit
    fi

    readarray -t array < <(echo "$json" | jq -r '.install-commands[]')
    if [ $? -ne 0 ]; then
        echo "Failed to parse JSON data"
        exit 1
    fi
    for element in "${array[@]}"; do
        "$element"
    done
}