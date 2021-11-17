#!/bin/bash
set -e
print_help(){
cat << 'EOF'

A musicbase utility to copy last played values from an existing CSV-type database file
Usage: otherdb.sh [option] FILE PATHCOL TIMECOL DELIM

options:
-h display this help file
-i database FILE does not contain a header
-n specify TXXX frame name (default: Songs-DB_Custom1)

Requires kid3. Using the kid3-cli utility, scans all music file paths using the database FILE and checks each for existence of the frame name identified (default is Songs-DB_Custom1). If it does not exist, creates a TXXX frame with that name, then assigns the LastTimePlayed time value from the FILE to the tag frame.

Requires four positional arguments. Specify input database FILE, PATHCOL (FILE column number containing the track's file path), TIMECOL (FILE column number containing the last played date), and DELIM (database's field delimiter). The format of the TIMECOL field must be a numerical time value of either sql time or epoch time.

EOF
}
framename="Songs-DB_Custom1"
excludeheader="no"
# Use getops to set any user-assigned options
while getopts ":hin:" opt; do
  case $opt in
    h) 
      print_help
      exit 0;;
    i)
      excludeheader="yes" 
      ;;
    n)
      framename=$OPTARG 
      ;;
    \?)
      printf 'Invalid option: -%s\n' "$OPTARG"
      exit 1 ;;
  esac
done
shift $((OPTIND-1))
## Verify user provided required, valid path and time argument
if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]] || [[ -z "$4" ]]
then
    printf  '\n%s\n' "****Missing positional argument(s)******"
    print_help
    exit 1
fi
dbinputfile=$1
pathcol=$2
timecol=$3
dbdelim=$4
{
if [ $excludeheader == "no" ];then read;fi # if header identified, skip first line
while IFS= read -r line; do    
    trackpath="$(echo $line | awk -F "$dbdelim" -v pathcol="$pathcol" '{ print $pathcol }')"
    exists=$(kid3-cli -c "get ""$framename" "$trackpath")
    if [ -z "$exists" ];then sudo kid3-cli -c "set TXXX.Description ""$framename" "$trackpath";fi
    timeval="$(echo $line | awk -F "$dbdelim" -v timecol="$timecol" '{ print $timecol }')"
    echo $trackpath $timeval 
    sudo kid3-cli -c "set ""$framename"" $timeval" "$trackpath"
done 
} < "$dbinputfile"
