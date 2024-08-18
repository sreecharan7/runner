#!/bin/bash

src="./src"

importFunctions(){
    local filename="$1";
    if [[ ! -f "${src}/${filename}" ]];then
        echo "something went wrong, please try again";
        exit 9;
    fi
    source "${src}/${filename}"
    func=$2
    if [[ -n "${func}" ]];then
        shift 2;
        "${func}" "$@";
    fi
}

if ! command -v python3 &> /dev/null ; then
    importFunctions "install.sh" "install_packages" "python3"
fi


if ! command -v python3 &> /dev/null ; then
    importFunctions "install.sh" "install_packages" "shc"
fi

libraries=("pyinstaller" "requests") 

install_library() {
    pip3 install $1 1>/dev/null 2>&1
}

for library in "${libraries[@]}"; do
    install_library $library
done

if [[ -d dist ]];then
    read -p "dist folder exists do you want to recreate. 
All the data will be loss in that folder[y/n]:" confirm
    if [[ $confirm == "n" ]];then
        exit 2
    fi
fi
rm -rf dist
sudo mkdir dist

shc -f run -o ./dist/run -r
shc -f install.sh -o ./dist/install -r
rm "run.x.c"
rm "install.sh.x.c"
