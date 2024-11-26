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
        importFunctions "usage.sh" "usage";
        exit
        ;;
     "--update")
        check_array_length "1" "$@"
        importFunctions "update.sh" "update_run";
        exit
        ;;
     "--uninstall")
        check_array_length "1" "$@"
        uninstall_run
        exit
        ;;
    "--reinstall")
        check_array_length "1" "$@"
        importFunctions "update.sh" "reinstall_run";
        exit
        ;;
     "--cleanup")
        cleanup "$@"
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
     "--listb")
        check_array_length "1" "$@"
        list_bundle
        exit
        ;;
     "--deleteb")
        check_array_length "1" "$@"
        delete_buddle
        exit
        ;;    
     "--share")
        importFunctions "share.sh" "share" "$@";
        exit
        ;;
     "--installdepend")
        check_array_length "1" "$@"
        importFunctions "update.sh" "install_dependencies";
        exit
        ;;
        *)
        recommd_command "${@}"
        echo "option is not present as sencondary ($1) refer run --help"
        exit 8
        ;;
    esac
}

check_array_length(){
    length=$1
    ((length++))
    if [[ $# != ${length} ]];then
        echo "given more arguments to the comand for the option"
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

cleanup(){
    shift 1
    shift 1
    local arguments=$@
    if [ "$#" == 0 ] ;then
        arguments='-maxdepth 1'
    fi
    find . $arguments -type f \( -name "*.exe" -o -name "*.out" -o -name "*.o" \) -delete;
}

uninstall_run(){
    file_dist=$(command -v run);
    dir_dist="$(dirname "$(dirname "${file_dist}")")/local/src/run";

    sudo rm -rf "${file_dist}" "${dir_dist}"

    if [[ ! -f "${file_dist}" ]]; then
        if [[ ! -d "${dir_dist}" ]]; then
            echo -e "\e[32muninstalled sucessfully\e[0m\n"
            else
            echo -e "\e[31monly half unistalled\e[0m";exit 10;
        fi
    else 
        echo -e "\e[31msomething went wrong try again...\e[0m";exit 10; 
    fi
}

run_buddle(){
    buudle_src="$(dirname ${src})/bunddle";
    bundle_name=$2;
    shift 2
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

delete_buddle(){
    buudle_src="$(dirname ${src})/bunddle";

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

    sudo rm -f "${buudle_src}/${bundle_name}.bunddle.sh";

    if [[ -f "${buudle_src}/${bundle_name}.bunddle.sh" ]];then
        echo "bundle is not deleted, please try again";
        exit 11
    fi
    
    echo "delted bunddle sucessfully"
}

list_bundle(){
    echo "These are the bunddles present:-";
    buudle_src="$(dirname ${src})/bunddle";
    ls "${buudle_src}" 2>/dev/null | awk -F '.bunddle.sh' '{print $1}'
}

recommd_command(){
    python3  "${src}/scripts/recommond.py" "${src}/commands.txt" "run $*" 2>/dev/null
}