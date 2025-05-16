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
println "flat2d_flag: ${flat2d_flag}"
println "transcriptsFile: ${params.transcriptsFile}"
println "outputDir: ${params.outputDir}"
println "sampleID: ${params.sampleID}"

process PROSEG {
    publishDir "${params.outputDir}/proseg"
    container "ruijintracyyang/proseg:latest"

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
    echo "Proseg version:"
    proseg --version
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

process PROSEG2BAYSOR {
    publishDir "${params.outputDir}/proseg2baysor"
    container "ruijintracyyang/proseg:latest"

    input:
    path transcript_metadata
    path cell_polygons

    output:
    path 'baysor-transcript-metadata.csv', emit: baysor_metadata
    path 'baysor-cell-polygons.geojson', emit: baysor_polygons

    script:
    """
    proseg-to-baysor  \
        ${transcript_metadata} \
        ${cell_polygons} \
        --output-transcript-metadata baysor-transcript-metadata.csv \
        --output-cell-polygons baysor-cell-polygons.geojson
    """
}

process XR_IMPORTSEG {
    publishDir "${params.outputDir}/xeniumranger"
    container "769915755291.dkr.ecr.us-west-2.amazonaws.com/xeniumranger:3.0.1"

    input:
    path baysor_metadata
    path baysor_polygons
    path xa_directory
    val sampleID

    output:
    path "${sampleID}"

    script:
    """
    xeniumranger import-segmentation \
        --id ${sampleID} \
        --xenium-bundle ${xa_directory} \
        --viz-polygons ${baysor_polygons} \
        --transcript-assignment ${baysor_metadata} \
        --units microns
    """
}

workflow {
    transcripts = file("${params.transcriptsFile}")
    proseg_result = PROSEG(transcripts)

    proseg2baysor_result = PROSEG2BAYSOR(
        proseg_result.transcript_metadata,
        proseg_result.cell_polygons_2d
    )

    XR_IMPORTSEG(
        proseg2baysor_result.baysor_metadata,
        proseg2baysor_result.baysor_polygons,
        transcripts.parent,
        params.sampleID
    )
}


