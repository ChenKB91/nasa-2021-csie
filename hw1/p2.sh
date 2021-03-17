#!/bin/bash

comp=0
thres=0
files=()

cmd=`echo "$1"|head -c -2`
target=`echo "$2"|head -c -2`
thres=$3
url=`echo "$4"|head -c -2`
shift 4
files+=("$@")

if [[ -z $url ]]; then
url=`$cmd $target ${files[@]}`
    if [[ $? ]]; then
    echo "Error when running $cmd."
    exit 1
    fi
url="${res##$'\n'}"
fi
>&2 echo "$url"

# parsing the site
site=`curl $url`

site=`sed '0,/Lines Matched/d' site | sed '/^\/TABLE$/,$d'`
echo site