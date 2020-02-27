#!/bin/sh
# nohup time -p bash   7-run_checkpoint_eval.sh allfonts Minus 1 > reports/7-allfonts-Minus.txt & 

SCRIPTPATH=`pwd`
LANG=$1
SCRIPT=Devanagari
BUILDTYPE=$2
CHECKPOINTCOUNT=$3
mkdir -p $SCRIPTPATH/reports
HEADCOUNT=390

# cleanup old files
rm gt/*/*${BUILDTYPE}_*.txt 
# rm data/$LANG/tessdata_fast/*${BUILDTYPE}*.traineddata data/$LANG/tessdata_best/*${BUILDTYPE}*.traineddata

# make traineddata files from last few checkpoints
ls -t data/$LANG/checkpoints/*${BUILDTYPE}*.checkpoint | head -$CHECKPOINTCOUNT > tmpcheckpoints
CHECKPOINT_FILES=tmpcheckpoints
while IFS= read -r TESTCHECK
do
    make traineddata MODEL_NAME=$LANG  CHECKPOINT_FILES=$TESTCHECK
done < "$CHECKPOINT_FILES"

TRAINEDDATAFILES=data/$LANG/tessdata_fast/*${BUILDTYPE}*.traineddata
for TRAINEDDATA in $TRAINEDDATAFILES  ; do
     TRAINEDDATAFILE="$(basename -- $TRAINEDDATA)"
	echo $TRAINEDDATA
	echo $TRAINEDDATAFILE
	echo ${TRAINEDDATAFILE%.*}
      echo -e  "\n------------------------------------------------------------------- $SCRIPT \n"
      echo -e  "\n------------------------------------------------------------------- $SCRIPT  $PREFIX-${TRAINEDDATAFILE%.*} \n"
           for PREFIX in $LANG ; do
			   FONTLIST=$SCRIPTPATH/langdata/$PREFIX.fontslist.txt
                head -$HEADCOUNT $SCRIPTPATH/data/$PREFIX/list.eval > $SCRIPTPATH/data/$PREFIX/list.test
               LISTEVAL=$SCRIPTPATH/data/$PREFIX/list.test
               REPORTSPATH=$SCRIPTPATH/reports/$PREFIX-eval-${TRAINEDDATAFILE%.*}
               rm -rf $REPORTSPATH
               mkdir $REPORTSPATH
               echo -e  "\n-----------------------------------------------------------------------------"  $PREFIX 
               while IFS= read -r FONTNAME
               do
                   echo "$SCRIPTPATH" > $REPORTSPATH/manifest-$PREFIX-${FONTNAME// /_}.log
                   echo -e  "\n------------------------------------------------------------------- $SCRIPT"  $PREFIX-${FONTNAME// /_}-${TRAINEDDATAFILE%.*}
                    while IFS= read -r LSTMFNAME
                    do
                        if [[ $LSTMFNAME == *${FONTNAME// /_}.* ]]; then
                            echo ${LSTMFNAME%.*}.tif >> $REPORTSPATH/manifest-$PREFIX-${FONTNAME// /_}.log
                            OMP_THREAD_LIMIT=1 tesseract ${LSTMFNAME%.*}.tif  ${LSTMFNAME%.*}.${TRAINEDDATAFILE%.*} --psm 6 --oem 1  -l  ${TRAINEDDATAFILE%.*}  --tessdata-dir $SCRIPTPATH/data/$LANG/tessdata_fast/  -c page_separator=''   1>/dev/null 2>&1
                            cat ${LSTMFNAME%.*}.gt.txt   >>  $REPORTSPATH/gt-$PREFIX-${FONTNAME// /_}.txt
                            cat ${LSTMFNAME%.*}.${TRAINEDDATAFILE%.*}.txt   >>  $REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-${FONTNAME// /_}.txt
                    fi
                done < $LISTEVAL
                 accuracy $REPORTSPATH/gt-$PREFIX-${FONTNAME// /_}.txt  $REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-${FONTNAME// /_}.txt  > $REPORTSPATH/report_${TRAINEDDATAFILE%.*}-$PREFIX-${FONTNAME// /_}.txt
                 wordacc $REPORTSPATH/gt-$PREFIX-${FONTNAME// /_}.txt  $REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-${FONTNAME// /_}.txt  > $REPORTSPATH/report_${TRAINEDDATAFILE%.*}-$PREFIX-${FONTNAME// /_}-wordacc.txt
                head -26 $REPORTSPATH/report_${TRAINEDDATAFILE%.*}-$PREFIX-${FONTNAME// /_}.txt
                cat $REPORTSPATH/gt-$PREFIX-${FONTNAME// /_}.txt  >> $REPORTSPATH/gt-$PREFIX-ALL.txt 
                cat $REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-${FONTNAME// /_}.txt >> $REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-ALL.txt 
                echo -e  "\n-----------------------------------------------------------------------------"  
            done < "$FONTLIST"
             accuracy $REPORTSPATH/gt-$PREFIX-ALL.txt  $REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-ALL.txt  > $REPORTSPATH/report_${TRAINEDDATAFILE%.*}-$PREFIX-ALL.txt
            java -cp ~/ocrevaluation/ocrevaluation.jar  eu.digitisation.Main  -gt "$REPORTSPATH/gt-$PREFIX-ALL.txt"  -ocr "$REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-ALL.txt"  -e UTF-8   -o "$REPORTSPATH/report_${TRAINEDDATAFILE%.*}-$PREFIX-ALL.html"      1>/dev/null 2>&1
             wordacc $REPORTSPATH/gt-$PREFIX-ALL.txt  $REPORTSPATH/ocr-${TRAINEDDATAFILE%.*}-$PREFIX-ALL.txt  > $REPORTSPATH/report_${TRAINEDDATAFILE%.*}-$PREFIX-ALL-wordacc.txt
            echo -e  "\n-----------------------------------------------------------------------------  $SCRIPT"  
        done 
        echo -e  "\n*************************************************************************  $SCRIPT"  
done
rm tmpcheckpoints

egrep  'Devanagari|Accuracy$|Digits|Punctuation' reports/7-$LANG-${BUILDTYPE}.txt > reports/7-$LANG-${BUILDTYPE}-summary.txt
