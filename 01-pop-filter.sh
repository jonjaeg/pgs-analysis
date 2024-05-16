#!/bin/bash

set -e

# input directories 
meta_data_file="input/pgs_all_metadata_scores.csv" # for all reference panels the same!
input_1000genomes="input/example.1000genomes.scores.txt" # relative paths to PGS file
input_hrc="input/example.hrc.scores.txt"

# directory where R-script is located and name of R-script
RMD_FOLDER="$(pwd)"  
RMD_SCRIPT="01-pop-filter.Rmd"
FILE_PATH="$(pwd)" # here absolute paths are necessary!
OUTPUT_DIR="$(pwd)/output/pop-filter-results"  # here absolute paths are necessary!

mkdir -p $OUTPUT_DIR


# for every panel a seperate folder is created (hard coded)
# filter for 1000genomes

OUTPUT_FILE="example.1000genomes.scores.filtered"


# in the "Rscript" intermediate_dir, knit_root_dir und output_file brauchen absolute paths!

Rscript -e "require( 'rmarkdown' ); render('${RMD_FOLDER}/${RMD_SCRIPT}',
    params = list(
      input_metadata = '${meta_data_file}',
      input_PGS_file_to_filter = '${input_1000genomes}',
      output_filename='${OUTPUT_DIR}/${OUTPUT_FILE}.txt'
    ),
    intermediates_dir='${FILE_PATH}',
    knit_root_dir='${FILE_PATH}',
    output_file='${OUTPUT_DIR}/${OUTPUT_FILE}.html'
  )"



# filter for hrc
OUTPUT_FILE="example.hrc.scores.filtered"


Rscript -e "require( 'rmarkdown' ); render('${RMD_FOLDER}/${RMD_SCRIPT}',
    params = list(
      input_metadata = '${meta_data_file}',
      input_PGS_file_to_filter = '${input_hrc}',
      output_filename='${OUTPUT_DIR}/${OUTPUT_FILE}.txt'
    ),
    intermediates_dir='${FILE_PATH}',
    knit_root_dir='${FILE_PATH}',
    output_file='${OUTPUT_DIR}/${OUTPUT_FILE}.html'
  )"
