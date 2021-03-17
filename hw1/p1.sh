#!/bin/bash

comp=0
thres=0
files=()
# fileflag=0

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    echo -e "Usage: $0 [options]... files...\n\nOptions and arguments:\n  -e, --exec executable\t  Required argument unless --url is given. The\n\t\t\texecutable command used to run the moss upload\n\t\t\tprocess.\n  -f, --file file\t  If this argument is provided, only find out the\n\t\t\tsimilarity between the target file and all the\n\t\t\tother files, rather than find out the similarity\n\t\t\tamong each pair of the files.\n  -c, --component\t  If this argument is provided, the final output\n\t\t\tshould be each plagiarism connected component,\n\t\t\tinstead of simply list the plagiarism files.\n  -t, --threshold value\t  The threshold value to determine whether a result\n\t\t\tfrom moss is truly plagiarism or not.\n\t\t\tThe value should be within 0 to 100.\n  -u, --url url\t\t  If this argument is provided, the program will\n\t\t\ttest the plagiarism according to the result of\n\t\t\tthis url, and the --exec arguments will be ignored.\n\t\t\tIf the given files do not match the result of\n\t\t\tthe given url, the behavior is undefined.\n  -h, --help\t\t  Display this help and exit.\n"
    exit 1
    ;;
    -e|--exec)
    cmd="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--file)
    target="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--component)
    comp=1
    shift # past argument
    ;;
    -t|--threshold)
    thres="$2"
    shift
    shift
    ;;
    -u|--url)
    url="$2"
    shift
    shift
    ;;
    
    *)
    if [[ $1 =~ ^\/?((\.|\.\.|([a-zA-Z0-9_]+(\.[a-z]+)?))\/)*([a-zA-Z0-9_]+(\.[a-z]+)?)$ ]]
    then
        files+=("$@") # save it in an array for later
        break
    else
        echo "Invalid argument $1. Try -h or –help for more help."
        exit 1
    fi
    ;;
esac
done

if [[ -z "$cmd" ]] && [[ -z "$url" ]]
then
echo -e "Require -e argument to provide an executable command,or -u argument to provide a result url.\nTry -h or –help for more help.\n"
exit 1
fi
if ! [[ -z "$target" ]]
then
    if ! [[ -f "$target" ]]; then
    echo -e "Target file $target does not exist or is not a readable regular file."
    exit 1;
    fi
fi
if ! [[ $thres =~ [0-9]+ ]] ; then
echo -e "Threshold value should be an integer within 0 to 100."
exit 1
fi
if [[ 1 -gt $thres ]] || [[ $thres -gt 100 ]] ; then
echo -e "Threshold value should be an integer within 0 to 100."
exit 1
fi
if [[ ${#files[@]} == 0 ]]; then
echo -e "Require at least one file to be tested similar-ity.\nTry -h or –help for more help.\n"
exit 1
fi

for meow in "${files[@]}"
do
    if ! [[ -f "$meow" ]]; then
    echo "File $meow does not exist or is not a readable regular file."
    exit 1
    fi
done


echo "cmd=$cmd"
echo "target=$target"
echo "comp=$comp"
echo "thres=$thres"
echo "url=$url"
echo "files=(${files[@]})"
