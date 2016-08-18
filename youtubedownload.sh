#!/bin/bash
# You can pass as argument an url or a file with urls

# Constants
declare -a myarray
declare -a arguments
OUT="."

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

function isTextFile {
	if file "$1" | grep -q text; then
    # is text
    	echo 1
	else
	# file doesn't think it's text
		echo 0
	fi

}

function isParameter {

	if  [[ $1 == -* ]] ;
	then
		echo 1
	else
	    echo 0
	fi
}


function printArray {
	# Explicitly report array content.
	let i=0
	while (( ${#myarray[@]} > i )); do
		echo "${myarray[i++]}"
	done
}


function download {
	#Download mp3
	MP3="--extract-audio --audio-format mp3 "
	ARGS=""
	if [ "$OUT" != "." ]; then
		ARGS=$ARGS" -o '$OUT/%(title)s.%(ext)s'"	
	fi
	
	
	#youtube-dl --extract-audio --audio-format mp3 $1
	COMMAND="youtube-dl $ARGS $MP3 $1"
	echo "YOUTUBE-DL COMMAND EXECUTED:	 	$COMMAND"
	#Download 
}



function readFileWords {
	# Load file into array.
	let i=0
	while IFS=$'\n' read -r line_data; do
		myarray[i]="${line_data}"
		((++i))
	done < $1
	
	#printArray
	readArgs "${myarray[@]}"
	
}

function checkArg {
	
	# If it's a parameter do nothing
	if [[ $(isParameter $1) -eq 1 ]]
	then
		echo "A parameter!!!!"
	# Parse a text file looking for url inside
	elif [[ $(isTextFile $1) -eq 1 ]]
	then
		echo "Is a text file"
		readFileWords $1
	# If its a valid url try to download using youtube-dl
	elif [[ $(isUrl $1) -eq 1 ]]
	then
		echo "Valid Url: $1"
		download $1
	else
		echo "Error: argument not valid: $1"
	fi
}

function readArgs {
	for var in "$@"
	do
		checkArg $var
	done
}

#https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash-script


# MAIN

# 1- Get all "-X" parameters arguments and modify the variables

while test $# -gt 0; do

	if [[ $(isParameter $1) -eq 1 ]];then
		case "$1" in
			-h|--help)
				echo "Use: ./youtubedownload.sh [PARAMS] [URL... | FILE...] "
				echo " "
				echo "This script download a youtube song/video using youtube-dl"
				echo "You can pas the url of video as argument, or text file with multiple url or a parameter."
				echo "Parameters:"
				echo "	-h|--help 		This help text"
				echo "	-o			Output folder"
				exit 0
				;;
			-o)
				shift
				#echo "AAA $1"
				if [[ -d $1 ]]; then
					OUT="$1"
					#touch lol
					shift
				elif [[ ! -d $1 ]]; then
					mkdir -p $1
					OUT="$1"
					#touch kk
					shift
				else 	
					echo "Specified directory parameter is not correct"
					exit 0
				fi	
				
				#$OUT=
				;;
			*)
				echo "Error: Parameter $1 not recognized"
		        shift
		        ;;
			
		esac
	else
		arguments+=($1)
		shift
	fi
	
done


# 2- Read again the parameters this time getting the urls or text files
#readArgs $@
readArgs  "${arguments[@]}"
#readFileWords $1
