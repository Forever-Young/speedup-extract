#!/bin/bash
dir=`dirname $(realpath $0)`
DEFAULT_SPEEDUP=`cat $dir/SPEEDUP 2> /dev/null`
DEFAULT_SPEEDUP=${DEFAULT_SPEEDUP:-+45}

DEFAULT_SOURCE=original

trap interrupt INT

function interrupt() {
    echo -e "\nDeleting unfinished $name.mp3"
    rm "result/$name.mp3" 2> /dev/null
    rm /tmp/temp.wav 2> /dev/null
    rm /tmp/temp.mp4a 2> /dev/null
    exit 1
}

original=$1
if [ ! -d "$original" ]; then
    speedup=${original:-${DEFAULT_SPEEDUP}}
    original=${2:-$DEFAULT_SOURCE}
else
    speedup=${2:-${DEFAULT_SPEEDUP}}
fi

if [ "$speedup" == "0" ]; then
    echo "Only extracting"
else
    echo "Using tempo change ${speedup}%"
fi
echo "Using source directory ${original}"

mkdir /tmp/result 2>/dev/null
ln -s /tmp/result 2>/dev/null

count=`ls $original/*.mp4 2>/dev/null | wc -l`
if [ ! $count -gt 0 ]; then
    echo "No input files"
    exit 0
fi

i=1
for f in $original/*.mp4; do
    name=`basename "$f" .mp4`
    if [ ! -f "result/$name.mp3" ]; then
	printf "\E[32m%3.0f%%\E[0m Processing %s. \E[32mExtracting...\E[0m" "$(($i*100/$count))" "$name.mp4"
	mplayer "$f" -dumpaudio -dumpfile /tmp/temp.mp4a > /dev/null 2>&1
	faad /tmp/temp.mp4a > /dev/null 2>&1
	if [ "$speedup" == "0" ]; then
	    lame --quiet -m a -cbr -b 64 --resample 24 /tmp/temp.wav "result/${name}.mp3"
	    echo -e "\b\b\b\b\b\b\b\b\b\b\b\b\bExtracting. \E[32mDone\E[0m"
	else
	    echo -en "\b\b\b\b\b\b\b\b\b\b\b\b\bExtracting. \E[32mSpeeding up...\E[0m"
	    soundstretch /tmp/temp.wav stdout -tempo=$speedup -speech 2>/dev/null | lame --quiet -m a -cbr -b 64 --resample 24  - "result/${name}.mp3"
	    echo -e "\b\b\b\b\b\b\b\b\b\b\b\b\b\bSpeeding up. \E[32mDone\E[0m"
	fi
	rm /tmp/temp.wav 2> /dev/null
	rm /tmp/temp.mp4a 2> /dev/null
    else
	printf "\E[32m%3.0f%%\E[0m Skipping %s\n" "$(($i*100/$count))" "$name.mp4"
    fi
    i=$((i+1))
done
