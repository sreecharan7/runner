#!/bin/bash

rm -rf /usr/local/src/run/
mkdir -p /usr/local/src/run
cp -rpf ./src /usr/local/src/run

rm -f /usr/bin/run
cp -f ./run /usr/bin

chmod +x /usr/bin/run

if [[ -f "/usr/bin/run" ]]; then
    if [[ -d "/usr/local/src/run/src" ]]; then
        echo -e "\e[32minstalled sucessfully\e[0m\n"
        else
        echo -e "\e[31msomething went wrong try again...\e[0m";exit 10;
    fi
else 
    echo -e "\e[31msomething went wrong try again...\e[0m";exit 10; 
fi

echo -e "completed!!\nThank you for installing run"