#!/bin/bash
dir=`dirname $(realpath $0)`
DEFAULT_SPEEDUP=`cat $dir/SPEEDUP 2> /dev/null`
DEFAULT_SPEEDUP=${DEFAULT_SPEEDUP:-+45}

speedup=${1:-${DEFAULT_SPEEDUP}}
echo "Using tempo change ${speedup}%"
mkdir /tmp/result 2>/dev/null
ln -s /tmp/result 2>/dev/null

trap interrupt INT

function interrupt() {
    echo -e "\nDeleting unfinished $name"
    rm "result/$name" 2> /dev/null
    exit 1
}

count=`ls original/*.mp3 2>/dev/null | wc -l`
if [ ! $count -gt 0 ]; then
    echo "No input files"
    exit 0
fi

i=1
for f in original/*.mp3; do
    name=`basename "$f"`
    if [ ! -f "result/$name" ]; then
        printf "\E[32m%3.0f%%\E[0m Processing %s" "$(($i*100/$count))." "$name"
        lame --quiet --decode "$f" - | soundstretch stdin stdout -tempo=$speedup -speech 2>/dev/null | lame --quiet -m a -cbr -b 64 --resample 24  - "result/$name"
        echo -e "\E[32m Done\E[0m"
    else
        printf "\E[32m%3.0f%%\E[0m Skipping %s\n" "$(($i*100/$count))" "$name"
    fi
    i=$((i+1))
done
