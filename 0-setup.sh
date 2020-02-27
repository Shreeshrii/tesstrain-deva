#!/bin/bash

export PYTHONIOENCODING=utf8
ulimit -s 65536
SCRIPTPATH=`pwd`

mkdir -p data langdata gt reports
mkdir -p data/script/Devanagari

cp /home/ubuntu/langdata_lstm/Latin.unicharset data/
cp /home/ubuntu/langdata_lstm/Devanagari.unicharset data/
cp /home/ubuntu/langdata_lstm/Inherited.unicharset data/

cp /home/ubuntu/tessdata_best/script/Devanagari.traineddata  data/script/
combine_tessdata -u data/script/Devanagari.traineddata data/script/Devanagari/Devanagari.

cp /home/ubuntu/langdata_save_lstm/san/NEW.training_text langdata/Layer.training_text
cp /home/ubuntu/langdata_save_lstm/san/OK.fontslist.txt langdata/Layer.fontslist.txt 

cp /home/ubuntu/tessdata_fast/script/Devanagari.traineddata data/fast_Devanagari.traineddata
cp /home/ubuntu/tessdata_fast/hin.traineddata data/fast_hin.traineddata
cp /home/ubuntu/tessdata_fast/san.traineddata data/fast_san.traineddata
