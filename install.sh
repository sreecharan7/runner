#!/bin/bash

rm -rf /usr/local/src/run/
mv -f ./src /usr/local/src/run

mv -f ./run /usr/bin

chmod +x /usr/bin/run

echo -e "installed sucessfully\n deleting source files"

cd .. 
rm -rf runner