# proseg-workflow
Basic nextflow pipeline to run [Proseg](https://github.com/dcjones/proseg) on a single sample

## Configuration
Pipeline parameters can be specified in `nextflow.config`

Key parameters include:
* `platform` - `xenium`, `cosmx`, or `merfish`
* `outputDir` - where to store the output files
* `inputDir` - directory with the input file(s)
* `transcriptsFile` - filename in `inputDir` with transcript info. For Xenium this is `transcripts.parquet`
* `enforce_connectivity` - prevent cells from having disconnected voxels
* `ignore_z_coord` - run in 2D mode

### CosMx
Right now `proseg-workflow` only supports running Proseg on CosMx data with the `--cosmx` flag. If there is interest
in supporting `--cosmx-micron` and FOV stitching, please create an issue. 

## Install
Make sure [Nextflow](https://github.com/nextflow-io/nextflow) and [Proseg](https://github.com/dcjones/proseg) are installed.

### Docker
A [docker container](https://hub.docker.com/repository/docker/tbencomo/proseg/general) with Proseg is provided easy deployment

To run the pipeline with docker:
```
nextflow run main.nf -with-docker [docker env name]
```

## Execution
This workflow can be run on [Cirro](https://cirro.bio/)

On Cirro the workflow is launched with 16 CPUs and 64GB of memory on AWS. If the initial run crashes, nextflow will try to relaunch 3 times with increasing levels of memory (64GB, 128GB, 192GB).
