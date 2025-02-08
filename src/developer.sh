
mode(){
    if [[ "$1" != "true" && "$1" != "false" ]];then
        recommd_command "--developer mode ${@}"
        echo "please read the documentation of developer mode ";
        echo "type :- run --developer help"
    fi
    if [[ "$1" == "${developerMode}" ]];then
        echo "changed sucessfully";exit;
    fi
    if [[ "$1" == "true" ]];then
        importFunctions "usage.sh" "developer_agreement"
        read -p "I am agreeing to the terms (y/n): " option
        if [[ ! "$option" =~ ^y ]]; then
            echo "You must agree to the terms to continue."
            exit 1
        fi
    fi
    change=$(change_mode $1)
    if [[ -n "${change}" ]];then
        echo "${change}"
        exit 2
    fi
    echo "changed sucessfully";
}

change_mode(){
    if ! command -v jq &> /dev/null; then
        echo "installing some dependencies"
        importFunctions "install.sh" "install_packages" "jq"
    fi
    sudo jq ".developerMode = \"$1\"" "${src}/details.json" > /tmp/temp.json && sudo mv /tmp/temp.json "${src}/details.json"
    if [ ! $? -eq 0 ]; then
        echo "something went wrong while changing"
    fi
}

developer(){
    if ! command -v jq &> /dev/null; then
        echo "installing some dependencies"
        importFunctions "install.sh" "install_packages" "jq"
    fi
    developerMode=$(jq -r ".developerMode" "${src}/details.json")

    if [[ "$1" == "mode" ]];then
        mode "$2"
    elif [[ "$1" == "help" ]];then 
        importFunctions "usage.sh" "developer_help"
    else 
        recommd_command "--developer ${@}"
        echo "please read the documentation of developer mode ";
        echo "type :- run --developer help"
    fi
}
