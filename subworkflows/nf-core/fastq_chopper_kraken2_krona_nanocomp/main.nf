// 
// ONT Read QC, trimming and taxonomy
//

include { CHOPPER   } from '../../../modules/nf-core/chopper/main'
include { NANOCOMP  } from '../../../modules/nf-core/nanocomp/main'
include { KRONA_KTUPDATETAXONOMY    } from '../../../modules/nf-core/krona/ktupdatetaxonomy/main'
include { KRAKEN2_KRAKEN2    } from '../../../modules/nf-core/kraken2/main'
include { KRONA_KTIMPORTTAXONOMY    } from '../../../modules/nf-core/krona/ktimporttaxonomy/main'

workflow  {

    take:
    ch_reads              // channel: [ val(meta), path(reads)  ]
    ch_krakendb           // channel: [ path(krakendb)  ]
    path taxonomy, stageAs: 'taxonomy.tab' 
    or
    ch_taxonomy           // channel: [ path(taxonomy)  ]
    val_skip_kraken2      // value: boolean

    main:

    ch_versions = Channel.empty()
    ch_chopped_reads = Channel.empty()
    ch_nanocomp_rep_html = Channel.empty()
    ch_kraken_rep = Channel.empty()
    ch_krona_plot = Channel.empty()

    // Read trimming
    CHOPPER (
        ch_reads
    )
    ch_chopped_reads    = CHOPPER.out.fastq //.concat(reads_ch2).set{coll_reads_ch} for nanocomp
    ch_versions         = ch_versions.mix(CHOPPER.out.versions.first())

    // QC via NanoComp on both raw and trimmed reads
    NANOCOMP (
        ch_chopped_reads    // only chopped reads atm
    )
    // need to add all the output statements?
    ch_nanocomp_rep_html = NANOCOMP.out.report_html //.toSortedList()
    ch_versions         = ch_versions.mix(NANOCOMP.out.versions.first())

    // Preliminary taxonomic classification incl. Krona plots
    if (!val_skip_kraken2) {
        KRONA_KTUPDATETAXONOMY(
            ch_taxonomy
        )
        KRAKEN2_KRAKEN2(
            ch_reads,
            ch_krakendb
        )
        // add kraken reports to emit later
        ch_kraken_rep = KRAKEN2_KRAKEN2.out.
        KRONA_KTIMPORTTAXONOMY(
            ch_kraken_rep,
            ch_taxonomy
        )
        //TODO krona output
        ch_krona_plot = KRONA_KTIMPORTTAXONOMY.out.
        
        ch_versions   = ch_versions.mix(KRONA_KTUPDATETAXONOMY.out.versions.first())
        ch_versions   = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions.first())
        ch_versions   = ch_versions.mix(KRONA_KTIMPORTTAXONOMY.out.versions.first())
    }
    

    emit:
    // TODO nf-core: edit emitted channels
    chopped_reads           = ch_chopped_reads       // channel: [ val(meta), [ reads ] ]
    nanocomp_report_html    = ch_nanocomp_rep_html   // channel: [ val(meta), [ html ] ]
    
    versions = ch_versions                     // channel: [ versions.yml ]
}