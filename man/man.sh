#!/bin/bash

root=$(dirname $0)
[ -d $root/man-pages ] || git clone https://github.com/mkerrisk/man-pages $root/man-pages
(cd $root/man-pages; git pull)

which pagerank &> /dev/null || ( echo could not find 'pagerank', exec 'go get github.com/jackdoe/updown && go install github.com/jackdoe/updown/cmd/pagerank' && exit 1 )
which rg &> /dev/null || ( echo 'you need to install ripgrep, https://github.com/BurntSushi/ripgrep (usually apt install ripgrep)' && exit 1 )

rg '.BR \w+ \(' $root/man-pages/man[1-9]* \
    | sed -e 's/ //g' \
    | sed -e 's/.BR//g' \
    | tr '(' '.' \
    | cut -f 1 -d ')' \
    | sed -e 's/.*\///g' \
    | sed -e 's/:/ /' \
    | pagerank -int -prob-follow 0.6 -tolerance 0.001 > /tmp/zr-man-pagerank

export MANWIDTH=80

for i in `find $root/man-pages/man[1-9] -type f -name '*.[0-9]'`; do
    base=$(basename $i)
    score=$(cat /tmp/zr-man-pagerank | grep -w $base | cut -f 1 -d ' ')
    popularity=${score:-0}
    echo $base score: $popularity

    man -P cat $base | zr-stdin -k man -root $root/../public -title $base -id $base -popularity $popularity
done

zr-reindex -k man -root $root/../public
