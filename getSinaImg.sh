#!/bin/bash
for file in `find _posts -type f `; do
    for i in `egrep "https?://[wx0-9]*\.sinaimg\.cn.*?\.jpg" $file -o`; do 
        n=`md5 -q -s $i`
        url=${i/large/mw2048}
        curl $url -o /Users/liqingshou/Work/xiaochai/xiaochai.github.io/assets/images/sina/$n.jpg
        echo "$i  $n" >> ./map
        sed -i "" "s/${i//\//\\/}/\/assets\/images\/sina\/$n.jpg/" $file
    done
done
