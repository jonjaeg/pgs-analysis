#!/bin/bash
set -e

# directory where R-script is located and name of R-script
RMD_FOLDER="$(pwd)"  
RMD_SCRIPT="02-pgs-diff.Rmd"
FILE_PATH="$(pwd)" # here absolute paths are necessary!
OUTPUT_DIR="$(pwd)/output/pgs-diff-result"  # here absolute paths are necessary!


# name of the output html file
OUTPUT_HTML="1000genomes_vs_hrc"

# create new directory in the output directory with the same name as the output file
mkdir -p $OUTPUT_DIR


# input files for the R-markdown-script
FILE1="output/pop-filter-results/example.1000genomes.scores.filtered.txt"
FILE2="output/pop-filter-results/example.hrc.scores.filtered.txt"
COVERAGE_FILE1="input/example.1000genomes.coverage.txt"
COVERAGE_FILE2="input/example.hrc.coverage.txt"

# in the "Rscript" intermediate_dir, knit_root_dir und output_file brauchen absolute paths!

Rscript -e "require( 'rmarkdown' ); render('${RMD_FOLDER}/${RMD_SCRIPT}',
    params = list(
      input_file1 = '${FILE1}',
      input_file2 = '${FILE2}',
      coverage_input_file1 = '${COVERAGE_FILE1}',
      coverage_input_file2 = '${COVERAGE_FILE2}'
    ),
    intermediates_dir='${FILE_PATH}',
    knit_root_dir='${FILE_PATH}',
    output_file='${OUTPUT_DIR}/${OUTPUT_HTML}.html'
  )"
