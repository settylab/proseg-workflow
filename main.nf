/* See nextflow.config for param declarations */

platform = params.platform.toLowerCase()
if (!(platform in ['xenium', 'cosmx', 'merscope'])) {
    error "${params.platform} is an invalid platform type. Please specify xenium, cosmx, or merscope"
}

if (params.enforce_connectivity) {
    connectivity_flag = "--enforce-connectivity"
} else {
    connectivity_flag = ""
}

if (params.ignore_z_coord) {
    flat2d_flag = "--ignore-z-coord"
    println "Warning: Ignoring z-coordinate and running Proseg in 2D mode"
} else {
    flat2d_flag = ""
}

println "Settings:"
println "platform: ${platform}"
println "connectivity_flag: ${connectivity_flag}"
println "ignore_z_coord: ${flat2d_flag}"
println "transcriptsFile: ${params.transcriptsFile}"
println "outputDir: ${params.outputDir}"

process PROSEG {
    publishDir "${params.outputDir}"

    input:
    path transcripts


    output:
    path 'expected-counts.csv.gz', emit: counts
    path 'cell-metadata.csv.gz', emit: cell_metadata
    path 'transcript-metadata.csv.gz', emit: transcript_metadata
    path 'gene-metadata.csv.gz', emit: gene_metadata
    path 'rates.csv.gz', emit: rates
    path 'cell-polygons.geojson.gz', emit: cell_polygons_2d
    path 'cell-polygons-layers.geojson.gz', emit:  cell_polygons_layers
    path 'cell-hulls.geojson.gz', emit: cell_hulls

    script:
    """
    proseg --${platform} ${transcripts} \
        --output-expected-counts expected-counts.csv.gz \
        --output-cell-metadata cell-metadata.csv.gz \
        --output-transcript-metadata transcript-metadata.csv.gz \
        --output-gene-metadata gene-metadata.csv.gz \
        --output-rates rates.csv.gz \
        --output-cell-polygons cell-polygons.geojson.gz \
        --output-cell-polygon-layers cell-polygons-layers.geojson.gz \
        --output-cell-hulls cell-hulls.geojson.gz \
        ${connectivity_flag} ${flat2d_flag}
    """
}


workflow {
    transcripts = file("${params.transcriptsFile}")
    PROSEG(transcripts)
}


