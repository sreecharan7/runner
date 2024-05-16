#!/bin/bash

cp -r ./src /usr/local/src/run

cp ./run /usr/bin

chmod +x /usr/bin/run

echo "installed sucessfully\n deleting source files"

rm -fr ./src
rm  -f run
rm -f install.sh