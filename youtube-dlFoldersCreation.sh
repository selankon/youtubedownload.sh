#!/bin/bash
# This script automatizes youtube-dl download from a file.
# How it works?
# The file must to have the following properties to work:
#	- Each line must to be or a url or the name of the folder that will contain the songs
#	- Replace spaces on folder names by "_"
# 	- The unique arg of this script must to be the file with all the song list
#	- Should accept youtube lists (it download full list)
#	- The file accept commented lines with #
# For example, for the file:
#   https://rooturl...
#	macarena
#	https://oneurl
#	https://secondurl
#	blahblah
#	https://thirdurl
#
#	The root url will be saved on the pwd where script executed
# 	The oneurl and seconurl on pwd/macarena
#	The thirdurl on pwd/blahblah

SAVELOG=true
LOGNAME="downloadlog.log"

HOME=$(pwd)
URLPARSED=0
FOLDERSCREATED=0
PROGRESS=0
TOTALLINES=0

TOTALDOWNLOADED=0
TOTALFAILED=0
declare -a myarray

function download {
	#Download mp3
	MP3="--extract-audio --audio-format mp3 -i "	
	
	#youtube-dl --extract-audio --audio-format mp3 $1
	COMMAND="youtube-dl $MP3 $1"
	echo "YOUTUBE-DL COMMAND EXECUTED:	 	$COMMAND"
	#Download 
	eval $COMMAND
	some_command
	if [ $? -eq 0 ]; then
		echo "DOWNLOAD SUCCESS "
	 	TOTALDOWNLOADED=$((TOTALDOWNLOADED+1))
	else
		echo "DOWNLOAD FAIL "
	 	TOTALFAILED=$((TOTALFAILED+1))
	fi
}

function isUrl {
	regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
	#string='http://www.google.com/test/link.php'
	if [[ $1 =~ $regex ]]
	then 
	    echo 1
	else
	    echo 0
	fi	
}

function readFileWords {
	# Load file into array.
	let i=0
	while IFS=$'\n' read -r line_data; do
		myarray[i]="${line_data}"
		((++i))
	done < $1
	
	#printArray
	TOTALINES=$i
	echo "TOTAL LINES $TOTALINES"
	parseString "${myarray[@]}"
	
}


function parseString {
	for var in "$@"
	do
		PROGRESS=$((PROGRESS+1))
		percent=$(awk "BEGIN { pc=100*${PROGRESS}/${TOTALINES}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
		echo "Total PROGRESS: $percent%"
		
		if [[ -z "$var" ]]
		then
			echo "------"
		elif [[ ${var:0:1} == '#' ]]
		then
			echo "Commented line $var"
		elif [[ $(isUrl $var) -eq 1 ]]	
		then	
			echo "Downloading url " $var
		 	URLPARSED=$((URLPARSED+1))
			download $var
		else
			var=${var// /_} # Replace white spaces by _
			echo "Creating directory $var"

			cd $HOME
			mkdir $var
		 	FOLDERSCREATED=$((FOLDERSCREATED+1))
			cd $var
		fi
	done
	end_time="$(date -u +%s)"
	elapsed="$(($end_time-$start_time))"
	
	echo 	"------------------------------"
	echo -e "UrlParsed: \t \t $URLPARSED "
	#echo -e "SuccessDownloads: \t $TOTALDOWNLOADED " DONTWORK PROPERLY
	#echo -e "ErrorDownloads: \t $TOTALFAILED "
	echo -e "FoldersCreated: \t $FOLDERSCREATED "
	echo -e "Time elapsed: \t \t $elapsed"
}

start_time="$(date -u +%s)"
if [ "$SAVELOG" = true ] ; then
	echo "SAvelog"
    readFileWords $1 | tee -a $LOGNAME
else
	readFileWords $1
fi
 

