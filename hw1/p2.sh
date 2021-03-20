#!/bin/bash
#trap read debug
comp=0
thres=0
files=()

cmd=`echo "$1"|head -c -2`
target=`echo "$2"|head -c -2`
if ! [[ -z "$target" ]]; then
    target=`realpath $target`
fi
thres=$3
url=`echo "$4"|head -c -2`
shift 4
# make the files absolute path
for f in "$@"
do
    s=`realpath $f`
    files+=("$s")
done

# if url not provided, get url from cmd
if [[ -z $url ]]; then
    url=`$cmd $target ${files[@]}`

    if [[ $? -ne 0 ]]; then
        echo "Error when running $cmd."
        exit 1
    fi
    url=`echo "$url"|tail -n 1`
fi

# check if all files have same directory
if [[ -z "$target" ]]; then
    dn=`dirname $(realpath ${files[0]})`
else
    dn=`dirname $(realpath $target)`
fi
   
#echo "$dn"
all_same_dir=1

for f in "${files[@]}"
do
    dn1=`realpath $f | xargs dirname`
    if ! [[ "$dn1" == "$dn" ]]; then
        all_same_dir=0
        break
    fi
    dn="$dn1"
done
>&2 echo "$url"

# parsing the site
#echo "|curl -L $url|"
site=`curl -s -L $url`
# delete extra lines
site=`echo -e "$site" | sed '0,/Lines Matched/d; /TABLE/,$d'`
# remove html tags
site=`echo -e "$site" | sed 's/<A HREF.*html">//g; s/<TR>//g; s/<TD>//g; s/<\/A>//g; s/<TD.*right>//g;'`
# remove directory and spaces, put them in order
site=`echo -e "$site" | sed 's/ //g; s/(/\n/g; s/)//g;'`
#echo "------------------------------------"
#echo -e "$site"
# parse this shitty thing line by line
line_n=0
res_arr=()
while read -r line
do
#echo "$line_n"
case $line_n in
0) file1="$line"
#echo "$file1"
;;
1) ratio1="${line::-1}"
#echo "$ratio1"
;;
2) file2="$line"
#echo "$file2"
;;
3) ratio2="${line::-1}"
#echo "$ratio2"
;;
4) lns="$line"
#echo "$lns"
score=`awk "BEGIN{print int(0.35*($ratio1+$ratio2)+0.15*$lns);}"`
if [[ $score -gt 100 ]]; then
    score=100
fi
#echo "$score"
if [[ $all_same_dir == 1 ]]; then
    file1="${file1##*/}"
    file2="${file2##*/}"
    target="${target##*/}"
fi
file1="${file1%.*}"
file2="${file2%.*}"
target="${target%.*}"

if [[ $score -ge $thres ]]; then
    if [[ -z $target ]]; then
        if [[ $ratio1 > $ratio2 ]]; then
            res_arr+=("$file1 $ratio1 $file2 $ratio2 $lns $score")
        elif [[ $ratio1 < $ratio2 ]]; then
            res_arr+=("$file2 $ratio2 $file1 $ratio1 $lns $score")
        else
            if [[ $file2 < $file1 ]]; then
                res_arr+=("$file2 $ratio2 $file1 $ratio1 $lns $score")
            fi
        fi
	else
        #echo "$target,  $file1,  $file2"
		if [[ $target == $file1 ]]; then
            res_arr+=("$file1 $ratio1 $file2 $ratio2 $lns $score");
        elif [[ $target == $file2 ]]; then
            res_arr+=("$file2 $ratio2 $file1 $ratio1 $lns $score");
        fi
    fi
fi
line_n=-1
;;
esac

((line_n+=1))
done < <(echo "$site")

#echo "${#res_arr[@]}"

if [[ ${#res_arr[@]} == 0 ]]
then
    >&2 echo "No plagiarism found."
    exit 255;
fi

IFS=$'\n';
echo "${res_arr[*]}" | sort -k6nr -k2nr -k4nr -k5nr -k1 -k3;
exit 0;

