// Define the pipeline parameters
params.fastq_files = "samplesheet.test.txt"  // Path to a file containing the list of FASTQ files
params.outdir = "results"          // Directory to store the output files

// Print the pipeline parameters
log.info "FASTQ files list: ${params.fastq_files}"
log.info "Output directory: ${params.outdir}"

// Process definition
process run_dechat {
    container "oras://community.wave.seqera.io/library/dechat:1.0.1--0cdf9c7516a8a247"
    publishDir params.outdir, pattern: "*.dechat.corrected.ec.fa", mode: 'copy'

    input:
    path fastq_file

    output:
    path "*.dechat.corrected.ec.fa", emit: corrected_file

    script:
    // Determine the base name based on whether the file is gzipped
    def output_base = fastq_file.toString().endsWith('.gz') ? file(fastq_file.baseName).baseName : fastq_file.baseName
    """
    dechat -o ${output_base}.dechat.corrected -t ${task.cpus} -i ${fastq_file}
    """
}


// Workflow definition
workflow {
    // Read the list of FASTQ files
    Channel.fromPath(params.fastq_files)
        .splitCsv(header: false)
        .map { row -> file(row[0]) }
        .set { fastq_files_ch }

    // Run the dechat process on each FASTQ file
    run_dechat(fastq_files_ch)
        .map { corrected_file -> file(corrected_file) }
        .set { corrected_files_ch }

    // Collect and store the output files
    corrected_files_ch
        .collect()
        .set { corrected_files }

    // Print the output files
    corrected_files.view { file -> "Corrected file: ${file}" }
}

// Save the output files to the specified directory
workflow.onComplete {
    corrected_files.each { file ->
        new File(params.outdir).mkdirs()
        file.copyTo(new File(params.outdir, file.getName()))
    }
    log.info "Pipeline completed successfully. Output files are stored in ${params.outdir}"
}
