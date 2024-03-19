// fastq_classify_plot_kraken2_krona

include { KRAKEN2_KRAKEN2           } from '../../../modules/nf-core/kraken2/kraken2/main'
include { KRAKENTOOLS_KREPORT2KRONA } from '../../../modules/nf-core/krakentools/kreport2krona/main'
include { KRONA_KTIMPORTTEXT        } from '../../../modules/nf-core/krona/ktimporttext/main'

workflow FASTQ_KRAKEN2_KRONA {
    take:
    ch_reads                     // channel: [ val(meta), path(reads)  ]
    ch_krakendb                  // channel: [ path(krakendb)  ]
    save_output_fastqs           // val: true/false
    save_reads_assignment        // val: true/false

    main:
    ch_versions       = Channel.empty()
    ch_kraken_report  = Channel.empty()
    ch_krona_table    = Channel.empty()
    ch_krona_plot     = Channel.empty()

    // classify samples
    KRAKEN2_KRAKEN2( ch_reads, ch_krakendb, save_output_fastqs, save_reads_assignment )
    ch_kraken_report = KRAKEN2_KRAKEN2.out.report
    ch_kraken_report.view { "$it" }

    // prepare kraken reports for krona consumption
    KRAKENTOOLS_KREPORT2KRONA( ch_kraken_report )
    ch_krona_table = KRAKENTOOLS_KREPORT2KRONA.out.txt
    ch_krona_table.view { "$it" }

    KRONA_KTIMPORTTEXT( ch_krona_table )
    ch_krona_plot = KRONA_KTIMPORTTEXT.out.html
    ch_krona_plot.view { "$it" }

    // log versions
    ch_versions = ch_versions.mix( KRAKEN2_KRAKEN2.out.versions           )
    ch_versions = ch_versions.mix( KRAKENTOOLS_KREPORT2KRONA.out.versions )
    ch_versions = ch_versions.mix( KRONA_KTIMPORTTEXT.out.versions        )

    emit:
    kraken_report = ch_kraken_report  // channel: [ val(meta), [ report ] ]
    krona_table   = ch_krona_table    // channel: [ val(meta), [ krona_table ] ]
    krona_plot    = ch_krona_plot     // channel: [ val(meta), [ krona_plot ] ]
    versions      = ch_versions       // channel: [ versions.yml ]
}
