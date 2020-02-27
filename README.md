# tesstrain-deva

Training workflow for Tesseract 4 for Finetune Plus/Minus for Devanagari script.

## leptonica, tesseract

You will need a recent version (>= 4.0.0beta1) of tesseract built with the
training tools and matching leptonica bindings.
[Build](https://github.com/tesseract-ocr/tesseract/wiki/Compiling)
[instructions](https://github.com/tesseract-ocr/tesseract/wiki/Compiling-%E2%80%93-GitInstallation)
and more can be found in the [Tesseract project
wiki](https://github.com/tesseract-ocr/tesseract/wiki/).

## tesstrain

This repo uses a modified version of Makefile from [tesstrain](https://github.com/tesseract-ocr/tesstrain) alongwith some bash scripts to run Finetune training.

For tesstrain, single line images and their corresponding ground truth transcription is used. This repo uses page level images and their transcription.

## License

Software is provided under the terms of the `Apache 2.0` license.
