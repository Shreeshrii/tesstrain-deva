#!/bin/bash
# nohup bash 2-train.sh > shreelipi.log & 

export PYTHONIOENCODING=utf8
ulimit -s 65536
SCRIPTPATH=`pwd`

MODEL=shreelipi
BUILD=Minus
LANG=san
ITERATIONS=100000

########## rm -rf $SCRIPTPATH/data/$MODEL
mkdir -p $SCRIPTPATH/data/$MODEL
mkdir -p $SCRIPTPATH/data/script/Devanagari

cd $SCRIPTPATH/data/$MODEL
wget -O $SCRIPTPATH/data/script/Devanagari.traineddata https://github.com/tesseract-ocr/tessdata_best/raw/master/script/Devanagari.traineddata
combine_tessdata -u $SCRIPTPATH/data/script/Devanagari.traineddata $SCRIPTPATH/data/script/Devanagari/$MODEL.
wget -O $MODEL.config https://github.com/tesseract-ocr/langdata_lstm/raw/master/${LANG}/${LANG}.config
wget -O $MODEL.numbers https://github.com/tesseract-ocr/langdata_lstm/raw/master/${LANG}/${LANG}.numbers
wget -O $MODEL.punc https://github.com/tesseract-ocr/langdata_lstm/raw/master/${LANG}/${LANG}.punc
Version_Str="$MODEL:shreeshrii`date +%Y%m%d`:from:"
sed -e "s/^/$Version_Str/" $SCRIPTPATH/data/script/Devanagari/$MODEL.version > $MODEL.version

find $SCRIPTPATH/gt/$MODEL -type f -name '*.lstmf' > /tmp/all-$MODEL-lstmf
python3 $SCRIPTPATH/shuffle.py 1 < /tmp/all-$MODEL-lstmf > all-lstmf

echo "" > all-gt
cat $SCRIPTPATH/gt/$MODEL/*.gt.txt >> all-gt

cp  $SCRIPTPATH/langdata/Layer.fontslist.txt all-fonts

cd ../..

make  training  \
MODEL_NAME=$MODEL  \
LANG_TYPE=Indic \
BUILD_TYPE=${BUILD}  \
TESSDATA=$SCRIPTPATH/data \
GROUND_TRUTH_DIR=$SCRIPTPATH/gt/$MODEL \
START_MODEL=script/Devanagari \
RATIO_TRAIN=0.95 \
DEBUG_INTERVAL=-1 \
MAX_ITERATIONS=$ITERATIONS

### 
### lstmtraining \
###   --stop_training \
###   --convert_to_int \
###   --continue_from data/$MODEL/checkpoints/${MODEL}${BUILD}_checkpoint \
###   --traineddata $SCRIPTPATH/data/script/Devanagari.traineddata \
###   --model_output data/${MODEL}${BUILD}_fast.traineddata
### 
### OMP_THREAD_LIMIT=1   time -p  lstmeval  \
###   --model data/${MODEL}${BUILD}_fast.traineddata \
###   --eval_listfile data/$MODEL/list.eval \
###   --verbosity 0
### 
### OMP_THREAD_LIMIT=1   time -p  lstmeval  \
###   --model $SCRIPTPATH/data/script/Devanagari.traineddata \
###   --eval_listfile data/$MODEL/list.eval \
###   --verbosity 0
### 
### 