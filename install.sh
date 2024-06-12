#!/bin/bash

dir_file=$(dirname $(command -v bash))
dir_src=$(dirname ${dir_file});

file_dist="${dir_file}/run"
dir_dist="${dir_src}/local/src/run"

rm -rf "${dir_dist}"
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