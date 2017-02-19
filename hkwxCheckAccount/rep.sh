#!/bin/bash
#
#
InputDir=/var/root/uuids
OutputDir=/var/mobile/alsdata
for file_a in ${InputDir}/*; do  
    temp_file=`basename $file_a`  
    cat "${InputDir}/${temp_file}" > "${OutputDir}/${temp_file}/myuuid.dat"
done