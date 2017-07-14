#!/bin/bash


logfile="log.txt"
OUTPUTPATH=""
INPUTPATH=""

main(){
    path=$INPUTPATH
    for file in `ls $path`
    do
        ext=${file#*.}
        if [ $ext != "mp4" ]
        then
            continue
        fi
        log_to_file "start convert ${file}"
        convertformat $path$file
    done
}


log_to_file(){
    echo $1
    echo "$1" >> ${logfile}
}

convertformat(){
    file=$1
    name=$(basename $file .mp4)
    ts=$INPUTPATH$name".ts"
    m3u8=$INPUTPATH$name".m3u8"
    ffmpeg -i $file -codec copy -bsf h264_mp4toannexb $ts
    ffmpeg -i $ts -c copy -map 0 -f segment -segment_list $INPUTPATH$name".m3u8" -segment_time 10 $INPUTPATH"output%03d.ts"
    head -n 17 $m3u8 > /tmp/$name".m3u8"
    mv /tmp/$name".m3u8" $m3u8
    echo "#EXT-X-ENDLIST" >> $m3u8
    rm -rf $INPUTPATH"output.ts" $INPUTPATH$name".ts"
    mkdir $OUTPUTPATH$name
    output=$OUTPUTPATH$name"/"
    ia=$INPUTPATH"*.ts"
    ib=$INPUTPATH"*.m3u8"
    mv $ia $output
    mv $ib $output
    log_to_file "${file} convert done!\n"
}

test(){
    name=8
    output=$OUTPUTPATH$name"/"
    a="${INPUTPATH}*.ts"
    cp -r $a $output

}

while getopts 'i:o:' OPT; do
    case $OPT in
        i)
            INPUTPATH=$OPTARG"/";;
        o)
            OUTPUTPATH=$OPTARG"/";;
    esac
done


if [ $# -lt 2 ];then
    echo "usage: \n"
    echo "$0 -i path -o path"
    exit 1
fi

main
