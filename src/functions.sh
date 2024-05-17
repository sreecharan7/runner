latest_file_run() {
    check_array_length "1" "$@"
    latest_edited=$(ls -lt |  grep -v -E '\.out$|\.o$'| head -2 | tail -1 | awk '{print $NF}');
    if [ -z "$latest_edited" ]; then
        echo "no latest file found"
        exit 5;
    else
        main "${latest_edited}"
    fi
    exit
}


double_dash_functions(){
    case $1 in
    "--version" )
        if ! command -v jq &> /dev/null; then
            echo "installing some dependencies"
            importFunctions "install.sh" "install_packages" "jq"
        fi
        check_array_length "1" "$@"
        echo -e "version is $(jq -r '.version' "${src}/details.json")"
        exit
        ;;
     "--help")
        check_array_length "1" "$@"
        importFunctions "usage.sh" "usage";
        exit
        ;;
     "--update")
        check_array_length "1" "$@"
        importFunctions "update.sh" "update_run";
        exit
        ;;    
        *)
        echo "option is not present"
        exit 8
        ;;
    esac
}

check_array_length(){
    length=$1
    ((length++))
    if [[ $# != ${length} ]];then
        echo "given more arguments to the comand"
        exit
    fi
}