// fastq_classify_plot_kraken2_krona

include { KRAKEN2_KRAKEN2           } from '../../../modules/nf-core/kraken2/kraken2/main'
include { KRAKENTOOLS_KREPORT2KRONA } from '../../../modules/nf-core/krakentools/kreport2krona/main'
include { KRONA_KTIMPORTTEXT        } from '../../../modules/nf-core/krona/ktimporttext/main'

workflow KRAKEN2_KRONA {
    take:
    ch_reads                     // channel: [ val(meta), path(reads)  ]
    ch_krakendb                  // channel: [ path(krakendb)  ]
    save_output_fastqs           // val:
    save_reads_assignment        // val:

    main:
    ch_versions       = Channel.empty()
    ch_kraken_report  = Channel.empty()
    ch_krona_table    = Channel.empty()
    ch_krona_plot     = Channel.empty()

    // classify samples
    KRAKEN2_KRAKEN2( ch_reads, ch_krakendb, save_output_fastqs, save_reads_assignment )
    ch_kraken_report = KRAKEN2_KRAKEN2.out.report

    // prepare kraken reports for krona consumption
    ch_krona_table = KRAKENTOOLS_KREPORT2KRONA( KRAKEN2_KRAKEN2.out.report ).out.txt
    KRONA_KTIMPORTTEXT( ch_krona_table )

    // add krona output
    ch_krona_plot = KRONA_KTIMPORTTEXT.out.html

    // log versions
    ch_versions = ch_versions.mix( KRAKEN2_KRAKEN2.out.versions.first()           )
    ch_versions = ch_versions.mix( KRAKENTOOLS_KREPORT2KRONA.out.versions.first() )
    ch_versions = ch_versions.mix( KRONA_KTIMPORTTEXT.out.versions.first()        )

    emit:
    kraken_report = ch_kraken_report  // channel: [ val(meta), [ report ] ]
    krona_table   = ch_krona_table    // channel: [ val(meta), [ krona_table ] ]
    krona_plot    = ch_krona_plot     // channel: [ val(meta), [ krona_plot ] ]
    versions      = ch_versions       // channel: [ versions.yml ]
}
