#!/bin/sh

echo "processdocs.sh [sourcedir] [targetdir]"
echo "- An empty document name means the document should be skipped"
echo "- ! as the document name means this document is a continuation of the previous one"
echo "- An empty document date is given today's date"
echo "- File names are in the form 'yyyymmdd Document name.jpg'"
echo "- Unless there is more than one document with the same name (i.e. a multipage document)"
echo "  in which case the documents are numbered 'yyyymmdd Document name [1..N].jpg"

for f in $1*; do
    eog $f 2>/dev/null&
    ppid=$!
    
    read -p "Document name (just enter to skip): " docname
    if [ -n "$docname" ]; then
        if [ "$docname" = '!' ]; then
            docname="$lastname"
            lastdate="$lastdate"
        else
            read -p "Document date (yyyymmdd - just enter for today): " docdate
            if [ -z "$docdate" ]; then docdate="`/bin/date +%Y%m%d`"; fi
        fi
        if [ -e "$2$docdate $docname.jpg" ]; then mv "$2$docdate $docname.jpg" "$2$docdate $docname 1.jpg"; fi
        postfix=1
        while [ -e "$2$docdate $docname $postfix.jpg" ]; do postfix=`expr $postfix + 1`; done
        if [ $postfix -eq 1 ]; then
            convert $f -adaptive-resize 30% "$2$docdate $docname.jpg" 2>/dev/null
        else
            convert $f -adaptive-resize 30% "$2$docdate $docname $postfix.jpg" 2>/dev/null
        fi
        lastname="$docname"
        lastdate="$docdate"
    fi
    kill $ppid
done
