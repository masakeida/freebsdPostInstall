#!/bin/sh

usage() {
    cat <<EOF
Usage:
    $(basename ${0}) ports_list_file
EOF
}

version() {
    echo "$(basename ${0}) version 0.0.1"
}

if [ $# -ne 1 ]; then
    version
    usage
    exit 1
fi

filename=$1

if [ ! -e ${filename} ]; then
    echo "${filename} does not exist. Stopped."
    exit 1
fi

#export ASSUME_ALWAYS_YES=yes

cat ${filename} | grep -v "^#" | grep -v "^$" | while read line
do
    if [ ! -d /usr/ports/${line} ]; then
	echo "/usr/ports/${line}: Not found."
    fi
done
