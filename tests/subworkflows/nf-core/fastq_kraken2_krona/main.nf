#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { UNTAR                 } from '../../../../modules/nf-core/untar/main.nf'
include { FASTQ_KRAKEN2_KRONA   } from '../../../../subworkflows/nf-core/fastq_kraken2_krona/main.nf'

workflow test_fastq_kraken2_krona_singleend_illumina {

    input = [ [ id:'test', single_end:true ], // meta map
                [ file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true) ]
            ]
    db    = [[], file(params.test_data['sarscov2']['genome']['kraken2_tar_gz'], checkIfExists: true)]

    UNTAR ( db )
    FASTQ_KRAKEN2_KRONA ( input, UNTAR.out.untar.map{ it[1] }, false, false )
}


workflow test_fastq_kraken2_krona_pairedend_illumina {

    input = [ [ id:'test', single_end:false ], // meta map
              [ file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true),
                file(params.test_data['sarscov2']['illumina']['test_2_fastq_gz'], checkIfExists: true) ]
            ]
    db    =  [[], file(params.test_data['sarscov2']['genome']['kraken2_tar_gz'], checkIfExists: true)]

    UNTAR ( db )
    FASTQ_KRAKEN2_KRONA ( input, UNTAR.out.untar.map{ it[1] }, false, false )
}


workflow test_fastq_kraken2_krona_ont {

    input = [ [id: "test_", single_end: true],
                [file(params.test_data['sarscov2']['nanopore']['test_fastq_gz'], checkIfExists: true)]
            ]
    db    =  [[], file(params.test_data['sarscov2']['genome']['kraken2_tar_gz'], checkIfExists: true)]

    UNTAR ( db )
    FASTQ_KRAKEN2_KRONA ( input, UNTAR.out.untar.map{ it[1] }, false, false )
}
