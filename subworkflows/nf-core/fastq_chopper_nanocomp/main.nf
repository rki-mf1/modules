// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join

//
// ONT Read QC, trimming and taxonomy
//

include { CHOPPER  } from '../../../modules/nf-core/chopper/main'
include { NANOCOMP as RAW_NANOCOMP } from '../../../modules/nf-core/nanocomp/main'
include { NANOCOMP as CHOPPED_NANOCOMP } from '../../../modules/nf-core/nanocomp/main'
include { NANOCOMP as COMBINED_NANOCOMP } from '../../../modules/nf-core/nanocomp/main'

workflow FASTQ_CHOPPER_NANOCOMP {

    take:
    ch_reads              // channel: [ val(meta), path(reads) ]

    main:
    ch_versions = Channel.empty()
    ch_chopped_reads = Channel.empty()
    ch_nanocomp_raw_html = Channel.empty()
    ch_nanocomp_chopped_html = Channel.empty()
    ch_nanocomp_combined_html = Channel.empty()

    raw_nc_in = ch_reads
                    .collect(flat: false)
                    .transpose()
                    .collect(flat: false)

    RAW_NANOCOMP( raw_nc_in )

    // Read trimming
    CHOPPER ( ch_reads )
    ch_versions = ch_versions.mix(CHOPPER.out.versions)

    // QC via NanoComp on both raw and trimmed reads
    ch_chopped_reads = CHOPPER.out.fastq
    chopped_nc_in = ch_chopped_reads
                        .collect(flat: false)
                        .transpose()
                        .collect(flat: false)

    CHOPPED_NANOCOMP ( chopped_nc_in )
    ch_versions = ch_versions.mix(CHOPPED_NANOCOMP.out.versions)

    // consumes all named output channels
    chopped_reports = Channel.empty()
    for (def name in CHOPPED_NANOCOMP.out.getNames()) {
        def ch_res = CHOPPED_NANOCOMP.out.getProperty(name)
        chopped_reports = chopped_reports.concat(ch_res)
    }
    // ch_chopped_reports = chopped_reports.collect()

    emit:
    chopped_reads    = CHOPPER.out.fastq   // channel: [ val(meta), [ reads ] ]
    // nanocomp_raw     = raw_reports         // channel: val(nanocomp_outputs)
    nanocomp_chopped = chopped_reports     // channel: val(nanocomp_outputs)
    versions         = ch_versions         // channel: [ versions.yml ]
}
