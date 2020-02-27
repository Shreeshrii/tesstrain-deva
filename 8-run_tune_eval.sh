#!/bin/sh
# nohup time -p bash   8-run_tune_eval.sh allfonts Minus > reports/8-allfonts-Minus.txt & 

SCRIPTPATH=`pwd`
LANG=$1
BUILDTYPE=$2
CHECKPOINT=${LANG}${BUILDTYPE}
FASTMODEL=${CHECKPOINT}_fast
FONTLIST=$SCRIPTPATH/langdata/$LANG.fontslist.txt
HEADCOUNT=390

lstmtraining \
 	--stop_training \
 	--continue_from $SCRIPTPATH/data/$LANG/checkpoints/${CHECKPOINT}_checkpoint \
 	--traineddata data/$LANG/$LANG.traineddata \
 	--model_output data/${CHECKPOINT}.traineddata

lstmtraining \
 	--stop_training \
    --convert_to_int \
 	--continue_from $SCRIPTPATH/data/$LANG/checkpoints/${CHECKPOINT}_checkpoint \
 	--traineddata data/$LANG/$LANG.traineddata \
 	--model_output data/$FASTMODEL.traineddata

mkdir -p $SCRIPTPATH/reports
for PREFIX in $LANG ; do
    head -$HEADCOUNT $SCRIPTPATH/data/$PREFIX/list.eval > $SCRIPTPATH/data/$PREFIX/list.test
    LISTEVAL=$SCRIPTPATH/data/$PREFIX/list.test
    REPORTSPATH=$SCRIPTPATH/reports/$PREFIX-eval-${FASTMODEL}
    rm -rf $REPORTSPATH
    mkdir $REPORTSPATH
    echo -e  "\n-----------------------------------------------------------------------------"  $PREFIX 
    while IFS= read -r FONTNAME
    do
        ### echo "$SCRIPTPATH" >  $REPORTSPATH/manifest-$PREFIX-"${FONTNAME// /_}".log
		echo -e "----------------------------------------------------------------------------- Devanagari  $PREFIX-${FONTNAME// /_} \n"
        while IFS= read -r LSTMFNAME
        do
            if [[ "$LSTMFNAME" == *"${FONTNAME// /_}."* ]]; then
                  ### echo "${LSTMFNAME%.*}.tif" >> $REPORTSPATH/manifest-$PREFIX-"${FONTNAME// /_}".log
                  OMP_THREAD_LIMIT=1 tesseract "${LSTMFNAME%.*}.tif"  "${LSTMFNAME%.*}-"${FASTMODEL} --psm 6 --oem 1  -l ${FASTMODEL} --tessdata-dir $SCRIPTPATH/data  -c page_separator=''   1>/dev/null 2>&1
                  cat "${LSTMFNAME%.*}".gt.txt   >>  "$REPORTSPATH/gt-$PREFIX-"${FONTNAME// /_}".txt"
                  cat "${LSTMFNAME%.*}"-${FASTMODEL}.txt   >>  $REPORTSPATH/ocr-${FASTMODEL}-$PREFIX-${FONTNAME// /_}.txt
            fi
        done < "$LISTEVAL"
        accuracy $REPORTSPATH/gt-$PREFIX-${FONTNAME// /_}.txt  $REPORTSPATH/ocr-${FASTMODEL}-$PREFIX-${FONTNAME// /_}.txt  > $REPORTSPATH/report_${FASTMODEL}-$PREFIX-${FONTNAME// /_}.txt
        java -cp ~/ocrevaluation/ocrevaluation.jar  eu.digitisation.Main  -gt $REPORTSPATH/gt-$PREFIX-${FONTNAME// /_}.txt  -ocr $REPORTSPATH/ocr-$FASTMODEL-$PREFIX-${FONTNAME// /_}.txt  -e UTF-8   -o $REPORTSPATH/report_$FASTMODEL-$PREFIX-${FONTNAME// /_}.html  1>/dev/null 2>&1
        head -26 $REPORTSPATH/report_${FASTMODEL}-$PREFIX-${FONTNAME// /_}.txt
        cat $REPORTSPATH/gt-$PREFIX-${FONTNAME// /_}.txt  >> $REPORTSPATH/gt-$PREFIX-ALL.txt 
        cat $REPORTSPATH/ocr-$FASTMODEL-$PREFIX-${FONTNAME// /_}.txt >> $REPORTSPATH/ocr-$FASTMODEL-$PREFIX-ALL.txt 
        echo -e "----------------------------------------------------------------------------- Devanagari Finished $FONTNAME **********************************\n"
        done < "$FONTLIST"
        accuracy $REPORTSPATH/gt-$PREFIX-ALL.txt  $REPORTSPATH/ocr-$FASTMODEL-$PREFIX-ALL.txt  > $REPORTSPATH/report_$FASTMODEL-$PREFIX-ALL.txt
        java -cp ~/ocrevaluation/ocrevaluation.jar  eu.digitisation.Main  -gt $REPORTSPATH/gt-$PREFIX-ALL.txt  -ocr $REPORTSPATH/ocr-$FASTMODEL-$PREFIX-ALL.txt  -e UTF-8   -o $REPORTSPATH/report_$FASTMODEL-$PREFIX-ALL.html      1>/dev/null 2>&1
echo "Finished $PREFIX"
done 

egrep 'Devanagari|Accuracy$|Digits|Punctuation' reports/8-${LANG}-${BUILDTYPE}.txt > reports/8-${LANG}-${BUILDTYPE}-summary.txt