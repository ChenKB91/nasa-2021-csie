#!/bin/bash

lines=()
target=$1
target=${target::-1}
comp=$2
IFS=$'\n'
while read -r line; do
    lines+=("$line")
done
edges=()
IFS=' '
for line in "${lines[@]}"
do
    IFS=' '
    read -r -a tmp <<< "$line"
    unset IFS
    file1="${tmp[0]}" # remember to change these two before feeding real things
    file2="${tmp[2]}"
    edges+=("$file1 $file2" "$file2 $file1")
    files+=("$file1" "$file2")
done

# sort the edges & files
IFS=$'\n'
files=($(echo "${files[*]}"|sort -u))
edges=(`sort -k1 -k2 <<<"${edges[*]}"`)
#echo -e "${edges[*]}"
if [[ $comp == 0 ]]; then
    if [[ -n $target ]]; then
        printf "$target"
    fi
    echo "${files[@]}"
    exit 0
fi
declare -A left right
len=${#edges[@]}
echo "${edges[*]}"
for ((i = 0; i < ${#edges[@]}; i=$j)); do
    j=$((i+1))
    # cur = edges[i][0]
    IFS=' '; read -r -a tmp <<< "${edges[$i]}"
    cur="${tmp[0]}" 
    unset IFS
    while [[ $j -lt $len ]] && [[ `awk '{print $1}' <<< "${edges[$j]}"` == $cur ]]
    do
        ((j++))
    done
    echo "cur=$cur i=$i j=$j"
    left[$cur]=$i
    right[$cur]=$j
done
tmp="test3"
IFS=$'\n'
for ((i=0;i<$len;i++)); do
    edges[$i]=`awk '{print $2}' <<< "${edges[$i]}"`
done
# output the shit to stderr
for f in ${files[@]}
do
    l=${left[$f]}; r=${right[$f]}
    printf "$f: " >&2
    for((i=$l;i<$r;i++))
    do
        printf " ${edges[$i]}" >&2
    done
    echo >&2
done

# part 2
declare -A visit
size=()
cmpn=()
dfs(){
    cur=$1; id=$2
    cmpn[$id]+="$cur "
    visit[$cur]=$id
    local l=${left[$cur]} r=${right[$cur]}
    sz=1
    for ((i=$l;i<$r;i++))
    do
        nxt=${edges[$i]}
         if [[ -z ${visit[$nxt]} ]]; then
             dfs $nxt $id
             sz+=$(($sz+$?))
         fi
    done
    return $sz
}
id=0
for f in ${files[@]}
do
    if [[ -z ${visit[@]} ]]
    then
        cmpn+=(' ')
        dfs $f $id
        size+=($?)
        echo "$?"
        ((id+=1))
    fi
done
for((i=0;i<$id;i++)); do
    echo "${size[$i]}: ${cmpn[$i]}"
done
