#!/bin/bash
for f in result/*; do
    base=`basename "$f"`
    if [ -L "original/$base" ]; then
	orig=`readlink -f "original/$base"`
	echo "Moving $base"
	mv "$f" "$orig"
	rm "original/$base"
    else
        echo -e "\E[33mSkipping $base, no original file or not a symlink\E[0m"
    fi
done
