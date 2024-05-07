/* See nextflow.config for param declarations */

params.platform = params.platform.toLowerCase()
if (!(params.platform in ['xenium', 'cosmx', 'merfish'])) {
    error "${params.platform} is an invalid platform type. Please specify xenium, cosmx, or merfish"
}

if (params.enforce_connectivity) {
    connectivity_flag = "--enforce-connectivity"
} else {
    connectivity_flag = ""
}

process PROSEG {
    publishDir "${params.outputDir}"

    input:
    path "${params.inputDir}/${params.transcriptsFile}"


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
    proseg --${params.platform} ${params.transcriptsFile} \
        --output-expected-counts expected-counts.csv.gz \
        --output-cell-metadata cell-metadata.csv.gz \
        --output-transcript-metadata transcript-metadata.csv.gz \
        --output-gene-metadata gene-metadata.csv.gz \
        --output-rates rates.csv.gz \
        --output-cell-polygons cell-polygons.geojson.gz \
        --output-cell-polygon-layers cell-polygons-layers.geojson.gz \
        --output-cell-hulls cell-hulls.geojson.gz \
        ${connectivity_flag}
    """
}


workflow {
    transcripts = file("${params.inputDir}/${params.transcriptsFile}")
    PROSEG(transcripts)
}


