//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fasta_channel(it) }
        .set { assemblies }

    emit:
    assemblies                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fasta_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample

    // add path(s) of the fastq file(s) to the meta map
    def fasta_meta = []
    if (!file(row.fasta).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Sample 1 Fasta file does not exist!\n${row.fasta_1}"
    }
    fasta_meta = [ meta, [ file(row.fasta) ] ]
    return fasta_meta
}
