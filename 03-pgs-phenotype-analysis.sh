#!/bin/bash

set -e


phenotype_file="input/example.phenotypes.txt" # the same for every reference panel! 
input_phenotypes_specification="Phenotype_1,Phenotype_2,Phenotype_3"
input_PGS_numbers="PGS002695,PGS002695,PGS002695"
input_variants_file="input/variants.csv"


# directory where R-script is located and name of R-script
RMD_FOLDER="$(pwd)"  
RMD_SCRIPT="03-pgs-phenotype-analysis.Rmd"
FILE_PATH="$(pwd)" # here absolute paths are necessary!
OUTPUT_DIR="$(pwd)/output/pgs-phenotypes_results"  # here absolute paths are necessary!






# every reference panel individually called (hard-coded) without any loops

# analysis 1000genomes


OUTPUT_HTML="1000genomes-analysis"

# create new directory in the output directory with the same name as the output file
mkdir -p $OUTPUT_DIR/$OUTPUT_HTML


PHENOTYPES="${phenotype_file}"
PGS_DATA="input/example.1000genomes.scores.txt"


Rscript -e "require( 'rmarkdown' ); render('${RMD_FOLDER}/${RMD_SCRIPT}',
    params = list(
      input_phenotypes = '${PHENOTYPES}',
      input_PGS_data = '${PGS_DATA}',
      input_phenotypes_specification = '${input_phenotypes_specification}',
      input_PGS_numbers = '${input_PGS_numbers}',
      input_variants_file= '${input_variants_file}'
      
      
    ),
    intermediates_dir='${FILE_PATH}',
    knit_root_dir='${FILE_PATH}',
    output_file='${OUTPUT_DIR}/${OUTPUT_HTML}/${OUTPUT_HTML}.html'
  )"

# analysis hrc


OUTPUT_HTML="hrc-analysis"


# create new directory in the output directory with the same name as the output file
mkdir -p $OUTPUT_DIR/$OUTPUT_HTML


PHENOTYPES="${phenotype_file}"
PGS_DATA="input/example.hrc.scores.txt"



Rscript -e "require( 'rmarkdown' ); render('${RMD_FOLDER}/${RMD_SCRIPT}',
    params = list(
      input_phenotypes = '${PHENOTYPES}',
      input_PGS_data = '${PGS_DATA}',
      input_phenotypes_specification = '${input_phenotypes_specification}',
      input_PGS_numbers = '${input_PGS_numbers}',
      input_variants_file= '${input_variants_file}'
      
      
    ),
    intermediates_dir='${FILE_PATH}',
    knit_root_dir='${FILE_PATH}',
    output_file='${OUTPUT_DIR}/${OUTPUT_HTML}/${OUTPUT_HTML}.html'
  )"
