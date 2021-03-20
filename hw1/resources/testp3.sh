#!/bin/bash
target=$1
target=${target::-1}
comp=$2
edges=()
files=()
while read -r u _ v _ && [[ -n $u ]]; do
    [[ -n $target ]] && target=$u || files+=($u)
    files+=($v)
    if [[ $comp == 1 ]] && [[ -z $target ]]; then
        edges+=("$u $v" "$v $u")
    fi 
done 
    IFS=$'\n'; 
    files=($(echo "${files[*]}" | sort -u)) 
    # sort | uniq 
    if [[ $comp == 0 ]] || [[ -n $target ]]; then
        [[ -n $target ]] && printf "%s " $target
        echo "${files[@]}"
        exit 0 
    fi 
    edges=($(echo "${edges[*]}" | sort -k 2)) 
    edges=($(echo "${edges[*]}" | sort -k 1)) 
    unset IFS 
    declare -A left right 
    # [left,right) 
    m=${#edges[@]} 
    for((i=0;i<$m;i=$j)); do
        cur=$(cut -d ' ' -f 1 <<< ${edges[$i]})
        edges[$i]=$(cut -d ' ' -f 2 <<< ${edges[$i]})
        ((j=i+1))
        while [[ $j -lt $m ]] && [[ $cur == $(cut -d ' ' -f 1 <<< ${edges[$j]}) ]];
        do
            edges[$j]=$(cut -d ' ' -f 2 <<< ${edges[$j]})
            ((j++))
        done
        left[$cur]=$i
        right[$cur]=$j
    done
    for f in ${files[@]}; do
        printf "%s:" $f >&2
        l=${left[$f]}; r=${right[$f]};
        for((i=$l;i<$r;i++)); do
            printf " %s" ${edges[$i]} >&2
        done
        echo >&2
    done

dfs(){
    declare cur=$1 id=$2 sz=1 i nxt
    local l=${left[$cur]} r=${right[$cur]}
    vis[$cur]=$id; ans[$id]+="$cur "
    for((i=$l;i<$r;i++)); do
        nxt=${edges[$i]}
        if [[ -z ${vis[$nxt]} ]]; then
            dfs $nxt $id
            sz=$(($sz+$?))
        fi
    done
    return $sz
}
declare -A vis id=0 ans=() sz=()
for f in ${files[@]}; do
    if [[ -z ${vis[$f]} ]];
    then
        ans+=(' ')
        dfs $f $id
        sz+=($?)
        id=$(($id+1))
    fi 
done 
for((i=0;i<$id;i++)); do
    printf "%d: " ${sz[$i]}
    printf "%s" "${ans[$i]// /$'\n'}" | sort | tr '\n' ' ' | sed 's/ $/\n/' 
done
