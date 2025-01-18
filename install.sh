#!/bin/bash

dir_file=$(dirname $(command -v bash))
dir_src=$(dirname ${dir_file});

file_dist="${dir_file}/run"
dir_dist="${dir_src}/local/src/run"

if ! grep -q "microsoft" /proc/version; then
    echo "removing some unnecessary files..."
    rm -rf ./src/wsl
else
    read -p "do you want the run comamnd avaliable in windows also [y/n]: " option
    if [[ "${option}" == "y" ]];then
        dest="C:\Program Files\runner\bin"
        batfile="$(wslpath -w ./src/wsl/run.bat)"
        echo "This may ask for the permission for running as administration mode (press yes if asked)"
        sleep 2
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "& {Start-Process powershell -ArgumentList '-Command \"New-Item -ItemType Directory -Path \\\"${dest}\\\";copy \\\"${batfile}\\\" \\\"${dest}\\\";setx PATH \\\"%PATH%;C:\\Program Files\\runner\\bin\\\"; \"' -Verb RunAs}"
    fi
fi

rm -rf "${dir_dist}/src"
mkdir -p "${dir_dist}"
cp -rpf ./src "${dir_dist}"

rm -f "${file_dist}"
cp -f ./run "${file_dist}"

chmod +x "${file_dist}"

if [[ -f "${file_dist}" ]]; then
    if [[ -d "${dir_dist}" ]]; then
        sed -i "2s#^src=.*#src=\"${dir_dist}/src\"#" "${file_dist}"
        echo -e "\e[32minstalled sucessfully\e[0m\n"
        else
        echo -e "\e[31msomething went wrong try again...\e[0m";exit 10;
    fi
else 
    echo -e "\e[31msomething went wrong try again...\e[0m";exit 10; 
fi

echo -e "completed!!\nThank you for installing run"