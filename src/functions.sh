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
     "--addb")
        check_array_length "1" "$@"
        bundle_comands
        exit
        ;;
    "--editb")
        check_array_length "1" "$@"
        edit_buddle
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


bundle_comands(){
    buudle_src="$(dirname ${src})/bunddle";
    sudo mkdir -p ${buudle_src}

    bundle_name="";

    while true; do
        read -p "enter the bunddle name:" bundle_name ;

        if [[ ! -z ${bundle_name} ]]; then
            if [[ ! -f "${buudle_src}/${bundle_name}.bunddle.sh" ]];then
                break;
            else
                echo "  with this name already a bunddle is there, try again" 
            fi
        else
            echo "  entered nothing, try again"
        fi
    done

    if ! command -v nano &> /dev/null; then
        echo "installing some dependencies"
        importFunctions "install.sh" "install_packages" "nano"
    fi

    importFunctions "usage.sh" "addb_create_file_usage";

    read -p "press enter to continue"

    sudo nano "${buudle_src}/${bundle_name}.bunddle.sh";

    if [[ ! -f "${buudle_src}/${bundle_name}.bunddle.sh" ]];then
        echo "something went wrong, please try again";
        exit 11
    fi
    
    echo "created bunddle sucessfully"
}

run_buddle(){
    check_array_length "2" "$@"
    buudle_src="$(dirname ${src})/bunddle";
    bundle_name=$2;
    if [[ ! -f "${buudle_src}/${bundle_name}.bunddle.sh" ]];then
        echo "with this name no bunddle found"
        exit 11
    fi
    
    source "${buudle_src}/${bundle_name}.bunddle.sh" 
}

edit_buddle(){
    buudle_src="$(dirname ${src})/bunddle";
    sudo mkdir -p ${buudle_src}

    bundle_name="";

    while true; do
        read -p "enter the bunddle name:" bundle_name ;

        if [[ ! -z ${bundle_name} ]]; then
            if [[ -f "${buudle_src}/${bundle_name}.bunddle.sh" ]];then
                break;
            else
                echo "  with this name no bunddle is there, try again" 
            fi
        else
            echo "  entered nothing, try again"
        fi
    done

    if ! command -v nano &> /dev/null; then
        echo "installing some dependencies"
        importFunctions "install.sh" "install_packages" "nano"
    fi

    importFunctions "usage.sh" "addb_create_file_usage";

    read -p "press enter to continue"

    sudo nano "${buudle_src}/${bundle_name}.bunddle.sh";

    if [[ ! -f "${buudle_src}/${bundle_name}.bunddle.sh" ]];then
        echo "bundle got deleted, please try created bunddle again";
        exit 11
    fi
    
    echo "edited bunddle sucessfully"
}