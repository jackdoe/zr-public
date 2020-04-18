root=$(dirname $0)
mkdir -p $root/data
if [ ! -f $root/data/RFC.tar.gz ]; then
    curl -sL https://www.rfc-editor.org/in-notes/tar/RFC-all.tar.gz  > $root/data/RFC.tar.gz
fi

pushd $root/data
tar --wildcards '*.txt' -xzvf RFC.tar.gz
popd

echo > data/pagerank.in
# simply make 
for rfc in $(ls -1 $root/data/ | grep txt); do
    echo $rfc
    for row in $(cat $root/data/$rfc | sed -r 's/RFC ([0-9]+)/_ZR_rfc\1.txt_ZR_/g' | tr "_ZR_" "\n" | rg -w 'rfc\d+.txt' | grep -v $rfc); do
        echo $rfc $row >> $root/data/pagerank.in
    done
done

cat data/pagerank.in | pagerank -int > data/pagerank

for rfc in $(ls -1 $root/data/ | grep txt); do
    score=$(cat $root/data/pagerank | grep -w $rfc | cut -f 1 -d ' ' | head -1)
    popularity=${score:-0}
    echo $rfc score: $popularity

    zr-stdin -k rfc -root $root/../public/ -title $rfc -id $rfc -popularity $popularity -file $root/data/$rfc
done

zr-reindex -k rfc -root $root/../public
tar -czvf $root/../dist/rfc.tar.gz $root/../public/rfc

