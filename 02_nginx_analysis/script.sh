#!/bin/bash

DEFAULT_ROWCOUNT=15
ANALYSIS_HISTORY_FILE="/tmp/anal_history.tmp"
CURRENT_DATETIME=$(date +%s)

function show-help {
  printf "Usage: $0 <access.log path> {top_hosts|low_hosts|top_routes|low_routes|errors|all} [row count (default: 15)]\n"
}

function instance-count {
  local instance="$1"
  echo $(ps aux | grep "$instance" | wc -l)
}

if [[ $1 = "--help" ]]; then
  show-help
  exit
fi

# 1. принимать путь до анализируемого файла как параметр и завершаться, отдавая сообщение об ошибке с кодом 10, если параметр не задан;
if (( $# < 2 )); then
  show-help
  exit 10
fi

# 5. автоматически завершаться, если в теле скрипта будет обнаружена ошибка при его выполнении;
# https://mads-hartmann.com/2017/06/16/writing-readable-bash-scripts.html#the-header-ceremony
# set -u
set -e
set -o pipefail

INPUT_FILE=$1

# 2. анализировать доступность файла по заданному пути и завершаться, отдавая сообщение об ошибке с кодом 20, если файл не существует;
if [[ ! -f $INPUT_FILE && ! -s $INPUT_FILE ]]; then
  echo "Error: File \"$INPUT_FILE\" is empty or does not exist."
  exit 20
fi

# 4. содержать защиту от мультизапуска;
if (( $(instance-count $0) > 4 )); then
  echo "Error: Already running!"
  exit 40
fi

# Set default rowcount if not specified
if (( $# >= 3 )); then
  ROW_COUNT=$3
else
	ROW_COUNT=$DEFAULT_ROWCOUNT
fi


echo "Current date: `date --date=@$CURRENT_DATETIME \"+%d/%b/%Y:%T\"`"

# Check last date
if [[ -f $ANALYSIS_HISTORY_FILE ]]; then
	LAST_DATETIME=$(cat $ANALYSIS_HISTORY_FILE | tail -n 1)
	last_date=$(date --date=@$LAST_DATETIME "+%d/%b/%Y:%T")
	echo "Last analysis date: $last_date"
fi

# Count new records
nrecc=$( tac $1 | awk '{  if ( $1=="ЗАПИСИ" && $2=="ОБРАБОТАНЫ" ) exit 0 ; else print }' | wc -l || true )

if [ $nrecc -le 0 ]; then
  echo "In $1 has no new recordes"
  echo $cdseq >> $ANALYSIS_HISTORY_FILE
  exit 0
fi

echo "New records count: $nrecc"
echo

# Various analysis methods
top_hosts() {
  tmp_top_l=`cat ${INPUT_FILE} | awk '{print $1}' | sort -n | uniq -c | sort -nr`

  printf "[Top $ROW_COUNT hosts]\n"
  printf "$tmp_top_l\n\n" | head -"$ROW_COUNT" || echo
}

low_hosts() {
  tmp_low_l=`cat ${INPUT_FILE} | awk '{print $1}' | sort -n | uniq -c | sort -nr`

  printf "[Low $ROW_COUNT hosts]\n"
  printf "$tmp_low_l\n\n" | tail -"$ROW_COUNT"
}

top_routes() {
  tmp_top_r=`cat ${INPUT_FILE} | awk '{print $7}' | sort -n | uniq -c | sort -nr`

  printf "[Top $ROW_COUNT routes]\n"
  printf "$tmp_top_r\n\n" | head -"$ROW_COUNT"
}

low_routes() {
  tmp_low_r=`cat ${INPUT_FILE} | awk '{print $7}' | sort -n | uniq -c | sort -nr`

  printf "[Low $ROW_COUNT routes]\n"
  printf "$tmp_low_r\n\n" | tail -"$ROW_COUNT"
}

error_list() {
  tmp_err_l=`cat ${INPUT_FILE} | awk ' $9 ~ /^[54]/ {print $9}' | sort -n | uniq -c | sort -nr`

  printf "[Error List]\n"
  printf "$tmp_err_l\n\n" | head -"$ROW_COUNT"
}

function all {
	top_hosts
	low_hosts
	top_routes
	low_routes
	error_list
}

# Output selection
case $2 in
	top_hosts)
	top_hosts
	;;
	low_hosts)
	low_hosts
	;;
	top_routes)
	top_routes
	;;
	low_routes)
	low_routes
	;;
	errors)
	error_list
	;;
	all)
  all
	;;
	*)
	echo "option name not found"
	exit 6
	;;
esac

echo "$CURRENT_DATETIME" >> $ANALYSIS_HISTORY_FILE

exit 0
