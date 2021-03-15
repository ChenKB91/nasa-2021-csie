#!/bin/bash
# validator function definition
validator(){
    # extract its argument
    input="$1"
    #echo "$input";
    # if the number of lines isn't 3, return 1 (invalid)
    [[ $(printf "$input" | wc -l) -ne 3 ]] && return 1
    # store each line into an array and determine if the number of element in the array is 3
    # TODO: 1. store the $input, separated by linefeed, into an array $lines
    #       2. if the number of element in the array is not 3, return 1 (invalid)
    IFS=$'\n'; read -rd '' -a lines <<< "$input";

    if [[ ${#lines[@]} != 3 ]]; then
        #echo "line != 3, line=${#lines[@]}";
	return 1;
    fi
    # ENDTODO
    # check the first line: a valid student id (without any leading or trailing space)
    # TODO: determine whether the first element of $lines matches a valid student id, if not, return 1
    if [[ ! "${lines[0]}" =~ ^[^[:space:]]+([:space:][^[:space:]]+)*$ ]]; then
	#echo "invalid id (space)"
	return 1;
    fi
    if [[ ! "${lines[0]}" =~ ^([BRD]0[1-9][1-9AB][0-9]{5}|[brd]0[1-9][1-9ab][0-9]{5})$ ]]
    then
	#echo "invalid id (format)"
	return 1;
    fi
    # ENDTODO
    # check the second line: an integer N in range 1 to 100 (without any leading or trailing space)
    # TODO: determine whether the second element of $lines is a valid integer, if not, return 1
    re='^[0-9]+$';
    if [[ ! "${lines[1]}" =~ $re ]]; then
	#echo "${lines[1]} not valid int";
        return 1;
    fi
    if [[ 1 -gt ${lines[1]} ]] || [[ ${lines[1]} -gt 100 ]]; then
        #echo "${lines[1]} not in range";
	return 1;
    fi
    # ENDTODO
    N="${lines[1]}"
    echo "$N"
    # check the third line: N space-separated valid floating number (without any leading or trailing space)
    # TODO: 1. fill the $float_regex with a regex that matches a single valid floating number
    #       2. let $tot_regex = "^$float_regex" + " $float_regex"*(N-1) + '$'
    #       3. determine whether the third element of $lines matches the regex $tot_regex, if not, return 1
    res=`printf "$N\n${lines[2]}" | ./testmatch.py`
    if ! [[ "$res" == "0" ]]
    then
	    echo "init filter"
	    return 1
    fi

    float_regex='[+-]?([0-9]+(\.[0-9]{0,6})?|\.[0-9]{1,6})'
    tot_regex="^$float_regex"
    for((x=0;x<$N-1;x++))
    do
        tot_regex="$tot_regex $float_regex";
    done
    tot_regex="$tot_regex$";
    #echo "$tot_regex";
    if [[ ! "${lines[2]}" =~ $tot_regex ]]
    then
	echo "float regex not match";
        return 1;
    fi
    # ENDTODO
    # pass all the check, return 0 (valid)
    
    echo "all clear"
    for x in ${lines[@]}
    do
	echo "|$x|" >> ./log.txt
	echo "|$x|"
    done
    return 0
}
# If the arguments are not enough, print the usage
if [[ $# -lt 7 ]]; then
    echo "Usage: $0 <num> <gen> <sol> <ans> <tle> <mle> <ole>"
    exit 0
fi
# Extract the arguments
num=$1; gen=$2; sol=$3; ans=$4; tle=$5; mle=$6; ole=$7
# convert the unit of mle to KB, the unit of ole to byte
# TODO: 1. let mle*=1024 and ole*=1024
#       2. create a temporary directory at the current directory and store its path to $tmpdir (hint: `man mktemp`)
((mle*=1024))
((ole*=1024))
tmpdir=`mktemp -d -p .`
# ENDTODO
# set trap on exit: auto remove the temporary directory when exit
trap '{ rm -rf "$tmpdir"; }' EXIT
# initialize variables
verdict_arr=(); time_arr=(); mem_arr=()
res_verdict=Accepted; max_time=0; max_mem=0
# Run the tests $num times
for((id=0;id<$num;id++))
do
    echo "running testcase$id..." >&2
    # run the generator and store its output (the testdata input) at $tmpdir/input
    "$gen" "$id" "$8" > "$tmpdir/input" 2> /dev/null
    # read the testdata content (prevent from command substitution removing trailing newline)
    IFS= read -rd '' input < <(cat "$tmpdir/input")
    #echo "$input"
    # run the validator function to validate the testdata
    if ! validator "$input"; then
        verdict_arr+=(JE); time_arr+=(0); mem_arr+=(0)
        #echo 'boom';
	continue
    fi
    # run the answer executable to get the correct answer
    "$ans" < "$tmpdir/input" > "$tmpdir/ans.out" 2> "$tmpdir/ans.err"
    ans_stat=$?
    # run the solution exectuable with timeout and memory limit, also truncate the output to specific length
    (ulimit -s unlimited; ulimit -v $((mle*2+65536)); /usr/bin/time -v timeout $((tle*2)) "$sol" "$id" "$8" < "$tmpdir/input" 2> "$tmpdir/sol.err" | head -c $(($ole+1)) > "$tmpdir/sol.out"; exit ${PIPESTATUS[0]})
    sol_stat=$?
    # parse the output of /usr/bin/time from its standard output
    # TODO: 1. let $time_res be the /usr/bin/time part from $tmpdir/sol.err file
    #       2. modify $tmpdir/sol.err file to store only the stderr of the solution program (remove /usr/bin/time part)
    #       3. extract $user_time and $sys_time from $time_res and remove their decimal separator (i.e. multiply 100)
    #       4. extract $mem_use from $time_res (the 'Maximum resident set size' section)
    #       5. calculate $tot_time to be the sum of $user_time and $sys_time (hint: specify decimal base)
    time_res=$(cat "$tmpdir/sol.err"|grep ':');
    tmp=$(cat "$tmpdir/sol.err"|grep -v ":")
    echo "$tmp" > $tmpdir/sol.err
    user_time=`echo "$time_res"|grep 'User time'|sed -e 's/.*: //g'`;
    user_time=`perl -E "say $user_time*100"`
    sys_time=`echo "$time_res"|grep 'System time'|sed -e 's/.*: //g'`;
    sys_time=`perl -E "say $sys_time*100"`
    mem_use=`echo "$time_res"|grep 'Maximum resident'|sed -e 's/.*: //g'`;
    tot_time=$((user_time+sys_time));
    #echo "usr:$user_time,sys:$sys_time,mem:$mem_use,tot:$tot_time";
    # END TODO
    # get the output length
    out_size=$(cat "$tmpdir/sol.out" | wc -c)
    # determine the verdict according to the result
    if ((tot_time>tle*100)); then
       verdict=TLE
    elif ((mem_use>mle)); then
        verdict=MLE
    elif [[ $out_size -gt $ole ]]; then
        verdict=OLE
    elif [[ $ans_stat -ne $sol_stat ]]; then
        verdict=RE
    elif ! diff "$tmpdir/ans.out" "$tmpdir/sol.out" &> /dev/null; then
        verdict=WA
	#echo "out"
	#echo "ans"
	#cat "$tmpdir/ans.out";echo "sol"; cat "$tmpdir/sol.out"
    elif ! diff "$tmpdir/ans.err" "$tmpdir/sol.err" &> /dev/null; then
        verdict=WA
	#echo "err"
	#echo "ans"
	#cat "$tmpdir/ans.err";echo "sol"; cat "$tmpdir/sol.err"
    else
        verdict=AC
    fi
    # store the results in the arrays and update the final result
    # TODO: 1. append $verdict to $verdict_arr, $tot_time to $time_arr, and $mem_use to $mem_arr
    #       2. if $verdict is not AC, set $res_verdict to 'Rejected'
    #       3. set $max_time=max($max_time,$tot_time), $max_mem=max($max_mem,$mem_use)
    verdict_arr+=($verdict);time_arr+=($tot_time);mem_arr+=($mem_use);
    if [[ $verdict != AC ]]; then
	    res_verdict='Rejected';
    fi
    max_time=$((max_time>tot_time ? max_time : tot_time));
    max_mem=$((max_mem>mem_use ? max_mem : mem_use));
    echo "$verdict"
    # ENDTODO
done
# print the final result and the seperator line
printf 'res: %s %2.2fs %3.3fMB\n' "$res_verdict" $(echo "$max_time"/100 | bc -l) $(bc -l <<< "$max_mem"/1024)
head -c 32 /dev/zero | tr '\0' '-'
echo
# print detailed result of each subtask
for((id=0;id<num;id++)); do
    # TODO: print the $id element of $verdict_arr, $time_arr, and $mem_arr according to the output format
    tmp=`perl -E "say ${time_arr[$id]}/100."`
    tmp2=`perl -E "say ${mem_arr[$id]}/1024."`

    printf '%3s: %-7s %.2fs %.3fMB\n' $id ${verdict_arr[$id]} $tmp $tmp2 
    # ENDTODO
done
